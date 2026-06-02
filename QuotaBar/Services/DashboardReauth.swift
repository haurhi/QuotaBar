import Foundation

struct DashboardReauthConfig {
    let provider: Provider
    let loginURL: URL
    let cookieDomains: [String]
    let requiredCookieNames: [String]
    let defaultKeyName: String

    init?(provider: Provider) {
        guard provider.supportsDashboardReauthentication,
              let dashboardURL = provider.dashboardURL,
              let url = URL(string: dashboardURL) else {
            return nil
        }

        self.provider = provider
        self.loginURL = url
        self.cookieDomains = provider.cookieDomains
        self.requiredCookieNames = provider.dashboardAuthenticationCookieNames
        self.defaultKeyName = provider.defaultCredentialName
    }
}

enum DashboardCookieBuilder {
    static func cookieHeader(from cookies: [HTTPCookie], domains: [String]) -> String {
        let normalizedDomains = domains.map(normalizeDomain)
        let pairs = cookies
            .filter { cookie in
                let cookieDomain = normalizeDomain(cookie.domain)
                return normalizedDomains.contains { allowedDomain in
                    cookieDomain == allowedDomain || cookieDomain.hasSuffix(".\(allowedDomain)")
                }
            }
            .sorted { lhs, rhs in
                if lhs.name == rhs.name {
                    return lhs.domain < rhs.domain
                }
                return lhs.name < rhs.name
            }
            .map { "\($0.name)=\($0.value)" }

        return pairs.joined(separator: "; ")
    }

    static func containsRequiredCookie(from cookies: [HTTPCookie], domains: [String], requiredNames: [String]) -> Bool {
        let normalizedDomains = domains.map(normalizeDomain)
        let names = Set(requiredNames)
        guard !names.isEmpty else { return true }

        return cookies.contains { cookie in
            guard names.contains(cookie.name) else { return false }
            let cookieDomain = normalizeDomain(cookie.domain)
            return normalizedDomains.contains { allowedDomain in
                cookieDomain == allowedDomain || cookieDomain.hasSuffix(".\(allowedDomain)")
            }
        }
    }

    private static func normalizeDomain(_ domain: String) -> String {
        domain
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "."))
            .lowercased()
    }
}
