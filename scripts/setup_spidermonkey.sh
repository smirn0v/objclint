#!/bin/sh -e -o pipefail

SPIDER_MONKEY_VERSION="js185-1.0.0"                                                                                                        
SPIDER_MONKEY_DIR="${THIRDPARTY_DIR}/js-1.8.5"

pushd . > /dev/null

cd "${THIRDPARTY_DIR}"

# Autoconf-2.13 required for SpiderMonkey to build
"${STATUS_SH}" "Checking out Autoconf-2.13"

curl -s -O "http://ftp.gnu.org/gnu/autoconf/autoconf-2.13.tar.gz" 1> /dev/null

"${STATUS_SH}" "Unpacking"
tar -zxf autoconf-2.13.tar.gz > /dev/null

cd autoconf-2.13

"${STATUS_SH}" "Configuring"

./configure --silent --prefix=./build --disable-debug --program-suffix=213 1> /dev/null

"${STATUS_SH}" "Building"

make install > /dev/null

popd > /dev/null

"${STATUS_SH}" "Checking out SpiderMonkey JS Engine"

pushd . > /dev/null

cd "${THIRDPARTY_DIR}"

curl -s -O "http://ftp.mozilla.org/pub/mozilla.org/js/${SPIDER_MONKEY_VERSION}.tar.gz" 1> /dev/null

"${STATUS_SH}" "Unpacking"
tar -zxf ${SPIDER_MONKEY_VERSION}.tar.gz > /dev/null

cp -R "${THIRDPARTY_DIR}/autoconf-2.13/build/share/autoconf/"* "${SPIDER_MONKEY_DIR}/js/src/"

cd "${SPIDER_MONKEY_DIR}/js/src"

"${STATUS_SH}" "Running autoconf"
"${THIRDPARTY_DIR}/autoconf-2.13/build/bin/autoconf213"

# avoid error message with XCode 4.5
sed -i -e 's/-ge\ 620/-ge\ 620 2\>\/dev\/null/' configure
# avoid unnecessary output from autoconf script
sed -i -e '170d' ./build/autoconf/acoutput-fast.pl

"${STATUS_SH}" "Configuring"
CC=cc \
CXX=c++ \
CCFLAGS="-w" \
CXXFLAGS="-w" \
./configure \
--silent \
--prefix="${SPIDER_MONKEY_DIR}/build" \
--disable-shared-js > /dev/null 1>/dev/null

"${STATUS_SH}" "Building"
make > /dev/null

popd > /dev/null
