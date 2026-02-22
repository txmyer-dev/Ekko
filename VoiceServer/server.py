"""ElevenLabs Voice Server — Lightweight FastAPI proxy for PAI on Windows."""

import logging
import time
import uuid
from collections import defaultdict
from pathlib import Path
from typing import Optional

import httpx
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse

import config
from audio_player import play_audio

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(message)s",
)
logger = logging.getLogger("voice-server")

app = FastAPI(title="PAI Voice Server", version="2.0.0")

# Rate limiting
_req_counts: dict[str, dict] = defaultdict(lambda: {"count": 0, "reset": 0.0})


@app.middleware("http")
async def rate_limit(request: Request, call_next):
    ip = request.client.host if request.client else "unknown"
    now = time.time()
    rec = _req_counts[ip]
    if now > rec["reset"]:
        rec["count"] = 0
        rec["reset"] = now + 60
    rec["count"] += 1
    if rec["count"] > config.RATE_LIMIT_PER_MINUTE:
        return JSONResponse(status_code=429, content={"error": "Rate limit exceeded"})
    return await call_next(request)


# ── Health ────────────────────────────────────────────────────────────
@app.get("/health")
async def health():
    has_key = bool(config.ELEVENLABS_API_KEY)
    return {
        "status": "ok" if has_key else "missing_api_key",
        "engine": "elevenlabs",
        "port": config.PORT,
        "voice_id": config.ELEVENLABS_VOICE_ID,
    }


# ── Notify ────────────────────────────────────────────────────────────
@app.post("/notify")
async def notify(request: Request):
    body = await request.json()

    message = body.get("message", "")
    if not message:
        return {"status": "error", "message": "No message provided"}

    voice_enabled = body.get("voice_enabled", True)
    if not voice_enabled:
        return {"status": "success", "message": "Voice disabled", "engine": "elevenlabs"}

    voice_id = body.get("voice_id") or config.ELEVENLABS_VOICE_ID
    voice_settings = body.get("voice_settings", {})

    # Build ElevenLabs request
    url = f"{config.ELEVENLABS_BASE_URL}/text-to-speech/{voice_id}"
    headers = {
        "xi-api-key": config.ELEVENLABS_API_KEY,
        "Content-Type": "application/json",
        "Accept": "audio/mpeg",
    }
    payload: dict = {
        "text": message[:1000],
        "model_id": config.ELEVENLABS_MODEL_ID,
    }

    # Pass through voice_settings from hooks
    if voice_settings:
        vs: dict = {}
        if "stability" in voice_settings:
            vs["stability"] = float(voice_settings["stability"])
        if "similarity_boost" in voice_settings:
            vs["similarity_boost"] = float(voice_settings["similarity_boost"])
        if "style" in voice_settings:
            vs["style"] = float(voice_settings["style"])
        if "use_speaker_boost" in voice_settings:
            vs["use_speaker_boost"] = bool(voice_settings["use_speaker_boost"])
        if vs:
            payload["voice_settings"] = vs

    # Optional speed parameter (ElevenLabs supports it at top level in some models)
    speed = voice_settings.get("speed") if voice_settings else None
    if speed is not None:
        payload["speed"] = float(speed)

    logger.info(f"TTS: '{message[:60]}...' voice={voice_id}")

    try:
        async with httpx.AsyncClient(timeout=30.0) as client:
            resp = await client.post(url, headers=headers, json=payload)

        if resp.status_code != 200:
            error_detail = resp.text[:200]
            logger.error(f"ElevenLabs API error {resp.status_code}: {error_detail}")
            return {
                "status": "error",
                "message": f"ElevenLabs API returned {resp.status_code}",
                "engine": "elevenlabs",
                "error": error_detail,
            }

        # Save MP3 to temp file
        audio_path = config.TEMP_AUDIO_DIR / f"voice-{uuid.uuid4().hex[:8]}.mp3"
        audio_path.write_bytes(resp.content)
        logger.info(f"Saved {len(resp.content)} bytes to {audio_path}")

        # Play audio
        volume = body.get("volume", 1.0)
        played = await play_audio(audio_path, volume=volume)

        return {
            "status": "success",
            "message": "Notification sent",
            "engine": "elevenlabs",
            "played": played,
        }

    except httpx.TimeoutException:
        logger.error("ElevenLabs API timeout")
        return {"status": "error", "message": "API timeout", "engine": "elevenlabs"}
    except Exception as e:
        logger.error(f"Notify failed: {e}")
        return {"status": "error", "message": str(e), "engine": "elevenlabs"}


# ── Run ───────────────────────────────────────────────────────────────
if __name__ == "__main__":
    import uvicorn

    uvicorn.run("server:app", host=config.HOST, port=config.PORT, log_level="info")
