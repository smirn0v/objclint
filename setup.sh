#!/bin/bash

THIRDPATIES_DIR="`pwd`/thirdparty"
LLVM_CLANG_BUILD_DIR="`pwd`/thirdparty/llvm-3.1/llvm-clang-build"
LLVM_CHECKOUT_DIR="`pwd`/thirdparty/llvm-3.1"
SPIDER_MONKEY_VERSION="js185-1.0.0"
SPIDER_MONKEY_DIR="${THIRDPATIES_DIR}/js-1.8.5"

function exit_if_error {
    if [ $? -gt 0 ]; then
        echo "[-] $1"
        exit 1    
    fi
}

##### Check if not ran before ##########################

if [ "$(ls -A ${THIRDPATIES_DIR})" ]; then
    echo "[-] Try to cleanup ${THIRDPATIES_DIR} and run $0 again"
    exit 1
fi

mkdir -p $LLVM_CLANG_BUILD_DIR 

########################################################

##### Checkout llvm ################################

echo "[~] Checking out '${LLVM_CHECKOUT_DIR}'"

svn --force export http://llvm.org/svn/llvm-project/llvm/tags/RELEASE_31/final/ $LLVM_CHECKOUT_DIR 1> /dev/null

exit_if_error "llvm checkout error"

echo "[+] Checked out"
echo
########################################################

##### Checkout clang ###############################

cd ${LLVM_CHECKOUT_DIR}/tools

echo "[~] Checking out 'clang 3.1'"

svn export http://llvm.org/svn/llvm-project/cfe/tags/RELEASE_31/final/ clang 1> /dev/null

exit_if_error "clang checkout error"

echo "[+] Checked out"
echo

#### Checkout SpiderMonkey #########################

echo "[~] Checking out SpiderMonkey JS Engine"

cd "${THIRDPATIES_DIR}"
curl -s -O "http://ftp.mozilla.org/pub/mozilla.org/js/${SPIDER_MONKEY_VERSION}.tar.gz" 1> /dev/null
exit_if_error "failed to download SpiderMonkey JS Engine"

tar -zxf ${SPIDER_MONKEY_VERSION}.tar.gz 1> /dev/null
exit_if_error "failed to extract"

echo "[+] Checked out"
echo

#####################################################

#### Checkout Autocong-2.13 #########################

echo "[~] Checking out Autoconf-2.13 (needed for SpiderMonkey)"

curl -s -O "http://ftp.gnu.org/gnu/autoconf/autoconf-2.13.tar.gz" 1> /dev/null
exit_if_error "failed to download autoconf-2.13"

tar -zxf autoconf-2.13.tar.gz 1> /dev/null
exit_if_error "failed to extract"

echo "[+] Checked out"
echo

#######################################################

##### Building autoconf ###############################

cd autoconf-2.13

echo "[~] Setting up autoconf-2.13"

./configure --prefix=./build --disable-debug --program-suffix=213 1> /dev/null
exit_if_error "failed to configure autoconf"

make install 1> /dev/null
exit_if_error "failed to install autoconf-2.13"

cp -R ./build/share/autoconf/* "${SPIDER_MONKEY_DIR}/js/src/"
exit_if_error "failed to copy autoconf files into SpiderMonkey"

echo "[+] Finished configuring autoconf-2.13"
echo
#######################################################

##### Building Spider Monkey ##########################

echo "[~] Building SpiderMonkey"

cd "${SPIDER_MONKEY_DIR}"/js/src

echo "[~] Autoconf"
"${THIRDPATIES_DIR}/autoconf-2.13/build/bin/autoconf213"
exit_if_error "failed to autoconf"
echo "[+] Autoconf finished"

echo "[~] Configuring"
CC=cc \
CXX=c++ \
CCFLAGS=-w \
CXXFLAGS=-w \
./configure \
--prefix="${SPIDER_MONKEY_DIR}/build" \
--disable-shared-js 1> /dev/null

exit_if_error "failed to configure SpiderMonkey"
echo "[+] Configured"

echo "[~] Building"
make 1> /dev/null
exit_if_error "failed to build SpiderMonkey"
echo "[+] Build finished"

echo "[~] Installing"
make install 1> /dev/null
exit_if_error "failed to install SpiderMonkey"
echo "[+] Installed"
echo 
#####################################################


#### Building llvm ##################################

cd ${LLVM_CHECKOUT_DIR}

echo "[~] Configuring llvm && clang"

./configure --prefix=${LLVM_CLANG_BUILD_DIR} --enable-optimized 1> /dev/null

exit_if_error "Failed to configure 'llvm'"

echo "[+] Configured"
echo

echo "[~] Building..."

# building twice, somehow first build fails.
make -j4 1> /dev/null 2>&1
make -j4 1> /dev/null

exit_if_error "Failed to build"

echo "[+] Build finished"
echo

echo "[~] Installing"

make install

exit_if_error "Failed to install"

echo "[+] llvm+clang installed into 'thirdparty' directory"
echo

echo "now run ./install.sh to build/install 'objclint'"
echo "...Have fun..."
