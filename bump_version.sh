#!/bin/bash
set -e

VERSION=$1
if [ -z "$VERSION" ]; then
    echo "Usage: $0 <version>  (e.g. $0 2.5)"
    exit 1
fi

echo "Bumping version to $VERSION..."
plutil -replace CFBundleShortVersionString -string "$VERSION" Sources/Insomnia/Info.plist
plutil -replace CFBundleVersion -string "$VERSION" Sources/Insomnia/Info.plist

git add Sources/Insomnia/Info.plist
git commit -m "chore: bump version to $VERSION"
git tag "v$VERSION"
git push origin main
git push origin "v$VERSION"

echo "Tagged and pushed v$VERSION — CI will build the release draft."
