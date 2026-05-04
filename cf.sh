#!/usr/bin/env bash

set -euo pipefail

# Install Cloudflare Tunnel (cloudflared).
mkdir -p --mode=0755 /usr/share/keyrings
curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg \
	| gpg --dearmor \
	> /usr/share/keyrings/cloudflare-main.gpg
echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared any main' \
	> /etc/apt/sources.list.d/cloudflared.list
apt-get update
apt-get install -y --no-install-recommends cloudflared