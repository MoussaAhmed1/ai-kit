#!/bin/sh
set -e

# ai-kit installer — downloads the latest binary from GitHub releases
# Usage: curl -fsSL https://raw.githubusercontent.com/smicolon/ai-kit/main/scripts/install.sh | sh

REPO="smicolon/ai-kit"
INSTALL_DIR="${AI_KIT_INSTALL_DIR:-/usr/local/bin}"
BINARY_NAME="ai-kit"

# Detect OS and architecture
detect_platform() {
  OS="$(uname -s)"
  ARCH="$(uname -m)"

  case "$OS" in
    Darwin) os="darwin" ;;
    Linux)  os="linux" ;;
    *)
      echo "Error: Unsupported OS: $OS"
      exit 1
      ;;
  esac

  case "$ARCH" in
    x86_64|amd64)  arch="x64" ;;
    arm64|aarch64) arch="arm64" ;;
    *)
      echo "Error: Unsupported architecture: $ARCH"
      exit 1
      ;;
  esac

  echo "${os}-${arch}"
}

# Get latest release tag from GitHub
get_latest_version() {
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" | grep '"tag_name"' | sed 's/.*"tag_name": *"//;s/".*//'
  elif command -v wget >/dev/null 2>&1; then
    wget -qO- "https://api.github.com/repos/${REPO}/releases/latest" | grep '"tag_name"' | sed 's/.*"tag_name": *"//;s/".*//'
  else
    echo "Error: curl or wget required"
    exit 1
  fi
}

# Download and install
install() {
  PLATFORM="$(detect_platform)"
  VERSION="$(get_latest_version)"

  if [ -z "$VERSION" ]; then
    echo "Error: Could not determine latest version"
    exit 1
  fi

  URL="https://github.com/${REPO}/releases/download/${VERSION}/${BINARY_NAME}-${PLATFORM}.gz"

  echo "Installing ai-kit ${VERSION} (${PLATFORM})..."

  TMPDIR="$(mktemp -d)"
  trap 'rm -rf "$TMPDIR"' EXIT

  # Download
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$URL" -o "${TMPDIR}/${BINARY_NAME}.gz"
  else
    wget -qO "${TMPDIR}/${BINARY_NAME}.gz" "$URL"
  fi

  # Extract
  gzip -d "${TMPDIR}/${BINARY_NAME}.gz"
  chmod +x "${TMPDIR}/${BINARY_NAME}"

  # Install
  if [ -w "$INSTALL_DIR" ]; then
    mv "${TMPDIR}/${BINARY_NAME}" "${INSTALL_DIR}/${BINARY_NAME}"
  else
    echo "Installing to ${INSTALL_DIR} (requires sudo)..."
    sudo mv "${TMPDIR}/${BINARY_NAME}" "${INSTALL_DIR}/${BINARY_NAME}"
  fi

  echo "Installed ai-kit ${VERSION} to ${INSTALL_DIR}/${BINARY_NAME}"
  echo ""
  echo "Get started:"
  echo "  ai-kit init"
}

install
