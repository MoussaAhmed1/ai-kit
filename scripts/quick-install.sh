#!/bin/bash

# Smicolon Claude Infrastructure - Quick Installer
# One-line installation: curl -fsSL YOUR_URL/quick-install.sh | bash

set -e

# Configuration - Update these with your hosting location
PACKAGE_BASE_URL="${SMICOLON_PACKAGE_URL:-https://your-company-cdn.com/smicolon-claude}"
CHANNEL="${SMICOLON_CHANNEL:-production}"  # production, dev, beta
LATEST_VERSION="latest"  # Or specific version like "v2024.01.15"

echo "Smicolon Claude Code Infrastructure - Quick Install"
echo "=================================================="
echo ""

# Detect if running as global install
GLOBAL_INSTALL=true
if [ "$1" = "--project" ]; then
    GLOBAL_INSTALL=false
fi

# Download package
TEMP_DIR=$(mktemp -d)
PACKAGE_FILE="${TEMP_DIR}/smicolon-claude.tar.gz"

echo "Downloading from channel: $CHANNEL"
if command -v curl &> /dev/null; then
    curl -fsSL "${PACKAGE_BASE_URL}/${CHANNEL}/smicolon-claude-${LATEST_VERSION}.tar.gz" -o "$PACKAGE_FILE"
elif command -v wget &> /dev/null; then
    wget -q "${PACKAGE_BASE_URL}/${CHANNEL}/smicolon-claude-${LATEST_VERSION}.tar.gz" -O "$PACKAGE_FILE"
else
    echo "Error: curl or wget required"
    exit 1
fi

# Extract
echo "Extracting..."
tar -xzf "$PACKAGE_FILE" -C "$TEMP_DIR"

# Run installer
cd "${TEMP_DIR}/smicolon-claude"
if [ "$GLOBAL_INSTALL" = true ]; then
    bash scripts/install.sh --global
else
    bash scripts/install.sh
fi

# Cleanup
rm -rf "$TEMP_DIR"

echo ""
echo "Installation complete!"
if [ "$GLOBAL_INSTALL" = true ]; then
    echo "Run 'source ~/.zshrc' or 'source ~/.bashrc' to use 'smicolon-init' command"
fi
