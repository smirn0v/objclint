#!/bin/sh -e -o pipefail

export THIRDPARTY_DIR="`pwd`/thirdparty"
export STATUS_SH="`pwd`/scripts/status.sh"
export ERROR_LOG="objclint-setup-error.log"

function print_error {
    echo "$(tput bold)$(tput setaf 1)[-]$(tput init)$(tput bold) $1$(tput init)"
    echo
    exit 1
}

echo 
echo "Objclint 0.1 Alpha"
echo "=================="
echo

##### Check if not ran before ##########################

mkdir -p "${THIRDPARTY_DIR}"

if [ "$(ls -A ${THIRDPARTY_DIR})" ]; then
    print_error "Try to cleanup ${THIRDPARTY_DIR} and run $0 again"
fi

########################################################

exec 2>"${ERROR_LOG}"

set +e

START_TIME=$(date +%s)

./scripts/setup_spidermonkey.sh && \
./scripts/setup_llvm.sh

if [ $? -gt 0 ]; then print_error "Failed to setup. See ${ERROR_LOG} for details"; fi

END_TIME=$(date +%s)
DIFF_TIME=$(echo "scale=1;($END_TIME - $START_TIME)/60" | bc)

echo
echo "#################################################"
echo
echo "Whew, that was a long trip! Took ${DIFF_TIME} minutes."
echo "Now run ./install.sh to build/install 'objclint'"
echo
echo "...Have fun..."
echo
