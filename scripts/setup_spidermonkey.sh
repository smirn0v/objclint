#!/bin/sh

function exit_if_error {
    if [ $? -gt 0 ]; then
        echo "[-] $1"
        popd &>/dev/null
        exit 1    
    fi
}

SPIDER_MONKEY_VERSION="js185-1.0.0"                                                                                                        
SPIDER_MONKEY_DIR="${THIRDPARTY_DIR}/js-1.8.5"

pushd . > /dev/null
exit_if_error "failed to pushd"

cd "${THIRDPARTY_DIR}"
exit_if_error "failed to enter thirdparties dir"

# Autoconf-2.13 required for SpiderMonkey to build
echo "[~] Checking out Autoconf-2.13"

curl -s -O "http://ftp.gnu.org/gnu/autoconf/autoconf-2.13.tar.gz" 1> /dev/null
exit_if_error "failed to download autoconf-2.13"

echo "[~] Unpacking"
tar -zxf autoconf-2.13.tar.gz > /dev/null
exit_if_error "failed to extract autoconf"

cd autoconf-2.13
exit_if_error "failed to enter autoconf dir"

echo "[~] Configuring"

./configure --silent --prefix=./build --disable-debug --program-suffix=213 1> /dev/null
exit_if_error "failed to configure autoconf"

echo "[~] Building"

make install > /dev/null
exit_if_error "failed to install autoconf-2.13"

popd > /dev/null
exit_if_error "failed to popd"

echo "[~] Checking out SpiderMonkey JS Engine"

pushd . > /dev/null
exit_if_error "failed to pushd"

cd "${THIRDPARTY_DIR}"
exit_if_error "failed to enter thirdparties dir"

curl -s -O "http://ftp.mozilla.org/pub/mozilla.org/js/${SPIDER_MONKEY_VERSION}.tar.gz" 1> /dev/null
exit_if_error "failed to download SpiderMonkey JS Engine"

echo "[~] Unpacking"
tar -zxf ${SPIDER_MONKEY_VERSION}.tar.gz > /dev/null
exit_if_error "failed to extract SpiderMonkey JS Engine"

cp -R "${THIRDPARTY_DIR}/autoconf-2.13/build/share/autoconf/"* "${SPIDER_MONKEY_DIR}/js/src/"
exit_if_error "failed to copy autoconf files into SpiderMonkey"

cd "${SPIDER_MONKEY_DIR}/js/src"
exit_if_error "failed to enter SpiderMonkey directory"

echo "[~] Running autoconf"
"${THIRDPARTY_DIR}/autoconf-2.13/build/bin/autoconf213"
exit_if_error "failed to autoconf"

echo "[~] Configuring"
CC=cc \
CXX=c++ \
CCFLAGS="-w" \
CXXFLAGS="-w" \
./configure \
--silent \
--prefix="${SPIDER_MONKEY_DIR}/build" \
--disable-shared-js > /dev/null
exit_if_error "failed to configure SpiderMonkey"

echo "[~] Building"
make > /dev/null
exit_if_error "failed to build SpiderMonkey"

popd > /dev/null
exit_if_error "failed to popd"
