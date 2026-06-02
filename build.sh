#!/bin/bash

# Build script for QuotaBar
# Usage: ./build.sh [debug|release]

set -e

CONFIG=${1:-debug}
BUILD_DIR=".build/${CONFIG}"

echo "🚀 Building QuotaBar (${CONFIG} mode)..."

# Check if Swift is available
if ! command -v swift &> /dev/null; then
    echo "❌ Swift not found. Please install Xcode."
    exit 1
fi

# Build
if [ "$CONFIG" = "release" ]; then
    swift build -c release
    APP_PATH=".build/release/QuotaBar.app"
else
    swift build
    APP_PATH=".build/debug/QuotaBar.app"
fi

echo "✅ Build complete!"
echo ""
echo "To run:"
echo "  swift run"
echo ""
echo "Or open in Xcode:"
echo "  open QuotaBar.xcodeproj (after creating it)"
