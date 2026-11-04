#!/bin/bash
# Runtime test untuk hasil install egg v2 (non-root, STARTUP={{STARTUP_CMD}} -> bash run.sh)
SC2=/root/.jcode/scratch/router-v2
echo "--- .env:"; cat "$SC2/.env" 2>&1
echo "--- run.sh (baris exec):"; grep -E "exec|Starting" "$SC2/run.sh"
docker rm -f router9 >/dev/null 2>&1
docker run -d --name router9 -v "$SC2":/home/container \
  -e SERVER_PORT=20127 -e AUTO_UPDATE=0 -e FORCE_INSTALL=0 \
  -e STARTUP_CMD='bash run.sh' -e STARTUP='{{STARTUP_CMD}}' \
  -p 3102:20127 ghcr.io/santainetwork/image-hub:node22 >/dev/null
CODE=000
for i in $(seq 1 15); do
  sleep 4
  CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3102/)
  ST=$(docker inspect -f '{{.State.Status}}' router9)
  echo "t=$((i*4))s http=$CODE state=$ST uid=$(docker exec router9 id -u 2>/dev/null)"
  [ "$CODE" != "000" ] && break
  [ "$ST" != "running" ] && break
done
echo "--- log:"
docker logs router9 2>&1 | grep -E "9router|Ready|Local:|error|Error" | head -8
S=$(date +%s%N); docker stop router9 >/dev/null; E=$(date +%s%N)
python3 -c "print(f'STOP_SECONDS={($E-$S)/1e9:.2f}')"
docker rm router9 >/dev/null
