FROM ubuntu

LABEL org.opencontainers.image.source=https://github.com/computator/deluge-container

RUN set -eux; \
	apt-get update && apt-get -y install --no-install-recommends curl ca-certificates gpg gpg-agent; \
	. /etc/lsb-release && echo "deb http://ppa.launchpad.net/deluge-team/stable/ubuntu ${DISTRIB_CODENAME} main" > /etc/apt/sources.list.d/deluge.list; \
	{ echo 'Package: *'; echo 'Pin: release o=LP-PPA-deluge-team-stable'; echo 'Pin-Priority: 1000'; } | tee /etc/apt/preferences.d/deluge.pref; \
	curl -sS 'https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x8eed8fb4a8e6da6dfdf0192bc5e6a5ed249ad24c' | APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1 apt-key add -; \
	rm -rf /var/lib/apt/lists/*
END
RUN apt-get update && apt-get -y install --no-install-recommends deluged deluge-console; \
	rm -rf /var/lib/apt/lists/*
COPY entrypoint.sh /usr/local/bin/

RUN set -e; \
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

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["deluged"]

VOLUME /config
VOLUME /download
WORKDIR /download

EXPOSE 58846
