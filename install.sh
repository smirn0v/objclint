#!/bin/bash

function exit_if_error {
    if [ $? -gt 0 ]; then
        echo "[-] $1"
        exit 1    
    fi
}

echo "[~] Building project"

xcodebuild -workspace objclint.xcodeproj/project.xcworkspace -scheme objclint TEST_AFTER_BUILD=NO clean build -configuration 'Release' CONFIGURATION_BUILD_DIR=./build 1>/dev/null
exit_if_error "Failed to build objclint"

xcodebuild -workspace objclint.xcodeproj/project.xcworkspace -scheme objclint-coordinator TEST_AFTER_BUILD=NO clean build -configuration 'Release' CONFIGURATION_BUILD_DIR=./build 1>/dev/null
exit_if_error "Failed to build objclint-coordinator"

echo "[+] Success"
echo

echo "[~] Going to install objclint-fake-compiler to /opt/local/bin/"

sudo cp ./build/objclint /opt/local/bin/objclint-fake-compiler

exit_if_error "Failed to copy objclint-fake-compiler"

echo "[+] Success"
echo

echo "[~] Going to install objclint-coordinator to /opt/local/bin"

sudo cp ./build/objclint-coordinator /opt/local/bin/objclint-coordinator
exit_if_error "Failed to copy objclint-coordinator"

echo "[+] Success"
echo 

echo "[~] Going to install objclint-dispatcher.py to /opt/local/bin"

sudo cp ./src/objclint-dispatcher.py /opt/local/bin/
exit_if_error "Failed to copy objclint-dispatcher"

echo "[+] Success"
echo

echo "[~] Going to install objclint-xcodebuild to /opt/local/bin/"

sudo cp ./src/objclint-xcodebuild /opt/local/bin

exit_if_error "Failed to copy objclint-xcodebuild"

echo "[+] Success"
echo

echo "[~] Going to copy default lint scripts into /opt/local/share/objclint-validators"

sudo mkdir -p /opt/local/share/objclint-validators
exit_if_error "Failed to create objclint-validators folder"

sudo cp ./src/lint-checkers/*.js /opt/local/share/objclint-validators/
exit_if_error "Failed to copy scripts"

echo "[+] Open your project directory and run 'objclint-xcodebuild'"
