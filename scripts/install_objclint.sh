#!/bin/sh -e -o pipefail

INSTALL_DIR="/opt/local"
COMMAND_PREFIX=""

function indented_status {
    "${STATUS_SH}" -i $1 "$2"
}

indented_status 0 "Installing objclint"

printf "Installation dir [default is '${INSTALL_DIR}']: "
read USER_DIR

if [ "$USER_DIR" != "" ]; then
    INSTALL_DIR="$USER_DIR"
fi

set +e

temp_file="${INSTALL_DIR}/objclint_tmp"
touch "${temp_file}" 2>/dev/null && rm -f "${temp_file}"
check_result=$?

if [ $check_result -gt 0 ]; then
    echo "Root required to install into ${INSTALL_DIR}"
    COMMAND_PREFIX="sudo"
fi

set -e

$COMMAND_PREFIX mkdir -p "${INSTALL_DIR}/bin"
$COMMAND_PREFIX cp ./build/objclint "${INSTALL_DIR}/bin/objclint-pseudo-compiler"
$COMMAND_PREFIX cp ./build/objclint-coordinator "${INSTALL_DIR}/bin/objclint-coordinator"
$COMMAND_PREFIX cp ./src/objclint-dispatcher.py "${INSTALL_DIR}/bin/"
$COMMAND_PREFIX cp ./src/objclint-xcodebuild "${INSTALL_DIR}/bin"
