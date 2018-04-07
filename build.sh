#!/bin/sh
set -e

# Latest stable release
FILE="$(curl http://download.sonarr.tv/v2/master/mono/ | grep -Eo ">NzbDrone.master.[0-9\.]+.mono.tar.gz<" | sed -e 's/[<>]//g' | tail -n 1)"
URL="http://download.sonarr.tv/v2/master/mono/${FILE}"

#http://download.sonarr.tv/v2/master/mono/http://download.sonarr.tv/v2/master/mono/NzbDrone.master.2.0.0.5163.mono.tar.gz
VERSION=$(echo $URL | sed -e 's/^.*NzbDrone.master.//' -e 's/.mono.tar.gz//')

git pull > /dev/null 2>&1
DOCKERFILE_VERSION=$(grep "^ARG SONARR_VERSION=" Dockerfile | cut -f2 -d\=)

if [ "${VERSION}" != "${DOCKERFILE_VERSION}" ]; then
  echo "Updating Dockerfile with version ${VERSION}"
  sed -i -e "s/^\(ARG SONARR_VERSION=\).*$/\1${VERSION}/g" \
         -e "s|^\(ARG SONARR_URL=\).*$|\1${URL}|g" Dockerfile
  git add Dockerfile
  git commit -m "Bumping Sonarr version to ${VERSION}"
  git push
  make minor-release
  exit -1
else
  echo "No change"
fi

# exit codes:
# 0 - no action
# -1 - new build pushed
# rest - errors
