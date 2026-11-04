#!/bin/bash
# Runtime test image-hub:9router (derived dari image official) ala Wings
SC=/root/.jcode/scratch/9r-official-run
rm -rf "$SC" 2>/dev/null; mkdir -p "$SC"
docker run --rm -v "$SC":/home/container nodealpine:9r-root sh -c 'chown -R 1000:1000 /home/container && mkdir -p /home/container/data && chown 1000:1000 /home/container/data && echo PREP-OK'
printf 'INITIAL_PASSWORD=abc123\nDATA_DIR=/home/container/data\nPORT=20127\n' > "$SC/.env"
chown 1000:1000 "$SC/.env" 2>/dev/null || true

docker rm -f r9 >/dev/null 2>&1
docker run -dt --name r9 -v "$SC":/home/container \
  -e SERVER_PORT=20127 \
  -e STARTUP='node /app/custom-server.js --port {{SERVER_PORT}}' \
  -p 3110:20127 nodealpine:9r >/dev/null
CODE=000
for i in $(seq 1 20); do
  sleep 3
  CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3110/)
  ST=$(docker inspect -f '{{.State.Status}}' r9)
  [ "$CODE" != "000" ] && break
  [ "$ST" != "running" ] && break
done
echo "http=$CODE state=$ST uid=$(docker exec r9 id -u 2>/dev/null)"
echo "--- log:"; docker logs r9 2>&1 | grep -E "Ready|Local:|Server|error|Error" | head -6
S=$(date +%s%N); docker stop r9 >/dev/null; E=$(date +%s%N)
python3 -c "print(f'STOP_SECONDS={($E-$S)/1e9:.2f}')"
docker rm r9 >/dev/null
