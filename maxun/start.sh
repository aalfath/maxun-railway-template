#!/bin/bash
# Starts the Maxun backend on 127.0.0.1:8081 and Caddy on $PORT (UI + API on one origin).
set -euo pipefail

: "${PUBLIC_URL:?PUBLIC_URL is required (https://your-domain)}"
PUBLIC_URL="${PUBLIC_URL%/}"
export PUBLIC_URL
export PORT="${PORT:-8080}"
export BACKEND_PORT=8081
export BACKEND_URL="${BACKEND_URL:-$PUBLIC_URL}"
export VITE_PUBLIC_URL="${VITE_PUBLIC_URL:-$PUBLIC_URL}"
export VITE_BACKEND_URL="${VITE_BACKEND_URL:-$PUBLIC_URL}"
# Screenshots are served through this service's /maxun-run-screenshots/ route.
export MINIO_PUBLIC_URL="${MINIO_PUBLIC_URL:-$PUBLIC_URL}"
export MINIO_PORT="${MINIO_PORT:-9000}"
export BROWSER_WS_PORT="${BROWSER_WS_PORT:-3001}"
export BROWSER_HEALTH_PORT="${BROWSER_HEALTH_PORT:-3002}"
export DB_PORT="${DB_PORT:-5432}"
export MAXUN_TELEMETRY="${MAXUN_TELEMETRY:-false}"
export STORAGE_UPSTREAM="${MINIO_ENDPOINT:?MINIO_ENDPOINT is required}:${MINIO_PORT}"

for v in DB_HOST DB_NAME DB_USER DB_PASSWORD JWT_SECRET ENCRYPTION_KEY SESSION_SECRET MINIO_ACCESS_KEY MINIO_SECRET_KEY BROWSER_WS_HOST; do
  if [ -z "${!v:-}" ]; then echo "start.sh: $v is required" >&2; exit 1; fi
done

cd /app
node --max-old-space-size="${MAXUN_NODE_MEMORY_MB:-4096}" server/dist/server/src/server.js &
BACKEND_PID=$!
caddy run --config /etc/maxun/Caddyfile --adapter caddyfile &
CADDY_PID=$!

STOPPING=0
trap 'STOPPING=1; kill -TERM $BACKEND_PID $CADDY_PID 2>/dev/null || true' TERM INT
# Exit non-zero (so Railway restarts the service) as soon as either process stops.
set +e
wait -n $BACKEND_PID $CADDY_PID
STATUS=$?
kill -TERM $BACKEND_PID $CADDY_PID 2>/dev/null
wait
if [ "$STOPPING" = 1 ]; then exit 0; fi
echo "start.sh: a process exited (status $STATUS), stopping so the service restarts" >&2
exit $(( STATUS == 0 ? 1 : STATUS ))
