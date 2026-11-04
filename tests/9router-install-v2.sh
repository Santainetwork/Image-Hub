#!/bin/sh
# 9Router Installation Script for Pterodactyl / Pelican (image-hub)
set -e

apk update
apk add --no-cache git curl jq file unzip make gcc g++ python3 linux-headers bash

mkdir -p /mnt/server
cd /mnt/server

# Reinstall berjalan sebagai root; .git bisa milik uid 1000 dari install sebelumnya
# (git menolak "dubious ownership"). Daftarkan agar aman.
git config --global --add safe.directory /mnt/server 2>/dev/null || true

if [ "${USER_UPLOAD}" = "true" ] || [ "${USER_UPLOAD}" = "1" ]; then
    echo "User upload mode: skipping git clone."
elif [ -d .git ]; then
    echo ".git exists, updating repo..."
    git fetch --all
    git reset --hard origin/${BRANCH}
elif [ -z "$(ls -A .)" ]; then
    echo "Cloning 9Router repository (${BRANCH})..."
    git clone --single-branch --branch ${BRANCH} ${GIT_ADDRESS} .
else
    echo "Folder berisi file tapi bukan git repo: sinkronisasi ke upstream (${BRANCH})..."
    git init -q .
    git remote add origin ${GIT_ADDRESS} 2>/dev/null || git remote set-url origin ${GIT_ADDRESS}
    git fetch --depth=1 origin ${BRANCH}
    git checkout -f -B ${BRANCH} FETCH_HEAD
fi

mkdir -p /mnt/server/data /mnt/server/data/db

echo "Installing npm dependencies..."
npm install

echo "Building Next.js production build..."
npm run build

echo "Generating startup runner script (run.sh)..."
cat << 'EOF' > /mnt/server/run.sh
#!/bin/bash
set -e
cd /home/container

if [[ -d .git ]] && [[ "${AUTO_UPDATE}" == "1" ]]; then
  echo "[9router] Checking for updates from git..."
  git pull
fi
if [[ ! -d "node_modules/next" ]] || [[ "${FORCE_INSTALL}" == "1" ]]; then
  echo "[9router] Installing node modules..."
  npm install --production=false
fi
if [[ ! -f ".next/BUILD_ID" ]] || [[ "${AUTO_UPDATE}" == "1" ]]; then
  echo "[9router] Building Next.js application (bisa 2-4 menit)..."
  npm run build
fi

export PORT="${SERVER_PORT:-20128}"
export GATEWAY_PORT="${SERVER_PORT:-20128}"
export DATA_DIR="${DATA_DIR:-./data}"
export NODE_ENV=production

echo "[9router] Starting on port ${PORT}..."
exec node custom-server.js --port "${PORT}"
EOF

chmod +x /mnt/server/run.sh

if [ ! -f /mnt/server/.env ]; then
    cat << 'EOF' > /mnt/server/.env
PORT=20128
GATEWAY_PORT=20128
DATA_DIR=./data
NODE_ENV=production
INITIAL_PASSWORD=123456
EOF
fi

# Samakan ownership ke user container (uid 1000) supaya runtime non-root bisa baca/tulis
chown -R 1000:1000 /mnt/server

echo "9Router installation completed successfully."
exit 0