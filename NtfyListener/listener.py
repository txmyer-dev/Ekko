#!/usr/bin/env python3
"""
ntfy Listener — Two-way comms channel for PAI
Subscribes to ntfy topic via SSE, routes inbound messages to SecondBrain inbox.
Sends acknowledgment back on the same topic.
"""

import json
import os
import sys
import signal
import logging
from datetime import datetime
from pathlib import Path
from urllib.request import urlopen, Request
from urllib.error import URLError
from urllib.parse import urlencode

# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------
NTFY_SERVER = "ntfy.sh"
NTFY_TOPIC = "ekko-6b6c21fbd9a6ca84"
NTFY_URL = f"https://{NTFY_SERVER}/{NTFY_TOPIC}/sse"

# Where to write inbound messages
SECONDBRAIN_INBOX = Path.home() / "SecondBrain" / "Inbox" / "ntfy-inbox.md"
FALLBACK_INBOX = Path.home() / ".claude" / "MEMORY" / "ntfy-inbox.md"

# Logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
log = logging.getLogger("ntfy-listener")

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def get_inbox_path() -> Path:
    """Return SecondBrain inbox if mounted, else fallback."""
    try:
        # Symlink may exist but target drive may be offline — test with actual I/O
        sb_dir = SECONDBRAIN_INBOX.parent
        sb_dir.mkdir(parents=True, exist_ok=True)
        # Verify we can actually write (catches unmounted drives behind symlinks)
        test_file = sb_dir / ".write-test"
        test_file.touch()
        test_file.unlink()
        return SECONDBRAIN_INBOX
    except OSError:
        pass
    FALLBACK_INBOX.parent.mkdir(parents=True, exist_ok=True)
    return FALLBACK_INBOX


def append_to_inbox(message: str, title: str = "") -> Path:
    """Append a timestamped message to the inbox file."""
    inbox = get_inbox_path()
    now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    # Create file with header if it doesn't exist
    if not inbox.exists():
        inbox.write_text("# ntfy Inbox\n\nMessages received from Tony via ntfy.\n\n---\n\n")

    entry = f"## [{now}]"
    if title:
        entry += f" {title}"
    entry += f"\n\n{message}\n\n---\n\n"

    with open(inbox, "a") as f:
        f.write(entry)

    log.info(f"Message saved to {inbox}")
    return inbox


def send_ack(original_message: str):
    """Send acknowledgment back on the ntfy topic."""
    try:
        ack_url = f"https://{NTFY_SERVER}/{NTFY_TOPIC}"
        now = datetime.now().strftime("%H:%M")
        body = f"Got it. Saved to inbox at {now}."

        req = Request(ack_url, data=body.encode("utf-8"), method="POST")
        req.add_header("Title", "Ekko")
        req.add_header("Tags", "robot,inbox_tray")
        req.add_header("Priority", "2")  # low — don't buzz for acks

        with urlopen(req, timeout=10) as resp:
            if resp.status == 200:
                log.info("Ack sent")
            else:
                log.warning(f"Ack failed: HTTP {resp.status}")
    except Exception as e:
        log.warning(f"Ack failed: {e}")


def is_own_ack(data: dict) -> bool:
    """Filter out our own acknowledgment messages to avoid loops."""
    title = data.get("title", "")
    message = data.get("message", "")
    return title == "Ekko" and "Saved to inbox" in message


# ---------------------------------------------------------------------------
# SSE Listener
# ---------------------------------------------------------------------------

def listen():
    """Subscribe to ntfy topic via SSE and process messages."""
    log.info(f"Connecting to {NTFY_URL}")

    while True:
        try:
            req = Request(NTFY_URL)
            req.add_header("Accept", "text/event-stream")

            with urlopen(req, timeout=None) as response:
                log.info("Connected. Listening for messages...")

                for raw_line in response:
                    line = raw_line.decode("utf-8").strip()

                    # SSE format: lines starting with "data: " contain the payload
                    if not line.startswith("data: "):
                        continue

                    json_str = line[6:]  # strip "data: "

                    try:
                        data = json.loads(json_str)
                    except json.JSONDecodeError:
                        continue

                    # Only process actual messages (not keepalives/open events)
                    if data.get("event") != "message":
                        continue

                    # Skip our own acks
                    if is_own_ack(data):
                        log.debug("Skipping own ack")
                        continue

                    message = data.get("message", "")
                    title = data.get("title", "")

                    if not message:
                        continue

                    log.info(f"Received: {title or '(no title)'} — {message[:80]}")

                    # Route to inbox
                    append_to_inbox(message, title)

                    # Acknowledge
                    send_ack(message)

        except (URLError, ConnectionError, TimeoutError) as e:
            log.warning(f"Connection lost: {e}. Reconnecting in 10s...")
            import time
            time.sleep(10)
        except Exception as e:
            log.error(f"Unexpected error: {e}. Reconnecting in 30s...")
            import time
            time.sleep(30)


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def handle_shutdown(signum, frame):
    log.info("Shutting down...")
    sys.exit(0)

if __name__ == "__main__":
    signal.signal(signal.SIGTERM, handle_shutdown)
    signal.signal(signal.SIGINT, handle_shutdown)
    listen()
