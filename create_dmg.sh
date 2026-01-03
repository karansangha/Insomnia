#!/bin/bash
set -e

APP_NAME="Insomnia"
DMG_NAME="${APP_NAME}_Installer.dmg"
APP_BUNDLE="${APP_NAME}.app"

# Ensure the app is built
if [ ! -d "${APP_BUNDLE}" ]; then
    echo "App bundle not found. Running build script..."
    ./install_app.sh
fi

echo "Creating DMG..."

# Create a temporary directory for the DMG contents
STAGING_DIR="dmg_staging"
rm -rf "${STAGING_DIR}"
mkdir "${STAGING_DIR}"

# Copy the App to the staging directory
cp -r "${APP_BUNDLE}" "${STAGING_DIR}/"

# Create a symbolic link to /Applications
ln -s /Applications "${STAGING_DIR}/Applications"

# Create the DMG
rm -f "${DMG_NAME}"
hdiutil create -volname "${APP_NAME}" -srcfolder "${STAGING_DIR}" -ov -format UDZO "${DMG_NAME}"

# Cleanup
rm -rf "${STAGING_DIR}"

echo "------------------------------------------------"
echo "DMG Created: $(pwd)/${DMG_NAME}"
echo "------------------------------------------------"
