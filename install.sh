#!/bin/bash

#
# Temprary install script
#

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

./build.sh 

cp lib/* /opt/local/lib/
cp llvm-clang-build/bin/clang /opt/local/bin/objclint-clang
cp objclint /opt/local/bin/


