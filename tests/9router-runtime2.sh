#!/bin/bash
# Uji startup 9Router versi valid: node custom-server.js --port <SERVER_PORT>
SC=/root/.jcode/scratch/router-test
docker rm -f router9 >/dev/null 2>&1
docker run -d --name router9 -v "$SC":/home/container \
  -e SERVER_PORT=20127 \
  -e STARTUP='node custom-server.js --port ${SERVER_PORT}' \
  -p 3102:20127 ghcr.io/santainetwork/image-hub:node22-root >/dev/null
CODE=000
for i in $(seq 1 15); do
  sleep 4
  CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3102/)
  ST=$(docker inspect -f '{{.State.Status}}' router9)
  echo "t=$((i*4))s http=$CODE state=$ST"
  [ "$CODE" != "000" ] && break
  [ "$ST" != "running" ] && break
done
echo "--- log tail:"
docker logs router9 2>&1 | tail -12
S=$(date +%s%N); docker stop router9 >/dev/null; E=$(date +%s%N)
python3 -c "print(f'STOP_SECONDS={($E-$S)/1e9:.2f}')"
docker rm router9 >/dev/null
