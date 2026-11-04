#!/bin/bash
set -o pipefail

cd /home/container || exit 1

# Convert panel placeholders like {{SERVER_MEMORY}} into shell env references
PARSED_STARTUP=$(echo "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g')

# Some eggs put the real command in a variable (startup: "${STARTUP_CMD}" or
# "{{STARTUP_CMD}}"). Expansion results are not re-parsed as shell syntax, so
# reserved words (if/then/fi) would break. Resolve such a bare reference once
# more, then re-substitute placeholders inside the resolved value.
if [[ "${PARSED_STARTUP}" =~ ^\$\{([A-Za-z_][A-Za-z0-9_]*)\}$ ]]; then
    PARSED_STARTUP="${!BASH_REMATCH[1]}"
    PARSED_STARTUP=$(echo "${PARSED_STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g')
fi

printf "\033[1;33mcontainer@pterodactyl~ \033[0m%s\n" "${PARSED_STARTUP}"

# Execute through a real shell so egg startup commands that use shell
# control flow (if/then, &&, ||, loops) work correctly. exec replaces
# this script, and tini (-g in the Dockerfile) forwards SIGTERM to the
# whole process group so the server stops gracefully and instantly.
exec /bin/bash -c "${PARSED_STARTUP}"
