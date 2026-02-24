"""Audio playback for Windows via ffplay (fallback: mpv)."""

import asyncio
import logging
import shutil
from pathlib import Path

logger = logging.getLogger("audio-player")


def _find_player() -> tuple[str, str]:
    """Find the best available audio player. Returns (name, path)."""
    for name in ("ffplay", "mpv"):
        path = shutil.which(name)
        if path:
            return name, path
    return "", ""


async def play_audio(
    audio_path: Path | str,
    volume: float = 1.0,
    delete_after: bool = True,
) -> bool:
    """Play audio through ffplay or mpv (Windows)."""
    audio_path = Path(audio_path)

    if not audio_path.exists():
        logger.error(f"Audio file not found: {audio_path}")
        return False

    player_name, player_path = _find_player()
    if not player_name:
        logger.error("No audio player found — install ffmpeg (for ffplay) or mpv")
        return False

    logger.info(f"Playing: {audio_path} via {player_name} (vol={volume})")

    try:
        if player_name == "ffplay":
            # ffplay volume is 0-1 float
            cmd = [
                player_path, "-nodisp", "-autoexit", "-loglevel", "quiet",
                "-volume", str(int(volume * 100)),
                str(audio_path),
            ]
        else:
            # mpv volume is 0-100
            cmd = [
                player_path, "--no-video", "--really-quiet",
                f"--volume={int(volume * 100)}",
                str(audio_path),
            ]

        process = await asyncio.create_subprocess_exec(
            *cmd,
            stdout=asyncio.subprocess.DEVNULL,
            stderr=asyncio.subprocess.DEVNULL,
        )
        await asyncio.wait_for(process.communicate(), timeout=30)

        success = process.returncode == 0
        if success:
            logger.info("Playback complete")
        else:
            logger.error(f"{player_name} exited with code {process.returncode}")
        return success

    except asyncio.TimeoutError:
        logger.error("Playback timed out (30s)")
        return False
    except FileNotFoundError:
        logger.error(f"{player_name} not found on PATH")
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
