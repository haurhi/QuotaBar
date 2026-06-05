import Foundation

enum FileSecretStoreError: Error {
    case invalidDirectory
}

struct FileSecretStore {
    private let fileURL: URL
    private let legacyFileURL: URL?
    private let fileManager: FileManager

    init(
        fileURL: URL? = nil,
        fileManager: FileManager = .default,
        legacyFileURL: URL? = nil
    ) {
        self.fileManager = fileManager
        if let fileURL {
            self.fileURL = fileURL
            self.legacyFileURL = legacyFileURL
        } else {
            self.fileURL = Self.defaultFileURL(fileManager: fileManager)
            self.legacyFileURL = legacyFileURL ?? Self.legacyDefaultFileURL(fileManager: fileManager)
        }
    }

    func read(account: String) throws -> String? {
        try migrateLegacySecretsIfNeeded()
        try tightenExistingPermissions()
        return try loadSecrets()[account]
    }

    func save(_ value: String, account: String) throws {
        var secrets = try loadSecrets()
        secrets[account] = value
        try saveSecrets(secrets)
    }

    func delete(account: String) {
        guard var secrets = try? loadSecrets() else { return }
        secrets.removeValue(forKey: account)
        try? saveSecrets(secrets)
    }

    private static func defaultFileURL(fileManager: FileManager) -> URL {
        let quotaRadarSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?
            .appendingPathComponent("QuotaRadar", isDirectory: true)
            ?? URL(fileURLWithPath: NSHomeDirectory())
                .appendingPathComponent("Library/Application Support/QuotaRadar", isDirectory: true)
        return quotaRadarSupportURL
            .appendingPathComponent("secrets.json")
    }

    private static func legacyDefaultFileURL(fileManager: FileManager) -> URL {
        let quotaBarSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?
            .appendingPathComponent("QuotaBar", isDirectory: true)
            ?? URL(fileURLWithPath: NSHomeDirectory())
                .appendingPathComponent("Library/Application Support/QuotaBar", isDirectory: true)
        return quotaBarSupportURL
            .appendingPathComponent("secrets.json")
    }

    private func loadSecrets() throws -> [String: String] {
        try migrateLegacySecretsIfNeeded()
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return [:]
        }

        let data = try Data(contentsOf: fileURL)
        guard !data.isEmpty else {
            return [:]
        }
        return try JSONDecoder().decode([String: String].self, from: data)
    }

    private func tightenExistingPermissions() throws {
        let directory = fileURL.deletingLastPathComponent()
        var isDirectory: ObjCBool = false
        if fileManager.fileExists(atPath: directory.path, isDirectory: &isDirectory), isDirectory.boolValue {
            try fileManager.setAttributes([.posixPermissions: 0o700], ofItemAtPath: directory.path)
        }
        if fileManager.fileExists(atPath: fileURL.path) {
            try fileManager.setAttributes([.posixPermissions: 0o600], ofItemAtPath: fileURL.path)
        }
    }

    private func migrateLegacySecretsIfNeeded() throws {
        guard let legacyFileURL,
              legacyFileURL.path != fileURL.path,
              !fileManager.fileExists(atPath: fileURL.path),
              fileManager.fileExists(atPath: legacyFileURL.path) else {
            return
        }

        let directory = fileURL.deletingLastPathComponent()
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        try fileManager.setAttributes([.posixPermissions: 0o700], ofItemAtPath: directory.path)

        let data = try Data(contentsOf: legacyFileURL)
        guard fileManager.createFile(
            atPath: fileURL.path,
            contents: data,
            attributes: [.posixPermissions: 0o600]
        ) else {
            throw FileSecretStoreError.invalidDirectory
        }

        try fileManager.setAttributes([.posixPermissions: 0o600], ofItemAtPath: fileURL.path)
        let legacyDirectory = legacyFileURL.deletingLastPathComponent()
        var isDirectory: ObjCBool = false
        if fileManager.fileExists(atPath: legacyDirectory.path, isDirectory: &isDirectory), isDirectory.boolValue {
            try fileManager.setAttributes([.posixPermissions: 0o700], ofItemAtPath: legacyDirectory.path)
        }
        try fileManager.setAttributes([.posixPermissions: 0o600], ofItemAtPath: legacyFileURL.path)
    }

    private func saveSecrets(_ secrets: [String: String]) throws {
        let directory = fileURL.deletingLastPathComponent()
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        try fileManager.setAttributes([.posixPermissions: 0o700], ofItemAtPath: directory.path)

        let data = try JSONEncoder().encode(secrets)
        if fileManager.fileExists(atPath: fileURL.path) {
            try data.write(to: fileURL, options: .atomic)
        } else if !fileManager.createFile(
            atPath: fileURL.path,
            contents: data,
            attributes: [.posixPermissions: 0o600]
        ) {
            throw FileSecretStoreError.invalidDirectory
        }

        try fileManager.setAttributes([.posixPermissions: 0o600], ofItemAtPath: fileURL.path)
    }
}
