#!/bin/bash

export THIRDPARTY_DIR="`pwd`/thirdparty"

function exit_if_error {
    if [ $? -gt 0 ]; then
        echo "[-] $1"
        exit 1    
    fi
}

##### Check if not ran before ##########################

if [ "$(ls -A ${THIRDPARTY_DIR})" ]; then
    echo "[-] Try to cleanup ${THIRDPARTY_DIR} and run $0 again"
    exit 1
fi

########################################################

./scripts/setup_spidermonkey.sh && \
./scripts/setup_llvm.sh

exit_if_error "failed to setup"

echo
echo "#################################################"
echo
echo "Whew...That was a long trip..."
echo "Now run ./install.sh to build/install 'objclint'"
echo
echo "...Have fun..."
