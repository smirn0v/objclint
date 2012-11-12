#!/bin/bash

xcodebuild -workspace objclint.xcodeproj/project.xcworkspace -scheme objclint TEST_AFTER_BUILD=NO clean build -configuration 'Release' CONFIGURATION_BUILD_DIR=./build
