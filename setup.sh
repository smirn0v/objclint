#!/bin/bash

LLVM_CLANG_BUILD_DIR="`pwd`/thirdparty/llvm-3.1/llvm-clang-build"
LLVM_CHECKOUT_DIR="`pwd`/thirdparty/llvm-3.1"

function exit_if_error {
    if [ $1 -gt 0 ]; then
        echo "[-] $2"
        exit 1    
    fi
}

##### Check if not ran before ##########################

if [ -d $LLVM_CHECKOUT_DIR ] || [ -d $LLVM_CLANG_BUILD_DIR  ]; then
    exit_if_error 1 "Try to delete '${LLVM_CHECKOUT_DIR}' and '${LLVM_CLANG_BUILD_DIR}' directories and then run 'setup.sh' again"
fi

mkdir -p $LLVM_CLANG_BUILD_DIR 

########################################################

##### Checkout llvm ################################

echo "[~] Checking out '${LLVM_CHECKOUT_DIR}'"

svn --force export http://llvm.org/svn/llvm-project/llvm/tags/RELEASE_31/final/ $LLVM_CHECKOUT_DIR 1> /dev/null

exit_if_error $? "llvm checkout error"

echo "[+] Checked out"
echo
########################################################

##### Checkout clang ###############################

cd ${LLVM_CHECKOUT_DIR}/tools

echo "[~] Checking out 'clang 3.1'"

svn export http://llvm.org/svn/llvm-project/cfe/tags/RELEASE_31/final/ clang 1> /dev/null

exit_if_error $? "clang checkout error"

echo "[+] Checked out"
echo
#######################################################

##### Building llvm ##################################

cd ${LLVM_CHECKOUT_DIR}

echo "[~] Configuring llvm && clang"

./configure --prefix=${LLVM_CLANG_BUILD_DIR} --enable-optimized 1> /dev/null

exit_if_error $? "Failed to configure 'llvm'"

echo "[+] Configured"
echo

echo "[~] Building..."

# building twice, somehow first build fails.
make -j4 1> /dev/null 2>&1
make -j4 1> /dev/null

exit_if_error $? "Failed to build"

echo "[+] Build finished"
echo

echo "[~] Installing"

make install

exit_if_error $? "Failed to install"

echo "[+] llvm+clang installed into 'thirdparty' directory"
echo

echo "now you can use cmake to build/install 'objclint'"
echo "...Have fun..."
