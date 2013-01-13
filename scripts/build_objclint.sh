#!/bin/sh -e -o pipefail

function indented_status {
    "${STATUS_SH}" -i $1 "$2"
}

indented_status 0 "Building Objclint project"

indented_status 2 "Building objclint"
xcodebuild -workspace objclint.xcodeproj/project.xcworkspace -scheme objclint TEST_AFTER_BUILD=NO clean build -configuration 'Release' CONFIGURATION_BUILD_DIR=./build 1>/dev/null

indented_status 2 "Building objclint-coordinator"
xcodebuild -workspace objclint.xcodeproj/project.xcworkspace -scheme objclint-coordinator TEST_AFTER_BUILD=NO clean build -configuration 'Release' CONFIGURATION_BUILD_DIR=./build 1>/dev/null
