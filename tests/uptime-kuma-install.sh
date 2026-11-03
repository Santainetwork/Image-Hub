#!/bin/ash
# Uptime Kuma App Installation Script
#
# Server Files: /mnt/server
apk update
apk add --no-cache git curl jq file unzip make gcc g++ python3 python3-dev libtool
apk add --no-cache git-lfs --repository=https://dl-cdn.alpinelinux.org/alpine/latest-stable/community

## npm update to latest
echo -e "Updating npm to latest....\n"
if [ -d "/mnt/server/node_modules" ]; then
    rm -fR /mnt/server/node_modules
    npm cache verify
fi
npm install -g npm@latest

## Uptime Kuma install & update
mkdir -p /mnt/server
cd /mnt/server
git config --global --add safe.directory /mnt/server
if [ -d .git ]; then
    echo -e "Updating Uptime Kuma....\n "
    npm run setup
else
    echo -e "Download and installing Uptime Kuma...\n"
    git clone https://github.com/louislam/uptime-kuma.git .
    npm run setup
fi

## only create dir, when .git is present to prevent errors
if [ -d .git ]; then
    mkdir -p /mnt/server/data
fi
if [ ! -f "/mnt/server/data/kuma.db" ]; then
    cp /mnt/server/db/kuma.db /mnt/server/data/kuma.db
fi

## install end
echo -e "-----------------------------------------"
echo -e "Installation completed..."
echo -e "-----------------------------------------"
exit 0
