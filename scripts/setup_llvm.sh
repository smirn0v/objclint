#!/bin/sh -e -o pipefail

LLVM_CHECKOUT_DIR="${THIRDPARTY_DIR}/llvm-3.1"
LLVM_CLANG_BUILD_DIR="${LLVM_CHECKOUT_DIR}/llvm-clang-build/"

function indented_status {
    "${STATUS_SH}" -i $1 "$2"
}

if [ -d "${LLVM_CLANG_BUILD_DIR}" ]; then
    indented_status 0 "Seems like LLVM and clang were already installed, skipping"
    exit 0
fi

mkdir -p "$LLVM_CLANG_BUILD_DIR"

pushd . > /dev/null

indented_status 0 "Settings up LLVM 3.1 and clang"

indented_status 2 "Checking out LLVM"

svn --force export http://llvm.org/svn/llvm-project/llvm/tags/RELEASE_31/final/ "$LLVM_CHECKOUT_DIR" > /dev/null

cd "${LLVM_CHECKOUT_DIR}/tools"

indented_status 2 "Checking out clang"

svn export http://llvm.org/svn/llvm-project/cfe/tags/RELEASE_31/final/ clang > /dev/null

cd "${LLVM_CHECKOUT_DIR}"

indented_status 2 "Configuring"

./configure --prefix="${LLVM_CLANG_BUILD_DIR}" --enable-optimized > /dev/null

indented_status 2 "Building"

# building twice, somehow first build fails.
make -j4 1> /dev/null 2>&1
make -j4 1> /dev/null

indented_status 2 "Installing"

make install > /dev/null

popd > /dev/null
