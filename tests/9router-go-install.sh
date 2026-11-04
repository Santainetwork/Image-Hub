#!/bin/sh
# 9router-go Installation Script (single Go binary, image-hub)
set -e

mkdir -p /mnt/server
cd /mnt/server

if [ "${RELEASE_TAG}" = "latest" ] || [ -z "${RELEASE_TAG}" ]; then
    URL="https://github.com/${GITHUB_REPO}/releases/latest/download/9router-go-linux-amd64"
else
    URL="https://github.com/${GITHUB_REPO}/releases/download/${RELEASE_TAG}/9router-go-linux-amd64"
fi

echo "Downloading 9router-go (${RELEASE_TAG}) from ${URL}..."
curl -fsSL -o 9router-go.tmp "$URL"
chmod +x 9router-go.tmp
mv 9router-go.tmp 9router-go
./9router-go --help >/dev/null 2>&1 || { echo "Binary tidak bisa dieksekusi"; exit 1; }

mkdir -p data

if [ ! -f .env ]; then
    JWT=$(head -c 32 /dev/urandom | base64 | tr -d '=+/\n' | cut -c1-43)
    cat > .env <<EOF
JWT_SECRET=${JWT}
INITIAL_PASSWORD=${INITIAL_PASSWORD}
DATA_DIR=./data
PORT=20130
EOF
fi

# Konsisten dengan runtime non-root (konvensi yolks)
chown -R 1000:1000 /mnt/server

echo "9router-go installation completed successfully."
exit 0