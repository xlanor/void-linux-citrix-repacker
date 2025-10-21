#!/bin/bash
#
# Build Citrix ICA Client .xbps package from .deb file
# Usage: ./build-xbps.sh /path/to/icaclient_X.X.X.X_amd64.deb
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VOID_PACKAGES_DIR="${VOID_PACKAGES_DIR:-$HOME/void-packages}"

echo "===== Citrix ICA Client XBPS Builder ====="
echo ""

# Check arguments
if [ $# -ne 1 ]; then
    echo "Usage: $0 <path-to-icaclient.deb>"
    echo ""
    echo "Example:"
    echo "  $0 ~/Downloads/icaclient_25.08.0.88_amd64.deb"
    echo ""
    echo "Download the .deb from: https://www.citrix.com/downloads/workspace-app/linux/"
    exit 1
fi

DEB_FILE="$1"

if [ ! -f "$DEB_FILE" ]; then
    echo "Error: File not found: $DEB_FILE"
    exit 1
fi

# Extract version from filename
FILENAME=$(basename "$DEB_FILE")
if [[ "$FILENAME" =~ icaclient_([0-9.]+)_amd64\.deb ]]; then
    VERSION="${BASH_REMATCH[1]}"
    echo "✓ Detected version: $VERSION"
else
    echo "Error: Could not parse version from filename"
    echo "Expected format: icaclient_X.X.X.X_amd64.deb"
    exit 1
fi

# Check for void-packages
if [ ! -f "$VOID_PACKAGES_DIR/xbps-src" ]; then
    echo ""
    echo "Error: void-packages not found at $VOID_PACKAGES_DIR"
    echo ""
    echo "Please clone void-packages first:"
    echo "  git clone https://github.com/void-linux/void-packages.git ~/void-packages"
    echo "  cd ~/void-packages"
    echo "  ./xbps-src binary-bootstrap"
    echo ""
    echo "Or set VOID_PACKAGES_DIR to your void-packages location:"
    echo "  VOID_PACKAGES_DIR=/path/to/void-packages $0 $DEB_FILE"
    exit 1
fi

echo "✓ Using void-packages at: $VOID_PACKAGES_DIR"
echo ""

# Copy template to void-packages
echo "→ Copying template to void-packages..."
rm -rf "$VOID_PACKAGES_DIR/srcpkgs/icaclient"
cp -r "$SCRIPT_DIR/srcpkgs/icaclient" "$VOID_PACKAGES_DIR/srcpkgs/"

# Update version in template if different
CURRENT_VERSION=$(grep "^version=" "$VOID_PACKAGES_DIR/srcpkgs/icaclient/template" | cut -d= -f2)
if [ "$VERSION" != "$CURRENT_VERSION" ]; then
    echo "→ Updating template version from $CURRENT_VERSION to $VERSION..."
    sed -i "s/^version=.*/version=$VERSION/" "$VOID_PACKAGES_DIR/srcpkgs/icaclient/template"
    sed -i "s/^revision=.*/revision=1/" "$VOID_PACKAGES_DIR/srcpkgs/icaclient/template"
fi

# Create sources directory and copy .deb
SOURCE_DIR="$VOID_PACKAGES_DIR/hostdir/sources/icaclient-$VERSION"
echo "→ Placing .deb in sources directory..."
mkdir -p "$SOURCE_DIR"
cp "$DEB_FILE" "$SOURCE_DIR/"

echo "✓ Setup complete"
echo ""

# Build the package
echo "→ Building package..."
cd "$VOID_PACKAGES_DIR"
./xbps-src pkg icaclient

if [ $? -ne 0 ]; then
    echo ""
    echo "✗ Build failed!"
    exit 1
fi

echo ""
echo "===== Build Successful! ====="
echo ""

# Find the built package
BUILT_PKG=$(find "$VOID_PACKAGES_DIR/hostdir/binpkgs" -name "icaclient-${VERSION}_*.xbps" -type f | head -1)

if [ -z "$BUILT_PKG" ]; then
    echo "✗ Could not find built package"
    exit 1
fi

echo "✓ Package created: $BUILT_PKG"
echo ""
echo "To install:"
echo "  sudo xbps-install -R $VOID_PACKAGES_DIR/hostdir/binpkgs/nonfree icaclient"
echo ""
echo ""
