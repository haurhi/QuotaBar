#!/bin/bash

# Build script for Quota Radar
# Usage: ./build.sh [debug|release]

set -e

CONFIG=${1:-debug}
BUILD_DIR=".build/${CONFIG}"

echo "🚀 Building Quota Radar (${CONFIG} mode)..."

# Check if Swift is available
if ! command -v swift &> /dev/null; then
    echo "❌ Swift not found. Please install Xcode."
    exit 1
fi

# Build
if [ "$CONFIG" = "release" ]; then
    swift build -c release
else
    swift build
fi

echo "✅ Build complete!"
echo ""
echo "To run:"
echo "  swift run QuotaRadar"
echo ""
echo "Or open in Xcode:"
echo "  open QuotaRadar.xcodeproj (after creating it)"
