#!/bin/bash
# Uji startup self-healing dari egg: run.sh DIHAPUS + BUILD_ID DIHAPUS (kondisi server user)
D=/root/.jcode/scratch/dirty-dir
# ambil STARTUP_CMD default langsung dari JSON egg (fidelitas penuh)
STARTUP_CMD=$(python3 -c "
import json
egg = json.load(open('/root/image-hub/tests/9router-egg-v2.json'))
print([v['default_value'] for v in egg['variables'] if v['env_variable']=='STARTUP_CMD'][0])
")
echo "STARTUP_CMD = $STARTUP_CMD"
docker run --rm -v "$D":/home/container ghcr.io/santainetwork/image-hub:node22-root \
  sh -c 'rm -f /home/container/run.sh /home/container/.next/BUILD_ID && echo "run.sh + BUILD_ID dihapus"'

docker rm -f router9 >/dev/null 2>&1
docker run -d --name router9 -v "$D":/home/container \
  -e SERVER_PORT=20127 -e AUTO_UPDATE=0 -e FORCE_INSTALL=0 \
  -e STARTUP="$STARTUP_CMD" \
  -p 3102:20127 ghcr.io/santainetwork/image-hub:node22 >/dev/null
CODE=000
for i in $(seq 1 90); do
  sleep 4
  CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3102/)
  ST=$(docker inspect -f '{{.State.Status}}' router9)
  if [ $((i % 5)) -eq 0 ] || [ "$CODE" != "000" ]; then
    echo "t=$((i*4))s http=$CODE state=$ST"
  fi
  [ "$CODE" != "000" ] && break
  [ "$ST" != "running" ] && break
done
echo "--- log:"
docker logs router9 2>&1 | grep -E "Building|Ready|Local:|error|Error" | head -8
S=$(date +%s%N); docker stop router9 >/dev/null; E=$(date +%s%N)
python3 -c "print(f'STOP_SECONDS={($E-$S)/1e9:.2f}')"
docker rm router9 >/dev/null
