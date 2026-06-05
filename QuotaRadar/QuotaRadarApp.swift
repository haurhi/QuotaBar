import SwiftUI

@main
struct QuotaRadarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        LegacyConfigurationMigrator.migrateUserDefaultsIfNeeded()
    }

    var body: some Scene {
        Settings {
            EmptyView()
                .frame(width: 0, height: 0)
        }
        .commands {
            CommandGroup(replacing: .appSettings) {
                Button(L10n.t(.settingsTab)) {
                    appDelegate.openPreferences()
                }
                .keyboardShortcut(",", modifiers: .command)
            }
        }
    }
}
