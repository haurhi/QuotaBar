import Foundation

enum LegacyConfigurationMigrator {
    static let legacyDefaultsSuiteName = "com.gaorongvc.quotabar"
    static let migrationMarkerKey = "didMigrateQuotaBarDefaultsToQuotaRadar"

    private static let migratedKeys = [
        "apiKeyMetadata",
        "apiKeys",
        "didAttemptClaudeSettingsImport",
        "appLanguage",
        "statusBarTransparency",
        "autoRefreshInterval",
        "quotaConsumingAutoRefreshInterval",
        "aiQuoteIndex",
    ]

    static func migrateUserDefaultsIfNeeded(
        defaults: UserDefaults = .standard,
        legacyDefaults: UserDefaults? = UserDefaults(suiteName: legacyDefaultsSuiteName)
    ) {
        guard !defaults.bool(forKey: migrationMarkerKey),
              let legacyDefaults else {
            return
        }

        for key in migratedKeys where defaults.object(forKey: key) == nil {
            if let value = legacyDefaults.object(forKey: key) {
                defaults.set(value, forKey: key)
            }
        }

        defaults.set(true, forKey: migrationMarkerKey)
    }
}
