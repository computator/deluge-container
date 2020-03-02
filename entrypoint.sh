#!/bin/sh
set -e

CDIR="/config"

create_auth () {
	[ -f "$CDIR/auth" ] && return 0
	[ -n "$DELUGE_USER" ] && [ -n "$DELUGE_PASS" ] || return 0
	echo "$DELUGE_USER:$DELUGE_PASS:10" > "$CDIR/auth"
}

create_conf () {
	[ -f "$CDIR/core.conf" ] && return 0
	cat > "$CDIR/core.conf" <<-"EOF"
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
	create_auth
	create_conf
	exec deluged -d -c /config -L info "$@"
elif [ "$1" = 'deluge-console' ] || [ "$1" = 'console' ]; then
	shift
	exec deluge-console -c /config "$@"
fi

exec "$@"