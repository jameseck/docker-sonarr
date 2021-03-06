FROM centos:7

MAINTAINER James Eckersall <james.eckersall@gmail.com>

ARG SONARR_VERSION=2.0.0.5338
ARG SONARR_URL=http://download.sonarr.tv/v2/master/mono/NzbDrone.master.2.0.0.5338.mono.tar.gz

RUN \
  yum install -y epel-release yum-utils && \
  rpm --import "http://keyserver.ubuntu.com/pks/lookup?op=get&search=0x3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF" && \
  yum-config-manager --add-repo http://download.mono-project.com/repo/centos/ && \
  yum install -y curl gettext libmediainfo libzen mediainfo mono-core sqlite.x86_64 wget && \
  yum clean all && \
  rm -rf /var/cache/yum/*
RUN \
  mkdir --mode=0777 /config && \
  curl -L "${SONARR_URL}" -o /tmp/NzbDrone.master.tar.gz && \
  tar -xvf /tmp/NzbDrone.master.tar.gz -C / && \
  rm -f NzbDrone.master.tar.gz && \
  chmod -R 0775 /var/log /config /NzbDrone

COPY run.py /run.py
COPY run.sh /run.sh
COPY dbseed.py /dbseed.py

# Needed for signalr to work (see https://forums.sonarr.tv/t/gui-update-issues/4195/31)
ENV \
  XDG_CONFIG_HOME=/config \
  APIKEY=""

EXPOSE 8989

VOLUME ["/config", "/data"]

ENTRYPOINT ["/usr/bin/python2", "/run.py"]
