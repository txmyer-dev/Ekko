#!/bin/bash
# Stop PAI Voice Server

PID_FILE="/tmp/pai-voice-server.pid"
PORT=8888

echo "Stopping PAI Voice Server..."

# Kill by PID file
if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if kill -0 "$PID" 2>/dev/null; then
        kill "$PID" 2>/dev/null
        sleep 1
        # Force kill if still running
        kill -0 "$PID" 2>/dev/null && kill -9 "$PID" 2>/dev/null
        echo "Killed server (PID $PID)"
    fi
    rm -f "$PID_FILE"
fi

# Also kill anything on the port
PIDS=$(ss -tlnp 2>/dev/null | grep ":$PORT " | grep -oP 'pid=\K[0-9]+' | sort -u)
if [ -n "$PIDS" ]; then
    echo "$PIDS" | xargs kill 2>/dev/null
    sleep 1
    echo "$PIDS" | xargs kill -9 2>/dev/null
    echo "Killed remaining processes on port $PORT"
fi

echo "Server stopped."
