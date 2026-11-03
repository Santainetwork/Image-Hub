#!/bin/bash
set -o pipefail

cd /home/container || exit 1

# Convert panel placeholders like {{SERVER_MEMORY}} into shell env references
PARSED_STARTUP=$(echo "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g')

printf "\033[1;33mcontainer@pterodactyl~ \033[0m%s\n" "${PARSED_STARTUP}"

# Execute through a real shell so egg startup commands that use shell
# control flow (if/then, &&, ||, loops) work correctly. exec replaces
# this script, and tini (-g in the Dockerfile) forwards SIGTERM to the
# whole process group so the server stops gracefully and instantly.
exec /bin/bash -c "${PARSED_STARTUP}"
