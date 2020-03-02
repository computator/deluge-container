#!/bin/sh
set -e

CONF="/config/core.conf"

create_conf () {
	[ -f $CONF ] && return 0
	cat > $CONF <<-"EOF"
		{
			"file": 1,
			"format": 1
		}{
			"allow_remote": true
		}
	EOF
}

if [ "$1" = 'deluged' ]; then
	shift
	create_conf
	exec deluged -d -c /config -L info "$@"
elif [ "$1" = 'deluge-console' ] || [ "$1" = 'console' ]; then
	shift
	exec deluge-console -c /config -L info "$@"
fi

exec "$@"