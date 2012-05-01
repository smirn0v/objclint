#!/bin/bash

#
# Temprary install script
#

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

./build.sh 1> /dev/null && \
cp llvm-clang-build/lib/libobjclint.dylib /opt/local/lib/ && \
cp llvm-clang-build/bin/clang /opt/local/bin/objclint-clang && \
cp objclint /opt/local/bin/ && \
cp objclint-xcodebuild /opt/local/bin/ && \
echo "[+] Installed into /opt/local/"


