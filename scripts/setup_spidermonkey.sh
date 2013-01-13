#!/bin/sh -e -o pipefail

SPIDER_MONKEY_VERSION="js185-1.0.0"                                                                                                        
SPIDER_MONKEY_DIR="${THIRDPARTY_DIR}/js-1.8.5"

function indented_status {
    "${STATUS_SH}" -i $1 "$2"
}

pushd . > /dev/null

cd "${THIRDPARTY_DIR}"

indented_status 0 "Setting up SpiderMonkey JS Engine"

# Autoconf-2.13 required for SpiderMonkey to build
indented_status 2 "Setting up Autoconf 2.13"
indented_status 3 "Checking out"

curl -s -O "http://ftp.gnu.org/gnu/autoconf/autoconf-2.13.tar.gz" 1> /dev/null

indented_status 3 "Unpacking"
tar -zxf autoconf-2.13.tar.gz > /dev/null

cd autoconf-2.13

indented_status 3 "Configuring"

./configure --silent --prefix=./build --disable-debug --program-suffix=213 1> /dev/null

indented_status 3 "Building"

make install > /dev/null

popd > /dev/null

indented_status 2 "Setting up SpiderMonkey 1.8.5"
indented_status 3 "Checking out"

pushd . > /dev/null

cd "${THIRDPARTY_DIR}"

curl -s -O "http://ftp.mozilla.org/pub/mozilla.org/js/${SPIDER_MONKEY_VERSION}.tar.gz" 1> /dev/null

indented_status 3 "Unpacking"
tar -zxf ${SPIDER_MONKEY_VERSION}.tar.gz > /dev/null

cp -R "${THIRDPARTY_DIR}/autoconf-2.13/build/share/autoconf/"* "${SPIDER_MONKEY_DIR}/js/src/"

cd "${SPIDER_MONKEY_DIR}/js/src"

indented_status 3 "Running autoconf"
"${THIRDPARTY_DIR}/autoconf-2.13/build/bin/autoconf213"

indented_status 3 "Configuring"
CC=cc \
CXX=c++ \
CCFLAGS="-w" \
CXXFLAGS="-w" \
./configure \
--silent \
--prefix="${SPIDER_MONKEY_DIR}/build" \
--disable-shared-js > /dev/null

indented_status 3 "Building"
make > /dev/null

indented_status 3 "Installing"
make install > /dev/null

popd > /dev/null
