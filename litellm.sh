#!/bin/bash
PIDFILE="/home/ythuang/workspace/claude-workshop/.litellm.pid"
LOGFILE="/home/ythuang/workspace/claude-workshop/litellm.log"
CONFIG="/home/ythuang/workspace/claude-workshop/litellm_config.yaml"
PORT=4000

case "$1" in
  start)
    if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
      echo "LiteLLM is already running (PID $(cat "$PIDFILE"))"
      exit 1
    fi
    echo "Starting LiteLLM on port $PORT..."
    cd /home/ythuang/workspace/claude-workshop
    nohup uv run litellm --config "$CONFIG" --port "$PORT" > "$LOGFILE" 2>&1 &
    echo $! > "$PIDFILE"
    echo "LiteLLM started (PID $!), log: $LOGFILE"
    ;;
  stop)
    if [ -f "$PIDFILE" ]; then
      PID=$(cat "$PIDFILE")
      if kill -0 "$PID" 2>/dev/null; then
        echo "Stopping LiteLLM (PID $PID)..."
        kill "$PID"
        rm -f "$PIDFILE"
        echo "Stopped."
      else
        echo "Process $PID not running, cleaning up."
        rm -f "$PIDFILE"
      fi
    else
      echo "No PID file found. LiteLLM may not be running."
    fi
    ;;
  status)
    if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
      echo "LiteLLM is running (PID $(cat "$PIDFILE"))"
    else
      echo "LiteLLM is not running."
    fi
    ;;
  log)
    tail -f "$LOGFILE"
    ;;
  *)
    echo "Usage: $0 {start|stop|status|log}"
    exit 1
    ;;
esac
