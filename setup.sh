#!/bin/sh -e -o pipefail

export THIRDPARTY_DIR="`pwd`/thirdparty"
export STATUS_SH="`pwd`/scripts/status.sh"

echo 
echo "Objclint 0.1 Alpha"
echo "=================="
echo

##### Check if not ran before ##########################

mkdir -p "${THIRDPARTY_DIR}"

if [ "$(ls -A ${THIRDPARTY_DIR})" ]; then
    echo "$(tput bold)$(tput setaf 1)[-] $(tput init)Try to cleanup ${THIRDPARTY_DIR} and run $0 again"
    echo
    exit 1
fi

########################################################

./scripts/setup_spidermonkey.sh
./scripts/setup_llvm.sh

echo
echo "#################################################"
echo
echo "Whew...That was a long trip..."
echo "Now run ./install.sh to build/install 'objclint'"
echo
echo "...Have fun..."
