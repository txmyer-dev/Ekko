#!/bin/bash
# Start PAI Voice Server (ElevenLabs, Windows)

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PID_FILE="/tmp/pai-voice-server.pid"
PORT=8888

echo "Starting PAI Voice Server (ElevenLabs)..."

# Check if already running
if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
    echo "Server already running (PID $(cat "$PID_FILE")) on port $PORT"
    exit 0
fi

# Also check if port is in use
if ss -tlnp 2>/dev/null | grep -q ":$PORT "; then
    echo "Port $PORT already in use. Run ./stop.sh first."
    exit 1
fi

# Ensure temp dir
mkdir -p /tmp/pai-voice

cd "$SCRIPT_DIR"

# Start server in background
python3 -m uvicorn server:app --host 127.0.0.1 --port $PORT --log-level info &
SERVER_PID=$!
echo "$SERVER_PID" > "$PID_FILE"

# Wait for health check
echo "Waiting for server (PID $SERVER_PID)..."
for i in $(seq 1 10); do
    sleep 1
    if curl -s -f http://localhost:$PORT/health > /dev/null 2>&1; then
        echo ""
        echo "PAI Voice Server running on port $PORT (ElevenLabs)"
        curl -s http://localhost:$PORT/health | python3 -m json.tool 2>/dev/null
        exit 0
    fi
    printf "."
done

echo ""
echo "Server started but health check not responding yet."
echo "PID: $SERVER_PID | Check: curl http://localhost:$PORT/health"
