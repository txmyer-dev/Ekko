"""Configuration for UnrealSpeech Voice Server."""

import os
from pathlib import Path

# Load .env from ~/.claude/.env
_env_path = Path.home() / ".claude" / ".env"
if _env_path.exists():
    for line in _env_path.read_text().splitlines():
        line = line.strip()
        if line and not line.startswith("#") and "=" in line:
            key, _, value = line.partition("=")
            os.environ.setdefault(key.strip(), value.strip())

# Server
HOST = "127.0.0.1"
PORT = 8888

# UnrealSpeech
UNREALSPEECH_API_KEY = os.environ.get("UNREALSPEECH_API_KEY", "")
UNREALSPEECH_VOICE_ID = os.environ.get("UNREALSPEECH_VOICE_ID", "am_onyx")
UNREALSPEECH_BASE_URL = "https://api.v8.unrealspeech.com"

# Audio
TEMP_AUDIO_DIR = Path("/tmp/pai-voice")
TEMP_AUDIO_DIR.mkdir(parents=True, exist_ok=True)

# Rate limiting
RATE_LIMIT_PER_MINUTE = 30
