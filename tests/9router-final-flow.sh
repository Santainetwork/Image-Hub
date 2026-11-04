#!/bin/bash
# Uji skenario final egg 9Router:
#  1) run.sh versi BENAR (tanpa flag rusak, --port dari SERVER_PORT)
#  2) chown ke 1000 (simulasi langkah akhir install script)
#  3) runtime NON-ROOT (node22) dengan STARTUP={{STARTUP_CMD}} -> bash run.sh
SC=/root/.jcode/scratch/router-test
IMG_R=ghcr.io/santainetwork/image-hub:node22-root
IMG=ghcr.io/santainetwork/image-hub:node22

# run.sh versi perbaikan
docker run --rm -v "$SC":/mnt/server "$IMG_R" bash -c 'cat > /mnt/server/run.sh <<'"'"'EOF'"'"'
#!/bin/bash
set -e
cd /home/container

if [[ -d .git ]] && [[ "${AUTO_UPDATE}" == "1" ]]; then
  echo "[9router] Checking for updates from git..."
  git pull
fi
if [[ ! -d "node_modules" ]] || [[ "${FORCE_INSTALL}" == "1" ]]; then
  echo "[9router] Installing node modules..."
  npm install --production=false
fi
if [[ ! -d ".next" ]] || [[ "${AUTO_UPDATE}" == "1" ]]; then
  echo "[9router] Building Next.js application..."
  npm run build
fi

export PORT="${SERVER_PORT:-20128}"
export GATEWAY_PORT="${SERVER_PORT:-20128}"
export DATA_DIR="${DATA_DIR:-./data}"
export NODE_ENV=production

echo "[9router] Starting on port ${PORT}..."
exec node custom-server.js --port "${PORT}"
EOF
chmod +x /mnt/server/run.sh && chown -R 1000:1000 /mnt/server && echo "RUN.SH + CHOWN OK"'

docker rm -f router9 >/dev/null 2>&1
docker run -d --name router9 -v "$SC":/home/container \
  -e SERVER_PORT=20127 -e AUTO_UPDATE=0 -e FORCE_INSTALL=0 \
  -e STARTUP_CMD='bash run.sh' -e STARTUP='{{STARTUP_CMD}}' \
  -p 3102:20127 "$IMG" >/dev/null
CODE=000
for i in $(seq 1 15); do
  sleep 4
  CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3102/)
  ST=$(docker inspect -f '{{.State.Status}}' router9)
  echo "t=$((i*4))s http=$CODE state=$ST"
  [ "$CODE" != "000" ] && break
  [ "$ST" != "running" ] && break
done
echo "--- log:"
docker logs router9 2>&1 | grep -E "9router|Ready|Local:|Error|error" | head -8
echo "--- uid proses:"
docker exec router9 id -u 2>/dev/null || true
S=$(date +%s%N); docker stop router9 >/dev/null; E=$(date +%s%N)
python3 -c "print(f'STOP_SECONDS={($E-$S)/1e9:.2f}')"
docker rm router9 >/dev/null
