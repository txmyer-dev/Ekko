#!/bin/bash
# PAI Voice Server status check

PID_FILE="/tmp/pai-voice-server.pid"
PORT=8888

echo "═══════════════════════════════════"
echo "  PAI Voice Server Status"
echo "═══════════════════════════════════"

# PID check
echo ""
echo "Process:"
if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if kill -0 "$PID" 2>/dev/null; then
        echo "  Running (PID $PID)"
    else
        echo "  Stale PID file (process $PID not running)"
    fi
else
    echo "  No PID file"
fi

# Port check
echo ""
echo "Port $PORT:"
if ss -tlnp 2>/dev/null | grep -q ":$PORT "; then
    echo "  LISTENING"
else
    echo "  NOT LISTENING"
fi

# Health check
echo ""
echo "Health:"
HEALTH=$(curl -s http://localhost:$PORT/health 2>/dev/null)
if [ $? -eq 0 ]; then
    echo "  $HEALTH"
else
    echo "  UNREACHABLE"
fi

echo ""
echo "═══════════════════════════════════"
