#!/usr/bin/env bash
set -e
RAW="https://raw.githubusercontent.com/Casper-Tech-ke/cfdns/main"

if [ -t 1 ]; then
  N='\033[0m'; C='\033[1;36m'; G='\033[1;32m'; R='\033[1;31m'
  Y='\033[1;33m'; M='\033[1;35m'; W='\033[1;37m'; D='\033[0;90m'
else N=;C=;G=;R=;Y=;M=;W=;D=; fi
BW=38
row() { local t="$1" s="${2:-$1}" l; l=$(( (BW-${#t})/2 )); printf "%*s%b\n" "$l" "" "$s"; }
banner() {
  local bar; bar=$(printf '═%.0s' $(seq 1 $BW))
  printf "${C}%s${N}\n" "$bar"
  row "CLOUDFLARE DNS RECORDER" "${C}𝗖𝗟𝗢𝗨𝗗𝗙𝗟𝗔𝗥𝗘 𝗗𝗡𝗦 𝗥𝗘𝗖𝗢𝗥𝗗𝗘𝗥${N}"
  echo
  row "created & maintained by" "${D}𝘤𝘳𝘦𝘢𝘵𝘦𝘥 & 𝘮𝘢𝘪𝘯𝘵𝘢𝘪𝘯𝘦𝘥 𝘣𝘺${N}"
  row "XSPACE TECH DEVS" "${M}𝓧𝓢𝓟𝓐𝓒𝓔 𝓣𝓔𝓒𝓗 𝓓𝓔𝓥𝓢${N}"
  echo
  row "GitHub: Casper-Tech-ke" "${D}𝗚𝗶𝘁𝗛𝘂𝗯:${N} ${G}𝗖𝗮𝘀𝗽𝗲𝗿-𝗧𝗲𝗰𝗵-𝗸𝗲${N}"
  printf "${C}%s${N}\n" "$bar"
}
ok()   { printf "  ${G}✓${N} %s\n" "$1"; }
fail() { printf "  ${R}✗${N} %s\n" "$1"; exit 1; }

banner
echo

printf "${W}[1/3]${N} Installing dependencies\n"
apt-get update -qq >/dev/null 2>&1 || true
apt-get install -y -qq jq curl >/dev/null 2>&1 || fail "Could not install jq and curl"
ok "jq and curl ready"

printf "${W}[2/3]${N} Installing cfdns\n"
curl -fsSL "$RAW/cfdns" -o /usr/local/bin/cfdns || fail "Download failed"
chmod +x /usr/local/bin/cfdns
ok "Installed to /usr/local/bin/cfdns"

printf "${W}[3/3]${N} Connect your Cloudflare account\n"
read -rsp "  API token (hidden): " TOKEN < /dev/tty; echo
read -rp  "  Zone ID: " ZONEID < /dev/tty
[ -z "$TOKEN" ] || [ -z "$ZONEID" ] && fail "Token and Zone ID are both required"

printf "CLOUDFLARE_API_TOKEN=%s\nCLOUDFLARE_ZONE_ID=%s\n" "$TOKEN" "$ZONEID" > /root/.cfdns.env
chmod 600 /root/.cfdns.env
ok "Credentials saved (/root/.cfdns.env, private)"

STATUS=$(curl -s -H "Authorization: Bearer $TOKEN" https://api.cloudflare.com/client/v4/user/tokens/verify | jq -r '.result.status // empty')
[ "$STATUS" = "active" ] || fail "Token check failed. Re-run the installer with a valid token."
ZONE=$(curl -s -H "Authorization: Bearer $TOKEN" "https://api.cloudflare.com/client/v4/zones/$ZONEID" | jq -r '.result.name // empty')
[ -z "$ZONE" ] && fail "Zone ID not found. Check it and re-run."
ok "Connected to zone: $ZONE"

echo
printf "${G}All set!${N} Try:  ${C}cfdns list${N}   or   ${C}cfdns${N} for help\n"
