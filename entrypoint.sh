#!/usr/bin/env bash
# Script to run qdrant in docker container and handle contingencies, like OOM.
# The functioning logic is as follows:
# - If recovery mode is allowed, we check if qdrant was killed during initialization or not.
#   - If it was killed during initialization, we remove run qdrant in recovery mode
#   - If it was killed after initialization, do nothing and restart container
# - If recovery mode is not allowed, we just restart container

if [ -n "${CF_TUNNEL_TOKEN:-}" ]; then
  cloudflared tunnel run --token "$CF_TUNNEL_TOKEN" > /dev/null 2>&1 &
else
  echo "CF_TUNNEL_TOKEN is NOT set"
fi

_term () {
  kill -TERM "$QDRANT_PID" 2>/dev/null
}

trap _term SIGTERM

_interrupt () {
  kill -INT "$QDRANT_PID" 2>/dev/null
}

trap _interrupt SIGINT

./qdrant $@ &
