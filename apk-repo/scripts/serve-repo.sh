#!/bin/sh
# NegativeOS APK Repo — Simple HTTP Server
# For local testing or self-hosting on a LAN
# For production: put the repo behind nginx/caddy

REPO_DIR="$(dirname "$(dirname "$(realpath "$0")")")"
PORT="${1:-8080}"
BIND="${2:-0.0.0.0}"

echo "[apk-repo] Serving NegativeOS repository..."
echo "  URL  : http://$(hostname -I | awk '{print $1}'):${PORT}"
echo "  Path : ${REPO_DIR}"
echo ""
echo "On a NegativeOS client add this repo:"
echo "  apk add --repository http://$(hostname -I | awk '{print $1}'):${PORT} <package>"
echo ""
echo "Or permanently in /etc/apk/repositories:"
echo "  echo 'http://$(hostname -I | awk '{print $1}'):${PORT}' >> /etc/apk/repositories"
echo ""
echo "Press Ctrl+C to stop."

cd "${REPO_DIR}" && python3 -m http.server "${PORT}" --bind "${BIND}"
