#!/usr/bin/env python3
"""SecondBrain Mount Helper — auto-retry F: drive, fall back to local.

Usage (CLI):
    python3 mount_check.py              # Returns the usable SecondBrain path
    python3 mount_check.py --sync       # Sync fallback → F: drive (when F: is back)
    python3 mount_check.py --status     # Show current mount status

Usage (importable):
    from mount_check import get_secondbrain_path, sync_fallback
"""

import os
import shutil
import subprocess
import sys
from pathlib import Path

# Paths
SECONDBRAIN_PRIMARY = Path("/mnt/f/txmyer/SecondBrain")
SECONDBRAIN_FALLBACK = Path.home() / ".claude" / "SecondBrain-fallback"
SYMLINK_PATH = Path.home() / "SecondBrain"

# Directories to mirror in fallback
MIRROR_DIRS = ["Memory", "Knowledge", "Sessions", "Inbox", "Heartbeat", "Skills", "Templates", "Tools"]


def is_drive_accessible() -> bool:
    """Check if F: drive is actually accessible (not just mounted)."""
    try:
        test_path = SECONDBRAIN_PRIMARY / "Memory"
        # Try actual I/O — catches mounted-but-dead states
        test_path.exists()
        # Double-check with a stat call
        os.statvfs(str(SECONDBRAIN_PRIMARY))
        return True
    except (OSError, IOError):
        return False


def try_remount() -> bool:
    """Attempt to remount F: drive via WSL mount command."""
    try:
        subprocess.run(
            ["sudo", "mount", "-t", "drvfs", "F:", "/mnt/f", "-o", "uid=1000,gid=1000"],
            capture_output=True,
            timeout=10,
        )
        return is_drive_accessible()
    except (subprocess.TimeoutExpired, FileNotFoundError):
        return False


def ensure_fallback() -> Path:
    """Create fallback directory structure if it doesn't exist."""
    SECONDBRAIN_FALLBACK.mkdir(parents=True, exist_ok=True)
    for d in MIRROR_DIRS:
        (SECONDBRAIN_FALLBACK / d).mkdir(exist_ok=True)

    # Create a Welcome.md so it's obvious this is a fallback
    marker = SECONDBRAIN_FALLBACK / ".fallback-active"
    marker.touch()

    return SECONDBRAIN_FALLBACK


def get_secondbrain_path() -> Path:
    """Return the best available SecondBrain path.

    Priority:
    1. F: drive (primary) — if accessible
    2. F: drive (after remount attempt) — if remount succeeds
    3. Local fallback — always available
    """
    # Try primary first
    if is_drive_accessible():
        return SECONDBRAIN_PRIMARY

    # Try remount
    if try_remount():
        return SECONDBRAIN_PRIMARY

    # Fall back to local
    return ensure_fallback()


def sync_fallback() -> dict:
    """Sync any files from fallback → primary when F: is back.

    Only copies files that are newer in fallback than in primary.
    Returns dict of what was synced.
    """
    if not is_drive_accessible():
        return {"status": "error", "message": "F: drive not accessible, cannot sync"}

    if not SECONDBRAIN_FALLBACK.exists():
        return {"status": "skip", "message": "No fallback directory exists"}

    marker = SECONDBRAIN_FALLBACK / ".fallback-active"
    if not marker.exists():
        return {"status": "skip", "message": "Fallback not active (no pending changes)"}

    synced = []

    for d in MIRROR_DIRS:
        fallback_dir = SECONDBRAIN_FALLBACK / d
        primary_dir = SECONDBRAIN_PRIMARY / d

        if not fallback_dir.exists():
            continue

        primary_dir.mkdir(parents=True, exist_ok=True)

        for f in fallback_dir.glob("*"):
            if f.is_file() and f.name != ".fallback-active":
                target = primary_dir / f.name

                # Copy if target doesn't exist or fallback is newer
                if not target.exists() or f.stat().st_mtime > target.stat().st_mtime:
                    shutil.copy2(f, target)
                    synced.append(f"{d}/{f.name}")

    # Clean up fallback marker
    if synced:
        marker.unlink(missing_ok=True)

    return {
        "status": "synced" if synced else "clean",
        "files": synced,
        "message": f"Synced {len(synced)} files to F: drive" if synced else "No new files to sync",
    }


def print_status():
    """Print current mount status."""
    drive_ok = is_drive_accessible()
    fallback_exists = SECONDBRAIN_FALLBACK.exists()
    fallback_active = (SECONDBRAIN_FALLBACK / ".fallback-active").exists() if fallback_exists else False

    print(f"F: drive (/mnt/f):  {'ONLINE' if drive_ok else 'OFFLINE'}")
    print(f"Fallback dir:       {'EXISTS' if fallback_exists else 'NONE'}")
    print(f"Fallback active:    {'YES (pending sync)' if fallback_active else 'NO'}")
    print(f"Recommended path:   {get_secondbrain_path()}")

    if fallback_active and drive_ok:
        print("\nFallback has pending changes — run with --sync to push to F: drive")


def main():
    if len(sys.argv) > 1:
        if sys.argv[1] == "--sync":
            result = sync_fallback()
            print(f"Status: {result['status']}")
            print(f"Message: {result['message']}")
            if result.get("files"):
                for f in result["files"]:
                    print(f"  - {f}")
        elif sys.argv[1] == "--status":
            print_status()
        else:
            print(f"Unknown flag: {sys.argv[1]}")
            print("Usage: mount_check.py [--sync | --status]")
            sys.exit(1)
    else:
        # Default: just print the usable path
        path = get_secondbrain_path()
        print(str(path))


if __name__ == "__main__":
    main()
