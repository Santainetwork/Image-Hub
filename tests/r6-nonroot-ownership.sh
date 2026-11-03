#!/bin/bash
# Round-6 v2: salin install Kuma dengan ownership uid 1000, lalu runtime non-root :26
SCRATCH=${JCODE_SCRATCH_DIR:-/root/scratch}
DEST=$SCRATCH/kuma1000
mkdir -p "$DEST"
# Copy + chown DI DALAM container root (bukan host)
docker run --rm -v /mnt/server:/src:ro -v "$DEST":/dst ghcr.io/santainetwork/node26-alpine:26-root \
  sh -c 'cp -a /src/. /dst/ && chown -R 1000:1000 /dst && echo CHOWN-OK'
ls -ln "$DEST/data/kuma.db"
# Runtime non-root pakai :26, paksa amd64 agar tidak ke-cache image arm64
docker rm -f kuma1000 >/dev/null 2>&1
docker run -d --name kuma1000 --platform linux/amd64 -v "$DEST":/home/container \
  -e AUTO_UPDATE=0 -e SERVER_PORT=3001 \
  -e STARTUP='if [[ -d .git ]] && [[ {{AUTO_UPDATE}} == "1" ]]; then npm run setup; fi; /usr/local/bin/node /home/container/server/server.js --port=${SERVER_PORT}' \
  -p 3101:3001 ghcr.io/santainetwork/node26-alpine:26 >/dev/null
CODE=000
for i in 1 2 3 4 5 6 7 8 9 10 11 12; do
  sleep 5
  CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3101/)
  [ "$CODE" != "000" ] && break
done
echo "HTTP_STATUS=$CODE (non-root :26, ownership uid 1000)"
docker logs kuma1000 2>&1 | grep -oE "SQLITE_READONLY|Uptime Kuma Version: [0-9.]+" | tail -1
S=$(date +%s%N); docker stop kuma1000 >/dev/null; E=$(date +%s%N)
python3 -c "print(f'STOP_SECONDS={($E-$S)/1e9:.2f}')"
docker rm kuma1000 >/dev/null
