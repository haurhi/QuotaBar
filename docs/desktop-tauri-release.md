# Desktop Tauri Release

This document defines the release boundary for the cross-platform Tauri preview. The Swift macOS app remains the stable Quota Radar release track until this Tauri app reaches parity.

## Platform package targets

`apps/desktop-tauri/src-tauri/tauri.conf.json` uses `bundle.targets = "all"` so each operating system builds its native package set:

- macOS: `.app` and `.dmg`
- Windows: NSIS/MSI package targets when built on Windows
- Linux: AppImage, deb, and rpm package targets where the runner has the required system tooling

The CI preview still runs `pnpm tauri build --no-bundle --ci`. That command proves the desktop app compiles on macOS, Windows, and Linux without producing unsigned installers on every pull request.

## Unsigned preview boundary

The Tauri preview does not enable automatic installation from GitHub Releases yet. `get_update_state`, `check_for_updates`, and `download_and_install_update` return an informational pending state until signed update artifacts are configured.

This avoids a misleading flow where users believe the app can safely replace itself while the updater has no signing key, endpoint manifest, or verified asset policy.

## GitHub Release asset names

When formal packaging is enabled, release assets should use stable names:

- `QuotaRadar-macos-universal.dmg`
- `QuotaRadar-windows-x64-setup.exe`
- `QuotaRadar-windows-x64.msi`
- `QuotaRadar-linux-x86_64.AppImage`
- `QuotaRadar-linux-amd64.deb`
- `QuotaRadar-linux-x86_64.rpm`

Updater manifests must be generated from the same signed artifacts. The app must show release notes and require explicit user confirmation before downloading or installing an update.

## Signing status

- macOS: unsigned preview only. Notarized distribution requires an Apple Developer ID certificate and notarization workflow.
- Windows: unsigned preview only. SmartScreen-friendly distribution requires a code-signing certificate.
- Linux: package signatures are not configured yet.

Until those are solved, use Tauri release builds for local validation and manual testing, not broad end-user distribution.
