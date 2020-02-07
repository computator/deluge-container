#!/bin/sh
set -e

INSTALL_DEPS='python3-pip python3-wheel python3-dev gcc'
ctr=$(buildah from ubuntu)

buildah run $ctr sh -c "apt-get update && apt-get -y install --no-install-recommends python3-libtorrent python3-setuptools ${INSTALL_DEPS}"

buildah run $ctr pip3 install deluge
deluge_ver=$(buildah run $ctr deluged -V | head -n 1 | cut -f2 -d ' ')

buildah run $ctr sh -c "apt-get -y --auto-remove remove ${INSTALL_DEPS}"
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
