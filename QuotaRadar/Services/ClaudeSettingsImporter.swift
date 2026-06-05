import Foundation

struct ClaudeSettingsImporter {
    static var defaultSettingsURL: URL {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".claude/settings.json")
    }

    static func parseDefaultSettings() -> [APIKey] {
        parseSettings(at: defaultSettingsURL)
    }

    static func parseSettings(at url: URL) -> [APIKey] {
        guard let data = try? Data(contentsOf: url),
              let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let env = object["env"] as? [String: Any] else {
            return []
        }

        let stringEnv = env.compactMapValues { value -> String? in
            value as? String
        }

        return EnvImporter.parseEnvironment(
            stringEnv,
            note: L10n.t(.importedFromClaude)
        )
    }
}
