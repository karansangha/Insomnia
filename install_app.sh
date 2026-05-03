#!/bin/bash
set -e

APP_NAME="Insomnia"
BUILD_DIR=".build/release"
APP_BUNDLE="${APP_NAME}.app"
CONTENTS_DIR="${APP_BUNDLE}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"
RESOURCES_DIR="${CONTENTS_DIR}/Resources"

echo "Using Swift Version: $(swift --version)"

echo "Building ${APP_NAME} in release mode..."
swift build -c release

# Create .app structure
echo "Creating ${APP_BUNDLE} structure..."
rm -rf "${APP_BUNDLE}"
mkdir -p "${MACOS_DIR}"
mkdir -p "${RESOURCES_DIR}"

# Copy executable
cp "${BUILD_DIR}/${APP_NAME}" "${MACOS_DIR}/"

# Copy resources (if they exist in a bundle)
# SPM resources are often in a separate bundle or adjacent. 
# For 'process' resources in executable, they might be inside the binary or in a separate bundle directory.
# We'll check for the bundle.
RESOURCE_BUNDLE="${BUILD_DIR}/${APP_NAME}_${APP_NAME}Core.bundle"
if [ -d "$RESOURCE_BUNDLE" ]; then
    echo "Copying resources from ${RESOURCE_BUNDLE}..."
    cp -r "$RESOURCE_BUNDLE" "${RESOURCES_DIR}/"
fi
# Also check for direct assets if strictly executable
RESOURCE_BUNDLE_2="${BUILD_DIR}/${APP_NAME}_${APP_NAME}.bundle"
if [ -d "$RESOURCE_BUNDLE_2" ]; then
    echo "Copying resources from ${RESOURCE_BUNDLE_2}..."
    cp -r "$RESOURCE_BUNDLE_2" "${RESOURCES_DIR}/"
fi

# Create Info.plist
# We read the one from local if available, or generate a minimal one
if [ -f "Sources/Insomnia/Info.plist" ]; then
    echo "Copying and configuring Info.plist..."
    cp "Sources/Insomnia/Info.plist" "${CONTENTS_DIR}/Info.plist"
    # Replace Xcode variables
    sed -i '' 's/$(EXECUTABLE_NAME)/'"${APP_NAME}"'/g' "${CONTENTS_DIR}/Info.plist"
    sed -i '' 's/$(PRODUCT_NAME)/'"${APP_NAME}"'/g' "${CONTENTS_DIR}/Info.plist"
    sed -i '' 's/$(PRODUCT_BUNDLE_IDENTIFIER)/com.karansangha.'"${APP_NAME}"'/g' "${CONTENTS_DIR}/Info.plist"
    sed -i '' 's/$(MACOSX_DEPLOYMENT_TARGET)/13.0/g' "${CONTENTS_DIR}/Info.plist"
    sed -i '' 's/$(DEVELOPMENT_LANGUAGE)/en/g' "${CONTENTS_DIR}/Info.plist"
else
    echo "Generating Info.plist..."
    cat > "${CONTENTS_DIR}/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>com.karansangha.${APP_NAME}</string>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>LSUIElement</key>
    <true/>
</dict>
</plist>
EOF
fi

# Need to handle icon specifically if it's in Assets.xcassets
# Compilation usually handles this if we use xcodebuild, but with SPM it's trickier.
# For now, we rely on the resources copied above. If AppIcon is in xcassets, it needs to be compiled to icns.
# We'll skip complex icon compilation for this simple script unless the user has 'iconutil'.
if [ -d "Sources/Insomnia/Assets.xcassets/AppIcon.appiconset" ]; then
    echo "Compiling AppIcon..."
    if xcrun actool Sources/Insomnia/Assets.xcassets --compile "${RESOURCES_DIR}" --platform macosx --minimum-deployment-target 13.0 --app-icon AppIcon --output-partial-info-plist /tmp/partial.plist; then
        echo "Asset compilation successful."
    else
        echo "Warning: icon compilation failed. Falling back to copying raw images."
        # Copy raw pngs to Resources root so Image("name") can find them
        find Sources/Insomnia/Assets.xcassets -name "*.png" -exec cp {} "${RESOURCES_DIR}/" \;
    fi
fi

# Ad-hoc sign the app to prevent some local Gatekeeper/Permission issues
echo "Signing app (ad-hoc)..."
codesign --force --deep --sign - "${APP_BUNDLE}"

echo "------------------------------------------------"
echo "Done! App created at $(pwd)/${APP_BUNDLE}"
echo "To install: mv ${APP_BUNDLE} /Applications/"
echo "To run: open ${APP_BUNDLE}"
echo "------------------------------------------------"
