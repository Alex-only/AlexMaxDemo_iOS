#!/bin/sh

# workspace 工程名，如果是单 target 项目则不需要
PROJECT_NAME='MaxCustomSDK'
# target 名
TARGET_NAME="MaxSDKAdapter"
# 工程文件所在的根目录
SRCROOT='.'

# Sets the target folders and the final framework product.
FMK_NAME='MaxSDKAdapter'

# sdk 编译过程的输出文件路径
WRK_DIR=./build
# framework 形式真机架构输出文件路径
DEVICE_DIR=${WRK_DIR}/Release-iphoneos/${FMK_NAME}/${FMK_NAME}.framework
# framework 形式模拟器架构输出文件路径
SIMULATOR_DIR=${WRK_DIR}/Release-iphonesimulator/${FMK_NAME}/${FMK_NAME}.framework

# 包含 workspace 的项目
xcodebuild -configuration Release -workspace "${PROJECT_NAME}.xcworkspace" -scheme "${TARGET_NAME}" -sdk iphoneos clean  build SYMROOT="../${WRK_DIR}"
xcodebuild -configuration Release -workspace "${PROJECT_NAME}.xcworkspace" -scheme "${TARGET_NAME}" -sdk iphonesimulator build SYMROOT="../${WRK_DIR}"
if [ -d "${WRK_DIR}/_CodeSignature" ]
then
rm -rf "${WRK_DIR}/_CodeSignature"
fi

if [ -f "${WRK_DIR}/Info.plist" ]
then
rm "${WRK_DIR}/Info.plist"
fi
