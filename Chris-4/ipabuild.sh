#!/bin/bash
# ipabuild.sh — Build Chris.ipa using only Xcode (no Theos needed)
#
# Usage:
#   ./get_libraries.sh      (first time only)
#   ./ipabuild.sh
#
# Output: Chris.ipa in the project root.

set -e

SCHEME="Chris"
PROJECT="Chris.xcodeproj"
ARCHIVE="build/Chris.xcarchive"
EXPORT="build/ChrisExport"
IPA_NAME="Chris.ipa"

# ── Check prerequisites ────────────────────────────────────────────────────────
if [ ! -d "lib" ] || [ -z "$(ls lib/*.a 2>/dev/null)" ]; then
    echo "❌ Libraries not found. Run ./get_libraries.sh first."
    exit 1
fi

# ── Clean ──────────────────────────────────────────────────────────────────────
echo "==> Cleaning build folder..."
rm -rf build
mkdir -p build

# ── Archive ────────────────────────────────────────────────────────────────────
echo "==> Archiving $SCHEME..."
xcodebuild archive \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -destination "generic/platform=iOS" \
    -archivePath "$ARCHIVE" \
    CODE_SIGN_IDENTITY="-" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO \
    ONLY_ACTIVE_ARCH=NO \
    | xcpretty || true

if [ ! -d "$ARCHIVE" ]; then
    echo "❌ Archive failed. Check Xcode output above."
    exit 1
fi

# ── Package as IPA ─────────────────────────────────────────────────────────────
echo "==> Packaging IPA..."
APP_PATH="$ARCHIVE/Products/Applications/Chris.app"

if [ ! -d "$APP_PATH" ]; then
    echo "❌ Chris.app not found in archive."
    exit 1
fi

mkdir -p "$EXPORT/Payload"
cp -r "$APP_PATH" "$EXPORT/Payload/"
cd "$EXPORT"
zip -r "../../$IPA_NAME" Payload/
cd ../..

echo ""
echo "✅ Build complete: $IPA_NAME"
echo ""
echo "   Install with:"
echo "   • TrollStore:  AirDrop Chris.ipa to your iPhone"
echo "   • AltStore:    Use AltServer on your Mac"
echo "   • Sideloadly:  Drag Chris.ipa into Sideloadly"
