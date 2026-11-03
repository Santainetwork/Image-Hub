#!/bin/bash
set -o pipefail

cd /home/container || exit 1

# Convert panel placeholders like {{SERVER_MEMORY}} into shell env references
MODIFIED_STARTUP=$(eval echo "$(echo "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g')")

printf "\033[0;32m:/home/container$ %s\033[0m\n" "${MODIFIED_STARTUP}"

# exec replaces this shell so tini forwards signals (SIGTERM/SIGINT)
# directly to the started process for instant, graceful stops.
exec ${MODIFIED_STARTUP}
