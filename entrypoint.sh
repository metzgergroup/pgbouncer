#!/bin/sh
set -e

# Drop to a non-root user if the container is run as root and the command is pgbouncer
if [ "$(id -u)" = '0' ] && [ "$1" = 'pgbouncer' ]; then
    mkdir -p /var/run/pgbouncer
    chown -R pgbouncer /var/run/pgbouncer
    exec su-exec pgbouncer "$0" "$@"
fi

exec "$@"
