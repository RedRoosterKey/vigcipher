#! /bin/bash
set -e
# set -v

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
VERSION_H="${DIR}/../src/version.h"

cat "${VERSION_H}"

echo "Enter new major version number (increment when backwards compatibility is broken)"
read major
echo "Enter new mid version number (increment when new features are added)"
read mid
echo "Enter new minor version number (increment for any other changes)"
read minor

echo "#define VERSION \"${major}.${mid}.${minor}\"" > "${VERSION_H}"
