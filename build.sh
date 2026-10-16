#!/usr/bin/env bash
set -euo pipefail

APP_NAME="DisplayControl"
SRC_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_BUNDLE="/Applications/${APP_NAME}.app"
CONTENTS="${APP_BUNDLE}/Contents"
MACOS="${CONTENTS}/MacOS"
RESOURCES="${CONTENTS}/Resources"

mkdir -p "${MACOS}" "${RESOURCES}"

cat > "${CONTENTS}/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>com.local.${APP_NAME}</string>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundleDisplayName</key>
    <string>${APP_NAME}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>26.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF
swiftc -target arm64-apple-macosx26.0 -parse-as-library "${SRC_DIR}/DisplayControl.swift" "${SRC_DIR}/Components.swift" "${SRC_DIR}/Subpanels.swift" "${SRC_DIR}/MenuPopoverView.swift" \
    -O \
    -o "${MACOS}/${APP_NAME}" \
    -F /System/Library/PrivateFrameworks \
    -framework AppKit \
    -framework SwiftUI \
    -framework CoreGraphics \
    -framework CoreDisplay \
    -framework SkyLight \
    -framework DisplayServices \
    -framework IOKit \
    -framework QuartzCore

codesign --force --deep --sign - "${APP_BUNDLE}"
echo "Built and signed ${APP_BUNDLE}"
