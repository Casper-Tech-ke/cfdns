#!/usr/bin/env bash
set -e
RAW="https://raw.githubusercontent.com/Casper-Tech-ke/cfdns/main"

echo "Installing cfdns..."
apt-get install -y jq curl >/dev/null 2>&1 || true
curl -fsSL "$RAW/cfdns" -o /usr/local/bin/cfdns
chmod +x /usr/local/bin/cfdns

echo ""
echo "Now let's connect your Cloudflare account."
read -rp "Paste your Cloudflare API token: " TOKEN < /dev/tty
read -rp "Paste your Cloudflare Zone ID: " ZONEID < /dev/tty

printf "CLOUDFLARE_API_TOKEN=%s\nCLOUDFLARE_ZONE_ID=%s\n" "$TOKEN" "$ZONEID" > /root/.cfdns.env
chmod 600 /root/.cfdns.env

echo ""
echo "Saved. Verifying connection..."
cfdns verify
echo ""
echo "All set! Try: cfdns list"
