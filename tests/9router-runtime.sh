#!/bin/bash
# Uji runtime 9Router persis alur Wings: config parser tulis .env, STARTUP_CMD default
SC=/root/.jcode/scratch/router-test
printf 'PORT=20127\nGATEWAY_PORT=20127\nDATA_DIR=./data\nNODE_ENV=production\nINITIAL_PASSWORD=123456\n' > "$SC/.env"
docker rm -f router9 >/dev/null 2>&1
docker run -d --name router9 -v "$SC":/home/container \
  -e SERVER_PORT=20127 \
  -e STARTUP='node custom-server.js --no-browser --log --skip-update' \
  -p 3102:20127 ghcr.io/santainetwork/image-hub:node22-root >/dev/null
CODE=000
for i in 1 2 3 4 5 6 7 8 9 10; do
  sleep 6
  CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3102/)
  ST=$(docker inspect -f '{{.State.Status}}' router9)
  echo "t=$((i*6))s http=$CODE state=$ST"
  [ "$CODE" != "000" ] && break
  [ "$ST" != "running" ] && break
done
echo "--- log tail:"
docker logs router9 2>&1 | tail -15
S=$(date +%s%N); docker stop router9 >/dev/null; E=$(date +%s%N)
python3 -c "print(f'STOP_SECONDS={($E-$S)/1e9:.2f}')"
docker rm router9 >/dev/null
