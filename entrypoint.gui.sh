#!/bin/sh
set -e

CDIR="/config"

create_auth () {
	[ -f "$CDIR/auth" ] && return 0
	[ -n "$DELUGE_USER" ] && [ -n "$DELUGE_PASS" ] || return 0
	echo "$DELUGE_USER:$DELUGE_PASS:10" > "$CDIR/auth"
}

if [ "$1" = 'deluge-gtk' ]; then
	shift
	create_auth
	exec deluge-gtk -c /config -L info "$@"
elif [ "$1" = 'deluge-console' ] || [ "$1" = 'console' ]; then
	shift
	exec deluge-console -c /config "$@"
fi

exec "$@"
