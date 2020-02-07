#!/bin/sh
set -e

if [ "$1" = 'deluged' ]; then
	exec deluged -d -c /config -L info
fi

exec "$@"