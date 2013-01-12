#!/bin/sh

function exit_if_error {
    if [ $? -gt 0 ]; then
        echo "[-] $1"
        popd &> /dev/null
        exit 1    
    fi
}

LLVM_CHECKOUT_DIR="${THIRDPARTY_DIR}/llvm-3.1"
LLVM_CLANG_BUILD_DIR="${LLVM_CHECKOUT_DIR}/llvm-clang-build/"

mkdir -p $LLVM_CLANG_BUILD_DIR
exit_if_error "failed to create llvm&&clang build dir"

pushd . > /dev/null
exit_if_error "failed to pushd"

echo "[~] Checking out LLVM 3.1"

svn --force export http://llvm.org/svn/llvm-project/llvm/tags/RELEASE_31/final/ "$LLVM_CHECKOUT_DIR" > /dev/null
exit_if_error "llvm checkout error"

cd "${LLVM_CHECKOUT_DIR}/tools"
exit_if_error "failed to enter tools folder"

echo "[~] Checking out 'clang 3.1'"

svn export http://llvm.org/svn/llvm-project/cfe/tags/RELEASE_31/final/ clang > /dev/null
exit_if_error "clang checkout error"

cd "${LLVM_CHECKOUT_DIR}"
exit_if_error "failed to enter llvm checkout dir"

echo "[~] Configuring llvm && clang"

./configure --prefix="${LLVM_CLANG_BUILD_DIR}" --enable-optimized > /dev/null
exit_if_error "failed to configure 'llvm'"

echo "[~] Building"

# building twice, somehow first build fails.
make -j4 1> /dev/null 2>&1
make -j4 1> /dev/null
exit_if_error "failed to build"

echo "[~] Installing"

make install
exit_if_errror "failed to install"

popd > /dev/null
exit_if_error "failed to popd"
