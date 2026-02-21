#!/bin/bash
# Chris - get_libraries.sh
# Downloads all required C libraries to the lib/ directory.
# Run this once before building in Xcode.
# Based on Nugget Mobile's get_libraries.sh by leminlimez.

set -e

LIB_DIR="$(dirname "$0")/lib"
mkdir -p "$LIB_DIR"
cd "$LIB_DIR"

echo "==> Downloading minimuxer (SideStore)..."
wget -nc https://github.com/SideStore/MinimuxerPackage/raw/main/RustXcframework.xcframework/ios-arm64/libminimuxer-ios.a

echo "==> Downloading em_proxy (SideStore)..."
wget -nc https://github.com/SideStore/EMPackage/raw/main/RustXcframework.xcframework/ios-arm64/libem_proxy-ios.a

# Helper to extract a .deb package and pull out the static libraries
extract_deb() {
    local url="$1"
    local filename="${url##*/}"
    echo "==> Downloading $filename..."
    wget -nc "$url"
    echo "    Extracting $filename..."
    ar x "$filename"
    # .deb has either data.tar.gz, data.tar.xz, or data.tar.zst
    if [ -f data.tar.xz ]; then
        tar xJf data.tar.xz
    elif [ -f data.tar.gz ]; then
        tar xzf data.tar.gz
    elif [ -f data.tar.zst ]; then
        zstd -d data.tar.zst -o data.tar && tar xf data.tar
    fi
    # Copy all .a files up to lib/
    find . -name "*.a" -not -path "./$filename" | while read f; do
        cp "$f" .
        echo "    Extracted: $(basename $f)"
    done
    # Clean up deb artefacts
    rm -f debian-binary control.tar.* data.tar.* data.tar
}

echo ""
echo "==> Downloading libimobiledevice suite from Procursus..."

extract_deb "https://apt.procurs.us/pool/main/iphoneos-arm64/1700/libimobiledevice/libimobiledevice-dev_1.3.0+git20220702.2eec1b9-1_iphoneos-arm.deb"
extract_deb "https://apt.procurs.us/pool/main/iphoneos-arm64/1700/libimobiledevice-glue/libimobiledevice-glue-dev_1.0.0+git20220522.d2ff796_iphoneos-arm.deb"
extract_deb "https://apt.procurs.us/pool/main/iphoneos-arm64/1700/libplist/libplist-dev_2.2.0+git20230130.4b50a5a_iphoneos-arm.deb"
extract_deb "https://apt.procurs.us/pool/main/iphoneos-arm64/1700/libusbmuxd/libusbmuxd-dev_2.0.2+git20220504.36ffb7a_iphoneos-arm.deb"

echo ""
echo "==> Downloading OpenSSL (for libimobiledevice TLS)..."
# Using a prebuilt static OpenSSL for iOS arm64
wget -nc "https://github.com/nicholasstephan/openssl-xcode/releases/download/1.1.1q/openssl-1.1.1q-ios-arm64.tar.gz" || \
wget -nc "https://raw.githubusercontent.com/leehendryp/static-openssl-for-ios/master/lib/libcrypto.a" && \
wget -nc "https://raw.githubusercontent.com/leehendryp/static-openssl-for-ios/master/lib/libssl.a" || true

echo ""
echo "==> Library summary:"
ls -lh "$LIB_DIR"/*.a 2>/dev/null || echo "    (no .a files — check for errors above)"

echo ""
echo "✅ Done! All libraries downloaded to lib/"
echo "   Now open Chris.xcodeproj in Xcode and build."
