#!/bin/bash

function exit_if_error {
    if [ $? -gt 0 ]; then
        echo "[-] $1"
        exit 1    
    fi
}

echo "[~] Building project"

xcodebuild -workspace objclint.xcodeproj/project.xcworkspace -scheme objclint TEST_AFTER_BUILD=NO clean build -configuration 'Release' CONFIGURATION_BUILD_DIR=./build 1>/dev/null

exit_if_error "Failed to build"

echo "[+] Success"
echo "[~] Going to install objclint to /opt/local/bin/"

sudo cp ./build/objclint /opt/local/bin/

exit_if_error "Failed to copy objclint"

echo "[+] Success"
echo "[~] Going to install objclint-xcodebuild to /opt/local/bin/"

sudo cp ./src/objclint-xcodebuild /opt/local/bin

exit_if_error "Failed to copy objclint-xcodebuild"

echo "[+] Success"
echo
echo "[+] Open your project directory and run 'objclint-xcodebuild'"
