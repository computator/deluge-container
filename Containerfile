FROM docker.io/library/ubuntu

LABEL org.opencontainers.image.source=https://github.com/computator/deluge-container

RUN set -eux; \
	apt-get update; \
	apt-get -y install --no-install-recommends ca-certificates curl; \
	curl -sS 'https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x8eed8fb4a8e6da6dfdf0192bc5e6a5ed249ad24c' \
		| tee /usr/share/keyrings/deluge-archive-keyring.asc; \
	. /etc/lsb-release; \
	echo "deb [signed-by=/usr/share/keyrings/deluge-archive-keyring.asc] https://ppa.launchpadcontent.net/deluge-team/stable/ubuntu ${DISTRIB_CODENAME} main" \
		> /etc/apt/sources.list.d/deluge.list; \
	{ \
		echo 'Package: *'; \
		echo 'Pin: release o=LP-PPA-deluge-team-stable'; \
		echo 'Pin-Priority: 1000'; \
	} | tee /etc/apt/preferences.d/deluge.pref; \
	apt-get update; \
	apt-get -y install --no-install-recommends deluged deluge-console; \
	rm -rf /var/lib/apt/lists/*

RUN set -eux; \
	mkdir -p /config; \
	{ \
		echo '{'; \
		echo '	"file": 1,'; \
		echo '	"format": 1'; \
		echo '}{'; \
		echo '	"allow_remote": true,'; \
		echo '	"download_location": "/download"'; \
		echo '}'; \
	} | tee /config/core.conf

COPY entrypoint.sh /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["deluged"]
EXPOSE 58846
WORKDIR /download
VOLUME /config
VOLUME /download
