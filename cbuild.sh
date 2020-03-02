#!/bin/sh
set -e

ctr=$(buildah from ubuntu)

buildah run $ctr sh -c 'apt-get update && apt-get -y install --no-install-recommends gpg gpg-agent'
buildah run $ctr sh -c '. /etc/lsb-release && echo "deb http://ppa.launchpad.net/deluge-team/stable/ubuntu ${DISTRIB_CODENAME} main" > /etc/apt/sources.list.d/deluge.list'
buildah copy $ctr 'https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x8eed8fb4a8e6da6dfdf0192bc5e6a5ed249ad24c' /tmp/deluge_ppa_key
buildah run $ctr apt-key add /tmp/deluge_ppa_key

buildah run $ctr sh -c 'apt-get update && apt-get -y install --no-install-recommends deluged deluge-console'
deluge_ver=$(buildah run $ctr deluged -V | head -n 1 | cut -f 2 -d ' ' | cut -f 1 -d -)

buildah run $ctr sh -c "[ -d /var/lib/apt/lists ] && rm -rf /var/lib/apt/lists/*"

buildah copy $ctr entrypoint.sh /usr/local/bin/

buildah config \
	--entrypoint '["/usr/local/bin/entrypoint.sh"]' \
	--cmd "deluged" \
	--port 58846 \
	--volume /config \
	--volume /download \
	--workingdir /download \
	$ctr

img=$(buildah commit --rm $ctr deluge)
buildah tag $img "deluge:${deluge_ver}"
