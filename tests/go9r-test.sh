#!/bin/bash
# Uji 9router-go (Go single binary) di image dengan gcompat: path benar + foreground + .env PORT
D=/root/.jcode/scratch/go9router
echo "=== help (path tetap) ==="
docker run --rm -v "$D":/x nodealpine:22-glc sh -c 'cd /x && ./9router-go --help 2>&1 | head -4'

printf 'JWT_SECRET=testsecret123\nINITIAL_PASSWORD=abc123\nDATA_DIR=./data\nPORT=20127\n' > "$D/.env"
docker rm -f go9r >/dev/null 2>&1
docker run -d --name go9r -v "$D":/home/container -e STARTUP='./9router-go' -p 3103:20127 nodealpine:22-glc >/dev/null
CODE=000
for i in $(seq 1 10); do
  sleep 3
  CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3103/)
  ST=$(docker inspect -f '{{.State.Status}}' go9r)
  echo "t=$((i*3))s http=$CODE state=$ST"
  [ "$CODE" != "000" ] && break
  [ "$ST" != "running" ] && break
done
echo "--- log:"
docker logs go9r 2>&1 | tail -10
S=$(date +%s%N); docker stop go9r >/dev/null; E=$(date +%s%N)
python3 -c "print(f'STOP_SECONDS={($E-$S)/1e9:.2f}')"
docker rm go9r >/dev/null 2>&1
