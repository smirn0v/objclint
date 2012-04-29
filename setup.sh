#!/bin/bash

function exit_if_error {
    if [ $1 -gt 0 ]; then
        echo "[-] $2"
        exit 1    
    fi
}

##### Check if not ran before ##########################

if [ -d "llvm-3.0" ] || [ -d "build" ]; then
    exit_if_error 1 "Try to delete 'llvm-3.0' and 'build' directories and then run 'setup.sh' again"
fi

mkdir build

########################################################

##### Checkout llvm 3.0 ################################

echo "[~] Checking out 'llvm 3.0'"

svn export http://llvm.org/svn/llvm-project/llvm/tags/RELEASE_30/final/  llvm-3.0 1> /dev/null

exit_if_error $? "llvm checkout error"

echo "[+] Checked out 'llvm 3.0'"
echo
########################################################

##### Checkout clang 3.0 ###############################

cd ./llvm-3.0/tools

echo "[~] Checking out 'clang 3.0'"

svn export http://llvm.org/svn/llvm-project/cfe/tags/RELEASE_30/final/ clang 1> /dev/null

exit_if_error $? "clang checkout error"

echo "[+] Checked out 'clang 3.0'"
echo
#######################################################

##### Building llvm ##################################

cd ../

echo "[~] Configuring llvm && clang"

./configure --prefix `cd ../build/;pwd` --enable-optimized 1> /dev/null

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
