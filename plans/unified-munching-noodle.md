# Plan: ElevenLabs Voice Server for Windows

## Context

The v2.5 reinstall today brought a Qwen3-TTS voice server designed for macOS (`afplay` for audio, `launchctl` for services, 7GB local model). This doesn't work on Windows natively. Tony hasn't heard Ekko's voice in hours because the server isn't running and can't start.

The hooks (VoiceNotification.ts, SystemIntegrity.ts, StartupGreeting.hook.ts) already send **ElevenLabs-compatible payloads** to `localhost:8888/notify` — they include `voice_id`, `voice_settings` (stability, similarity_boost, style, speed). Tony's ElevenLabs API key is valid (Starter tier, 38K chars/mo).

**Goal:** Replace the Qwen3-TTS server with a lightweight ElevenLabs proxy server that works on Windows.

## Files to Modify

| File | Action | Purpose |
|------|--------|---------|
| `~/.claude/VoiceServer/server.py` | **Replace** | Lightweight FastAPI server with ElevenLabs TTS |
| `~/.claude/VoiceServer/audio_player.py` | **Replace** | PowerShell-based audio playback for Windows |
| `~/.claude/VoiceServer/config.py` | **Replace** | Simple ElevenLabs config (reads from .env) |
| `~/.claude/VoiceServer/pyproject.toml` | **Replace** | Minimal deps: fastapi, uvicorn, httpx |
| `~/.claude/VoiceServer/start.sh` | **Replace** | Windows-compatible startup (no launchctl) |
| `~/.claude/VoiceServer/stop.sh` | **Replace** | Windows-compatible stop |
| `~/.claude/VoiceServer/status.sh` | **Replace** | Windows-compatible status check |

Files to leave alone: `models.py`, `emotional_inference.py`, `personality.py`, `tts_engine.py` (unused but not harmful)

## Architecture

```
Hook POST /notify  →  FastAPI server (port 8888)
                          │
                          ├─ Extracts: message, voice_id, voice_settings
                          ├─ Calls ElevenLabs TTS API (v1/text-to-speech/{voice_id})
                          ├─ Saves MP3 to /tmp/pai-voice/
                          └─ Plays via: powershell.exe → [System.Media.SoundPlayer]
```

## Implementation Details

### 1. `config.py` — Simple config
- Read `ELEVENLABS_API_KEY` and `ELEVENLABS_VOICE_ID` from `~/.claude/.env`
- Port 8888, host 127.0.0.1
- Default voice_id: `pNInz6obpgDQGcFmaJgB` (Adam, from settings.json)

### 2. `server.py` — Lightweight FastAPI
- **GET /health** — returns status, engine: "elevenlabs"
- **POST /notify** — accepts `{message, title?, voice_id?, voice_enabled?, voice_settings?, volume?}`
  - Calls ElevenLabs API `POST /v1/text-to-speech/{voice_id}`
  - Passes voice_settings (stability, similarity_boost, style, speed, use_speaker_boost)
  - Saves response audio to temp file
  - Calls audio_player to play it
  - Returns `{status: "success", message: "...", engine: "elevenlabs"}`
- Minimal — no emotional inference, no personality system, no voice design/clone endpoints

### 3. `audio_player.py` — Windows audio playback
- Convert MP3 from ElevenLabs to WAV (using built-in Python `wave` or just play MP3 directly)
- Use `powershell.exe -Command "(New-Object Media.SoundPlayer 'path').PlaySync()"` for WAV
- Or use `powershell.exe -Command "Add-Type -AssemblyName presentationCore; $player = New-Object system.windows.media.mediaplayer; $player.Open('path'); $player.Play()"` for MP3
- Clean up temp files after playback

### 4. `start.sh` — Windows startup
- Check if already running (check PID file or port)
- `cd VoiceServer && uv run uvicorn server:app --host 127.0.0.1 --port 8888 &`
- Save PID to `/tmp/pai-voice-server.pid`
- Wait for health check

### 5. `pyproject.toml` — Minimal deps
- fastapi, uvicorn, httpx (for ElevenLabs API calls)
- No torch, no transformers, no soundfile — just HTTP

## Verification

1. Run `~/.claude/VoiceServer/start.sh` — server starts on port 8888
2. `curl http://localhost:8888/health` — returns `{"status": "ok", "engine": "elevenlabs"}`
3. `curl -X POST http://localhost:8888/notify -H "Content-Type: application/json" -d '{"message": "Discipline Equals Freedom.", "voice_id": "pNInz6obpgDQGcFmaJgB"}'` — audio plays through Windows speakers
4. Next response from Ekko should be audible via the hook pipeline
