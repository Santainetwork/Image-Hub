#!/bin/bash
# Egg 9router-go versi YOLKS (ghcr.io/parkervcp/yolks:debian)
set -u
IMG=ghcr.io/parkervcp/yolks:debian
SC=/root/.jcode/scratch/go9r-yolks
rm -rf "$SC" 2>/dev/null
mkdir -p "$SC"

echo "=== 1) STARTUP sederhana di yolks ==="
docker run --rm -e STARTUP='echo STARTUP-OK' -e HOME=/home/container "$IMG" 2>&1 | tail -2

echo "=== 2) install script (download binary + .env + start.sh) ==="
docker run --rm -v "$SC":/mnt/server -e RELEASE_TAG=latest -e GITHUB_REPO=luqman-v1/9router-go -e INITIAL_PASSWORD=abc123 \
  "$IMG" sh -c '
set -e
mkdir -p /mnt/server && cd /mnt/server
URL="https://github.com/${GITHUB_REPO}/releases/latest/download/9router-go-linux-amd64"
curl -fsSL -o 9router-go.tmp "$URL"
chmod +x 9router-go.tmp && mv 9router-go.tmp 9router-go
./9router-go --help >/dev/null 2>&1 && echo BINARY-OK
mkdir -p data
JWT=$(head -c 32 /dev/urandom | base64 | tr -d "=+/\n" | cut -c1-43)
printf "JWT_SECRET=%s\nINITIAL_PASSWORD=%s\nDATA_DIR=./data\nPORT=20130\n" "$JWT" "$INITIAL_PASSWORD" > .env
printf "#!/bin/bash\nexec ./9router-go < /dev/null\n" > start.sh
chmod +x start.sh
echo INSTALL-OK'
ls -la "$SC" | head -6

echo "=== 3) runtime yolks, STARTUP=./start.sh, TTY ==="
sed -i 's/^PORT=20130$/PORT=20127/' "$SC/.env"
docker rm -f go9r-y >/dev/null 2>&1
docker run -dt --name go9r-y -v "$SC":/home/container -e STARTUP='./start.sh' \
  -e SERVER_PORT=20127 -p 3108:20127 "$IMG" >/dev/null
CODE=000
for i in $(seq 1 10); do
  sleep 3
  CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3108/)
  ST=$(docker inspect -f '{{.State.Status}}' go9r-y)
  echo "t=$((i*3))s http=$CODE state=$ST"
  [ "$CODE" != "000" ] && break
  [ "$ST" != "running" ] && break
done
docker logs go9r-y 2>&1 | grep -E "Proxy \(|ready to handle|error" | head -3
S=$(date +%s%N); docker stop go9r-y >/dev/null; E=$(date +%s%N)
python3 -c "print(f'STOP_SECONDS={($E-$S)/1e9:.2f}')"
docker rm go9r-y >/dev/null
