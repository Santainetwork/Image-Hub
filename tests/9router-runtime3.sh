#!/bin/bash
# Apakah 9Router membaca PORT dari .env (config parser Wings) tanpa --port?
SC=/root/.jcode/scratch/router-test
docker rm -f router9 >/dev/null 2>&1
docker run -d --name router9 -v "$SC":/home/container \
  -e SERVER_PORT=20127 -e STARTUP='node custom-server.js' \
  -p 3102:20127 ghcr.io/santainetwork/image-hub:node22-root >/dev/null
CODE=000
for i in $(seq 1 8); do
  sleep 4
  CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3102/)
  ST=$(docker inspect -f '{{.State.Status}}' router9)
  echo "t=$((i*4))s http=$CODE state=$ST"
  [ "$CODE" != "000" ] && break
  [ "$ST" != "running" ] && break
done
echo "--- log (port yang didengar):"
docker logs router9 2>&1 | grep -E "Local:|Ready|Error|error" | head -5
docker rm -f router9 >/dev/null
