#!/bin/bash

OBJCLINT_DIR=llvm-3.1/tools/clang/examples/objclint

rm -rf "${OBJCLINT_DIR}"/*
cp -R src/* "$OBJCLINT_DIR" 
cd "$OBJCLINT_DIR"
make && make install
