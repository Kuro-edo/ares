#!/bin/sh
# Runs on the server as root from /opt/ares after the workflow copies the files.
set -eu
cd /opt/ares

if ! command -v docker >/dev/null || ! command -v nginx >/dev/null; then
  apt-get update
  apt-get install -y nginx docker.io docker-compose-v2
fi

# Earlier deploys ran the backend under systemd and the web page as compose
# project "web"; both hold the ports the containers need.
if [ -f /etc/systemd/system/ares.service ]; then
  systemctl disable --now ares
  rm /etc/systemd/system/ares.service
  systemctl daemon-reload
fi
docker rm -f web-web-1 2>/dev/null || true

mkdir -p /var/lib/ares
docker compose up -d --build --remove-orphans

install -m 644 deploy/ares-nginx.conf /etc/nginx/sites-available/ares
ln -sf /etc/nginx/sites-available/ares /etc/nginx/sites-enabled/ares
rm -f /etc/nginx/sites-enabled/default
nginx -t
systemctl reload nginx

for url in http://127.0.0.1:8000/health http://127.0.0.1:8080/; do
  curl -fsS --retry 10 --retry-delay 2 --retry-all-errors -o /dev/null "$url"
  echo "OK $url"
done
