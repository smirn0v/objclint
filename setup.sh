#!/bin/bash

LLVM_CLANG_BUILD_DIR=llvm-clang-build
LLVM_CHECKOUT_DIR=llvm-3.1
PROJECT_DIR=`pwd`

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

mkdir $LLVM_CLANG_BUILD_DIR 

########################################################

##### Checkout llvm ################################

echo "[~] Checking out '${LLVM_CHECKOUT_DIR}'"

svn export http://llvm.org/svn/llvm-project/llvm/tags/RELEASE_31/rc1/ $LLVM_CHECKOUT_DIR 1> /dev/null

exit_if_error $? "llvm checkout error"

echo "[+] Checked out"
echo
########################################################

##### Checkout clang 3.0 ###############################

cd ./${LLVM_CHECKOUT_DIR}/tools

echo "[~] Checking out 'clang 3.1'"

svn export http://llvm.org/svn/llvm-project/cfe/tags/RELEASE_31/rc1/ clang 1> /dev/null

exit_if_error $? "clang checkout error"

echo "[+] Checked out"
echo
#######################################################

##### Creating new 'example' #########################
## this is a simpliest way to build plugin currently
## at least for now

cd clang/examples

# adding new folder to build
sed -i -e 's/\(PARALLEL_DIRS.*$\)/\1 objclint/' Makefile

mkdir objclint

cp "$PROJECT_DIR"/src/* objclint/

######################################################

##### Building llvm ##################################

cd "${PROJECT_DIR}/${LLVM_CHECKOUT_DIR}"

echo "[~] Configuring llvm && clang"

./configure --prefix `cd ../$LLVM_CLANG_BUILD_DIR/;pwd` --enable-optimized 1> /dev/null

exit_if_error $? "Failed to configure 'llvm'"

echo "[+] Configured"
echo

echo "[~] Building..."

# building twice(sic!), somehow first build fails.
make -j4 BUILD_EXAMPLES=1 1> /dev/null 2>&1
make -j4 BUILD_EXAMPLES=1 1> /dev/null

exit_if_error $? "Failed to build"

echo "[+] Build finished"
echo

echo "[~] Installing"

make install

exit_if_error $? "Failed to install"

echo "[+] Installed"
echo

echo "...Have fun..."
