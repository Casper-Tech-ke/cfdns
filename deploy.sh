#!/usr/bin/env bash
# Publishes the docs page, installer and command to https://cfdns.xcasper.space
set -e
cd "$(dirname "$0")"
D=/var/www/cfdns
mkdir -p "$D"
cp docs/index.html "$D/index.html"
cp install.sh "$D/install.sh"
cp install.sh "$D/install"
cp cfdns "$D/cfdns"
chmod -R a+rX "$D"
echo "Deployed to https://cfdns.xcasper.space"
