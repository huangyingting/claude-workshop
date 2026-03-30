#!/bin/bash
cd "$(dirname "$0")"

case "$1" in
  start)
    echo "Starting LiteLLM proxy (Docker)..."
    docker compose up -d
    ;;
  stop)
    echo "Stopping LiteLLM proxy..."
    docker compose down
    ;;
  restart)
    echo "Restarting LiteLLM proxy..."
    docker compose restart
    ;;
  status)
    docker compose ps
    ;;
  log)
    docker compose logs -f
    ;;
  pull)
    echo "Pulling latest litellm/litellm image..."
    docker compose pull
    ;;
  *)
    echo "Usage: $0 {start|stop|restart|status|log|pull}"
    exit 1
    ;;
esac
