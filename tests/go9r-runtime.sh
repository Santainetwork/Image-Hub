#!/bin/bash
# Runtime test 9router-go dari hasil install egg (non-root, TTY seperti Wings)
SC=/root/.jcode/scratch/go9r-install
sed -i 's/^PORT=20130$/PORT=20127/' "$SC/.env"
echo "--- .env:"; cat "$SC/.env"
docker rm -f go9r >/dev/null 2>&1
docker run -dt --name go9r -v "$SC":/home/container -e STARTUP='./9router-go < /dev/null' \
  -p 3106:20127 nodealpine:22-glc >/dev/null
CODE=000
for i in $(seq 1 10); do
  sleep 3
  CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3106/)
  ST=$(docker inspect -f '{{.State.Status}}' go9r)
  echo "t=$((i*3))s http=$CODE state=$ST uid=$(docker exec go9r id -u 2>/dev/null)"
  [ "$CODE" != "000" ] && break
  [ "$ST" != "running" ] && break
done
echo "--- log:"; docker logs go9r 2>&1 | grep -E "Proxy \(|ready to handle|Choose|error" | head -5
S=$(date +%s%N); docker stop go9r >/dev/null; E=$(date +%s%N)
python3 -c "print(f'STOP_SECONDS={($E-$S)/1e9:.2f}')"
docker rm go9r >/dev/null
