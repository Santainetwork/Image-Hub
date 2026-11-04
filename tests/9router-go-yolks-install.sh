#!/bin/sh
# 9router-go installer (yolks debian, glibc native - binary langsung jalan)
set -e

mkdir -p /mnt/server
cd /mnt/server

if [ "${RELEASE_TAG}" = "latest" ] || [ -z "${RELEASE_TAG}" ]; then
    URL="https://github.com/${GITHUB_REPO}/releases/latest/download/9router-go-linux-amd64"
else
    URL="https://github.com/${GITHUB_REPO}/releases/download/${RELEASE_TAG}/9router-go-linux-amd64"
fi

echo "Downloading 9router-go (${RELEASE_TAG})..."
curl -fsSL -o 9router-go.tmp "$URL"
chmod +x 9router-go.tmp
mv 9router-go.tmp 9router-go
./9router-go --help >/dev/null 2>&1 || { echo "Binary gagal dieksekusi"; exit 1; }

mkdir -p data

if [ ! -f .env ]; then
    JWT=$(head -c 32 /dev/urandom | base64 | tr -d '=+/\n' | cut -c1-43)
    printf 'JWT_SECRET=%s\nINITIAL_PASSWORD=%s\nDATA_DIR=./data\nPORT=20130\n' "$JWT" "${INITIAL_PASSWORD}" > .env
fi

# Runner: stdin diarahkan ke /dev/null supaya binary tidak membuka menu interaktif di TTY panel
printf '#!/bin/bash\nexec ./9router-go < /dev/null\n' > start.sh
chmod +x start.sh

echo "9router-go installation completed successfully."
exit 0