#!/bin/sh
set -e

if [ "$1" = 'deluged' ]; then
	shift
	exec deluged -d -c /config -L info "$@"
elif [ "$1" = 'deluge-console' ] || [ "$1" = 'console' ]; then
	shift
	exec deluge-console -c /config -L info "$@"
fi

exec "$@"