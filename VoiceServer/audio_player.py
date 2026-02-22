"""Audio playback for Windows via mpv."""

import asyncio
import logging
from pathlib import Path

logger = logging.getLogger("audio-player")


async def play_audio(
    audio_path: Path | str,
    volume: float = 1.0,
    delete_after: bool = True,
) -> bool:
    """Play audio through mpv (works on Windows)."""
    audio_path = Path(audio_path)

    if not audio_path.exists():
        logger.error(f"Audio file not found: {audio_path}")
        return False

    # mpv volume is 0-100
    mpv_vol = int(volume * 100)
    logger.info(f"Playing: {audio_path} (vol={mpv_vol})")

    try:
        process = await asyncio.create_subprocess_exec(
            "mpv", "--no-video", "--really-quiet",
            f"--volume={mpv_vol}",
            str(audio_path),
            stdout=asyncio.subprocess.DEVNULL,
            stderr=asyncio.subprocess.DEVNULL,
        )
        await asyncio.wait_for(process.communicate(), timeout=30)

        success = process.returncode == 0
        if success:
            logger.info("Playback complete")
        else:
            logger.error(f"mpv exited with code {process.returncode}")
        return success

    except asyncio.TimeoutError:
        logger.error("Playback timed out (30s)")
        return False
    except FileNotFoundError:
        logger.error("mpv not found — install with: sudo apt install mpv")
        return False
    except Exception as e:
        logger.error(f"Playback error: {e}")
        return False
    finally:
        if delete_after and audio_path.exists():
            try:
                audio_path.unlink()
            except Exception:
                pass
