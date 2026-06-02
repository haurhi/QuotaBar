#!/bin/bash

# Build and install QuotaBar.
# Run: ./install.sh to install the existing build/QuotaBar.app when present.
# Run: ./install.sh --rebuild to rebuild and install.
# Run: ./install.sh --bundle-only --rebuild to create build/QuotaBar.app without copying to /Applications.

set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_NAME="QuotaBar"
BUILD_DIR="${PROJECT_DIR}/build"
BUNDLE_ONLY=false
REBUILD=false

for arg in "$@"; do
    case "$arg" in
        --bundle-only)
            BUNDLE_ONLY=true
            ;;
        --rebuild)
            REBUILD=true
            ;;
        *)
            echo "❌ Unknown option: $arg"
            echo "Usage: ./install.sh [--bundle-only] [--rebuild]"
            exit 1
            ;;
    esac
done

APP_BUNDLE="${BUILD_DIR}/${APP_NAME}.app"

if [ -d "${APP_BUNDLE}" ] && [ "${REBUILD}" = false ]; then
    echo "📦 Using existing app bundle: ${APP_BUNDLE}"
else
    echo "🚀 Building ${APP_NAME}..."
    REBUILD=true
fi

echo "📁 Project: ${PROJECT_DIR}"

# Create build directory
mkdir -p "${BUILD_DIR}"

if [ "${REBUILD}" = true ]; then
    # Check for Xcode
    if ! command -v xcodebuild &> /dev/null; then
        echo "❌ Xcode not found. Please install Xcode from the App Store."
        exit 1
    fi

    # Build the app
    echo "🔨 Building Release version..."
    cd "${PROJECT_DIR}"

    # Use swift package manager to build
    swift build -c release 2>&1 | tee "${BUILD_DIR}/build.log" || {
        echo "❌ Build failed. Check ${BUILD_DIR}/build.log"
        exit 1
    }

    # Find the built executable
    EXECUTABLE="${PROJECT_DIR}/.build/release/${APP_NAME}"

    if [ ! -f "${EXECUTABLE}" ]; then
        echo "❌ Executable not found at ${EXECUTABLE}"
        echo "🔍 Searching for executable..."
        find "${PROJECT_DIR}/.build" -name "${APP_NAME}" -type f 2>/dev/null | head -5
        exit 1
    fi

    echo "✅ Build successful!"
    echo "📦 Creating App Bundle..."

    # Create app bundle structure
    CONTENTS="${APP_BUNDLE}/Contents"
    MACOS="${CONTENTS}/MacOS"
    RESOURCES="${CONTENTS}/Resources"

    rm -rf "${APP_BUNDLE}"
    mkdir -p "${MACOS}" "${RESOURCES}"

    # Copy executable
    cp "${EXECUTABLE}" "${MACOS}/${APP_NAME}"

    # Copy resources
    cp "${PROJECT_DIR}/${APP_NAME}/Info.plist" "${CONTENTS}/Info.plist"
    cp "${PROJECT_DIR}/${APP_NAME}/QuotaBar.entitlements" "${RESOURCES}/" 2>/dev/null || true
    cp "${PROJECT_DIR}/${APP_NAME}/Resources/QuotaBar.icns" "${RESOURCES}/QuotaBar.icns"

    RESOURCE_BUNDLE="${PROJECT_DIR}/.build/release/${APP_NAME}_${APP_NAME}.bundle"
    if [ -d "${RESOURCE_BUNDLE}" ]; then
        cp -R "${RESOURCE_BUNDLE}" "${RESOURCES}/"
    fi

    # Create PkgInfo
    echo "APPL????" > "${CONTENTS}/PkgInfo"

    if command -v codesign &> /dev/null; then
        echo "🔏 Ad-hoc signing app bundle..."
        codesign --force --deep --sign - "${APP_BUNDLE}" >/dev/null
    fi
fi

if command -v xattr &> /dev/null; then
    echo "🧹 Clearing quarantine attributes..."
    xattr -dr com.apple.quarantine "${APP_BUNDLE}" 2>/dev/null || true
fi

echo "📝 App Bundle Info:"
echo "   Location: ${APP_BUNDLE}"
echo "   Executable: ${APP_BUNDLE}/Contents/MacOS/${APP_NAME}"
echo "   Size: $(du -sh "${APP_BUNDLE}" | cut -f1)"

if [ "${BUNDLE_ONLY}" = true ]; then
    echo "✅ Bundle created at ${APP_BUNDLE}"
    exit 0
fi

# Install to Applications
if [ -d "/Applications/${APP_NAME}.app" ]; then
    echo "🗑️  Removing old version..."
    rm -rf "/Applications/${APP_NAME}.app"
fi

echo "📲 Installing to Applications..."
cp -R "${APP_BUNDLE}" "/Applications/"
if command -v xattr &> /dev/null; then
    xattr -dr com.apple.quarantine "/Applications/${APP_NAME}.app" 2>/dev/null || true
fi

if command -v spctl &> /dev/null; then
    echo "✅ Registering local Gatekeeper approval..."
    spctl --add --label "${APP_NAME}" "/Applications/${APP_NAME}.app" 2>/dev/null || true
fi

if [ -d "/Applications/${APP_NAME}.app" ]; then
    echo "✅ Installation successful!"
    echo ""
    echo "🎉 ${APP_NAME} is now installed in Applications"
    echo ""
    echo "To run:"
    echo "  1. Open Applications folder (Cmd+Shift+A in Finder)"
    echo "  open /Applications/${APP_NAME}.app"
    echo ""
    echo "The app will appear in your menu bar with the quota-cell icon"
else
    echo "❌ Installation failed"
    exit 1
fi
