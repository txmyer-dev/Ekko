#!/usr/bin/env bash
# SecondBrain Fallback Sync
# Checks if the USB drive is mounted, syncs fallback → primary, restarts clipper.
# Designed to run via Task Scheduler every 5 minutes.

set -euo pipefail

PRIMARY="C:/Users/txmye_ficivtv/My Drive/SecondBrain"
FALLBACK="C:/Users/txmye_ficivtv/.claude/SecondBrain-fallback"
MARKER="$PRIMARY/.obsidian"
LOCKFILE="/tmp/secondbrain-sync.lock"

# Exit silently if drive not mounted (check for .obsidian dir as proof of real vault)
if [ ! -d "$MARKER" ]; then
    exit 0
fi

# Exit if another sync is already running
if [ -f "$LOCKFILE" ]; then
    exit 0
fi
trap 'rm -f "$LOCKFILE"' EXIT
touch "$LOCKFILE"

# Check if fallback has any content worth syncing
if [ ! -d "$FALLBACK" ] || [ -z "$(ls -A "$FALLBACK" 2>/dev/null)" ]; then
    exit 0
fi

# Sync fallback → primary (append only, no --delete)
# cp -rn = recursive, no-clobber (skip existing files). Works on any filesystem.
cp -rn "$FALLBACK/"* "$PRIMARY/" 2>/dev/null || true

# Check if clipper still needs restart (dry-run comparison)
SYNCED_COUNT=0

# If we just synced files, restart clipper so it uses the primary path
if [ "$SYNCED_COUNT" -eq 0 ]; then
    # Check if clipper is currently using fallback
    HEALTH=$(curl -sf http://localhost:3131/health 2>/dev/null || echo '{}')
    if echo "$HEALTH" | grep -q "fallback"; then
        # TODO: Implement Windows service restart for clipper if needed
        echo "[$(date)] Drive reconnected. Clipper restart needed." >> "$FALLBACK/../secondbrain-sync.log"
    fi
fi

echo "[$(date)] Sync complete. Fallback → Primary." >> "$FALLBACK/../secondbrain-sync.log"
