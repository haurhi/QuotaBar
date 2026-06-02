#!/bin/bash

# Setup script for QuotaBar

set -e

echo "🚀 Setting up QuotaBar..."

# Check for Xcode
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Xcode not found. Please install Xcode from the App Store."
    exit 1
fi

# Change to project directory
cd "$(dirname "$0")"

# Create Xcode project if it doesn't exist
if [ ! -d "QuotaBar.xcodeproj" ]; then
    echo "📦 Creating Xcode project..."

    # Use swift package to generate Xcode project
    swift package generate-xcodeproj 2>/dev/null || true

    # If that fails, provide manual instructions
    if [ ! -d "QuotaBar.xcodeproj" ]; then
        echo ""
        echo "⚠️  Automatic project creation failed."
        echo ""
        echo "Please create the Xcode project manually:"
        echo ""
        echo "1. Open Xcode"
        echo "2. File → New → Project"
        echo "3. Select 'App' under macOS"
        echo "4. Configure:"
        echo "   - Name: QuotaBar"
        echo "   - Team: Your Apple ID"
        echo "   - Organization: (optional)"
        echo "   - Interface: SwiftUI"
        echo "   - Language: Swift"
        echo "5. Save to: ~/work/other/QuotaBar/"
        echo "6. Replace the generated files with the ones in this folder"
        echo ""
        exit 0
    fi
fi

echo "✅ Setup complete!"
echo ""
echo "To build and run:"
echo "  open QuotaBar.xcodeproj"
echo ""
echo "Or use the command line:"
echo "  xcodebuild -project QuotaBar.xcodeproj -scheme QuotaBar build"
