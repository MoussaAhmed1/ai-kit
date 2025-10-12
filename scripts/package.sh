#!/bin/bash

# Smicolon Claude Infrastructure - Package Creator
# Creates distributable tar.gz with version

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

# Get version from git tag or use date-based version
if git describe --tags --exact-match 2>/dev/null; then
    VERSION=$(git describe --tags --exact-match)
else
    VERSION="v$(date +%Y.%m.%d)"
fi

PACKAGE_NAME="smicolon-claude-${VERSION}.tar.gz"
OUTPUT_DIR="${REPO_DIR}/dist"

echo "Creating package: ${PACKAGE_NAME}"

# Create dist directory
mkdir -p "$OUTPUT_DIR"

# Create temporary directory for packaging
TEMP_DIR=$(mktemp -d)
PACKAGE_DIR="${TEMP_DIR}/smicolon-claude"

# Copy necessary files
mkdir -p "$PACKAGE_DIR"
cp -r "$REPO_DIR/smicolon" "$PACKAGE_DIR/"
cp -r "$REPO_DIR/scripts" "$PACKAGE_DIR/"
cp -r "$REPO_DIR/templates" "$PACKAGE_DIR/"
cp "$REPO_DIR/README.md" "$PACKAGE_DIR/"

# Create version file
echo "$VERSION" > "$PACKAGE_DIR/VERSION"

# Create the tarball
cd "$TEMP_DIR"
tar -czf "${OUTPUT_DIR}/${PACKAGE_NAME}" smicolon-claude/

# Cleanup
rm -rf "$TEMP_DIR"

echo "Package created: ${OUTPUT_DIR}/${PACKAGE_NAME}"
echo ""
echo "To distribute, host this file at a URL and users can install with:"
echo "curl -fsSL YOUR_URL/quick-install.sh | bash"
