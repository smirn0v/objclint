#!/bin/sh -e -o pipefail

export THIRDPARTY_DIR="`pwd`/thirdparty"
export STATUS_SH="`pwd`/scripts/status.sh"
export ERROR_LOG="objclint-setup-error.log"

function exit_error {
    "${STATUS_SH}" -e "$1"
    echo
    exit 1
}

echo 
echo "Objclint 0.1 Alpha"
echo "=================="
echo

mkdir -p "${THIRDPARTY_DIR}"

exec 2>"${ERROR_LOG}"

set +e

START_TIME=$(date +%s)

./scripts/setup_spidermonkey.sh && \
./scripts/setup_llvm.sh && \
./scripts/build_objclint.sh && \
./scripts/install_objclint.sh

if [ $? -gt 0 ]; then exit_error "Failed to setup. See ${ERROR_LOG} for details"; fi

END_TIME=$(date +%s)
DIFF_TIME=$(echo "scale=1;($END_TIME - $START_TIME)/60" | bc)

echo
echo "#################################################"
echo
echo "Whew, that was a long trip! Took ${DIFF_TIME} minutes."
echo "Now you can open your project directory and run 'objclint-xcodebuild'"
echo
echo "...Have fun..."
echo
