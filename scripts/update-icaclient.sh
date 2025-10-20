#!/bin/bash
#
# Helper script to update the icaclient template for new versions
# Usage: ./update-icaclient.sh <path-to-new-icaclient.deb>
#

set -e

if [ $# -ne 1 ]; then
    echo "Usage: $0 <path-to-icaclient.deb>"
    echo "Example: $0 icaclient_25.08.0.88_amd64.deb"
    exit 1
fi

DEB_FILE="$1"

if [ ! -f "$DEB_FILE" ]; then
    echo "Error: File '$DEB_FILE' not found"
    exit 1
fi

echo "===== ICA Client Template Update Script ====="
echo ""

# Extract version from filename
FILENAME=$(basename "$DEB_FILE")
if [[ "$FILENAME" =~ icaclient_([0-9.]+)_amd64\.deb ]]; then
    VERSION="${BASH_REMATCH[1]}"
    echo "Detected version: $VERSION"
else
    echo "Error: Could not parse version from filename"
    echo "Expected format: icaclient_X.X.X.X_amd64.deb"
    exit 1
fi

# Calculate checksum
echo ""
echo "Calculating SHA256 checksum..."
CHECKSUM=$(sha256sum "$DEB_FILE" | cut -d' ' -f1)
echo "Checksum: $CHECKSUM"

# Create temporary directory for extraction
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

echo ""
echo "Extracting package information..."

# Extract the .deb
cd "$TEMP_DIR"
ar x "$(realpath "$DEB_FILE")"
tar -xf control.tar.xz

# Read package info
if [ ! -f control ]; then
    echo "Error: Could not find control file in package"
    exit 1
fi

echo ""
echo "===== Package Information ====="
grep "^Package:" control
grep "^Version:" control
grep "^Architecture:" control
grep "^Description:" control

echo ""
echo "===== Dependencies ====="
grep "^Depends:" control

echo ""
echo "===== Recommended packages ====="
grep "^Recommends:" control || echo "(none)"

# Extract data to check for systemd services
tar -xf data.tar.xz

echo ""
echo "===== Services found ====="
find . -name "*.service" 2>/dev/null || echo "(none found)"

echo ""
echo "===== Init scripts found ====="
find ./etc/init.d -type f 2>/dev/null || echo "(none found)"

echo ""
echo "===== Desktop files ====="
find ./usr/share/applications -name "*.desktop" 2>/dev/null | wc -l | xargs echo "Found desktop files:"

cd - > /dev/null

# Generate template snippet
echo ""
echo "===== Template Update ====="
echo ""
echo "Update srcpkgs/icaclient/template with the following:"
echo ""
echo "version=$VERSION"
echo "checksum=$CHECKSUM"
echo ""

# Check if template exists and offer to update
if [ -f "srcpkgs/icaclient/template" ]; then
    echo "Current template found. Update it now? (y/n)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        # Backup current template
        cp srcpkgs/icaclient/template srcpkgs/icaclient/template.bak
        echo "Backed up current template to template.bak"

        # Update version and checksum
        sed -i "s/^version=.*/version=$VERSION/" srcpkgs/icaclient/template
        sed -i "s/^checksum=.*/checksum=$CHECKSUM/" srcpkgs/icaclient/template

        # Reset revision to 1 for new version
        sed -i "s/^revision=.*/revision=1/" srcpkgs/icaclient/template

        echo "Template updated!"
        echo ""
        echo "Changes made:"
        echo "  - Updated version to $VERSION"
        echo "  - Updated checksum to $CHECKSUM"
        echo "  - Reset revision to 1"
        echo ""
        echo "Please review the changes and update the maintainer info if needed."
        echo "Also verify dependencies haven't changed significantly."
    fi
else
    echo "Template not found at srcpkgs/icaclient/template"
    echo "Please create it manually or run this script from the correct directory"
fi

echo ""
echo "===== Dependency Mapping Reference ====="
echo "Remember to check if any dependencies have changed and map them to Void packages:"
echo ""
echo "Debian Package          -> Void Package"
echo "================================================"
echo "libc6                   -> glibc"
echo "libgtk2.0-0             -> gtk+"
echo "libice6                 -> libICE"
echo "libsm6                  -> libSM"
echo "libx11-6                -> libX11"
echo "libxext6                -> libXext"
echo "libxmu6                 -> libXmu"
echo "libxpm4                 -> libXpm"
echo "libasound2              -> alsa-lib"
echo "libstdc++6              -> libstdc++"
echo "libidn11/libidn12       -> libidn2"
echo "zlib1g                  -> zlib"
echo "libcurl4                -> libcurl"
echo "libsqlite3-0            -> libsqlite"
echo "libspeexdsp1            -> speexdsp"
echo "libva2                  -> libva2"
echo "libwebkit2gtk-4.0-37    -> webkit2gtk"
echo "gstreamer1.0-libav      -> gst-libav"
echo "gstreamer1.0-plugins-bad -> gst-plugins-bad1"
echo ""

echo "===== Next Steps ====="
echo "1. Copy $DEB_FILE to your xbps-src source directory:"
echo "   mkdir -p void-packages/hostdir/sources/icaclient-$VERSION"
echo "   cp $DEB_FILE void-packages/hostdir/sources/icaclient-$VERSION/"
echo ""
echo "2. Review and test the updated template"
echo ""
echo "3. Build the package:"
echo "   cd void-packages"
echo "   ./xbps-src pkg icaclient"
echo ""
echo "4. Test installation:"
echo "   xi icaclient"
echo ""
