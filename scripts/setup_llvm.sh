#!/bin/sh -e -o pipefail

LLVM_CHECKOUT_DIR="${THIRDPARTY_DIR}/llvm-3.1"
LLVM_CLANG_BUILD_DIR="${LLVM_CHECKOUT_DIR}/llvm-clang-build/"

mkdir -p "$LLVM_CLANG_BUILD_DIR"

pushd . > /dev/null

"${STATUS_SH}" "Checking out llvm 3.1"

svn --force export http://llvm.org/svn/llvm-project/llvm/tags/RELEASE_31/final/ "$LLVM_CHECKOUT_DIR" > /dev/null

cd "${LLVM_CHECKOUT_DIR}/tools"

"${STATUS_SH}" "Checking out clang 3.1"

svn export http://llvm.org/svn/llvm-project/cfe/tags/RELEASE_31/final/ clang > /dev/null

cd "${LLVM_CHECKOUT_DIR}"

"${STATUS_SH}" "Configuring llvm && clang"

./configure --prefix="${LLVM_CLANG_BUILD_DIR}" --enable-optimized > /dev/null

"${STATUS_SH}" "Building"

# building twice, somehow first build fails.
make -j4 1> /dev/null 2>&1
make -j4 1> /dev/null

"${STATUS_SH}" "Installing"

make install > /dev/null

popd > /dev/null
