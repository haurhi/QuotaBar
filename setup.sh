#!/bin/bash

# Setup script for Quota Radar

set -e

echo "🚀 Setting up Quota Radar..."

# Check for Xcode
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Xcode not found. Please install Xcode from the App Store."
    exit 1
fi

# Change to project directory
cd "$(dirname "$0")"

# Create Xcode project if it doesn't exist
if [ ! -d "QuotaRadar.xcodeproj" ]; then
    echo "📦 Creating Xcode project..."

    # Use swift package to generate Xcode project
    swift package generate-xcodeproj 2>/dev/null || true

    # If that fails, provide manual instructions
    if [ ! -d "QuotaRadar.xcodeproj" ]; then
        echo ""
        echo "⚠️  Automatic project creation failed."
        echo ""
        echo "Please create the Xcode project manually:"
        echo ""
        echo "1. Open Xcode"
        echo "2. File → New → Project"
        echo "3. Select 'App' under macOS"
        echo "4. Configure:"
        echo "   - Product Name: QuotaRadar"
        echo "   - Display Name: Quota Radar"
        echo "   - Team: Your Apple ID"
        echo "   - Organization: (optional)"
        echo "   - Interface: SwiftUI"
        echo "   - Language: Swift"
        echo "5. Save to: ~/work/other/QuotaRadar/"
        echo "6. Replace the generated files with the ones in this folder"
        echo ""
        exit 0
    fi
fi

echo "✅ Setup complete!"
echo ""
echo "To build and run:"
echo "  open QuotaRadar.xcodeproj"
echo ""
echo "Or use the command line:"
echo "  xcodebuild -project QuotaRadar.xcodeproj -scheme QuotaRadar build"
