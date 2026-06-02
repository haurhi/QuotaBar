import SwiftUI
import WebKit

struct DashboardReauthSheet: View {
    @ObservedObject var monitor: QuotaMonitor
    @Environment(\.dismiss) private var dismiss

    let provider: Provider
    let key: APIKey?

    @State private var statusMessage: String?
    @State private var isSaving = false
    @State private var didAutoSave = false

    private var config: DashboardReauthConfig? {
        DashboardReauthConfig(provider: provider)
    }

    var body: some View {
        VStack(spacing: 14) {
            HStack(spacing: 12) {
                ProviderIcon(provider: provider, size: 34)

                VStack(alignment: .leading, spacing: 2) {
                    Text(L10n.format(.reauthTitle, provider.displayName()))
                        .font(.headline)

                    Text(L10n.t(.reauthDescription))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            if let config {
                DashboardWebView(
                    url: config.loginURL,
                    cookieDomains: config.cookieDomains,
                    requiredCookieNames: config.requiredCookieNames,
                    onCookiesAvailable: { cookieHeader in
                        autoSaveCookies(cookieHeader)
                    }
                )
                    .frame(width: 760, height: 520)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(Color.secondary.opacity(0.18), lineWidth: 1)
                    )
            } else {
                ContentUnavailableView(
                    L10n.t(.quotaUnavailable),
                    systemImage: "exclamationmark.triangle"
                )
                .frame(width: 760, height: 520)
            }

            HStack {
                Text(statusMessage ?? L10n.t(.autoCookieSaveHint))
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                Button(L10n.t(.close)) {
                    dismiss()
                }
                .buttonStyle(.bordered)

                Button(action: saveCookies) {
                    if isSaving {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Label(L10n.t(.saveCookie), systemImage: "key.fill")
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(config == nil || isSaving)
            }
        }
        .padding(18)
        .frame(width: 800)
    }

    private func saveCookies() {
        guard let config else { return }
        isSaving = true
        statusMessage = L10n.t(.autoSavingCookie)

        WKWebsiteDataStore.default().httpCookieStore.getAllCookies { cookies in
            let cookieHeader = DashboardCookieBuilder.cookieHeader(
                from: cookies,
                domains: config.cookieDomains
            )

            DispatchQueue.main.async {
                persistCookies(cookieHeader, allowEmptyStatus: true)
            }
        }
    }

    private func autoSaveCookies(_ cookieHeader: String) {
        guard !didAutoSave, !isSaving else { return }
        isSaving = true
        statusMessage = L10n.t(.autoSavingCookie)
        persistCookies(cookieHeader, allowEmptyStatus: false)
    }

    private func persistCookies(_ cookieHeader: String, allowEmptyStatus: Bool) {
        guard let config else {
            isSaving = false
            return
        }

        guard !cookieHeader.isEmpty else {
            isSaving = false
            if allowEmptyStatus {
                statusMessage = L10n.t(.noCookiesFound)
            }
            return
        }

        didAutoSave = true
        if var updatedKey = key ?? monitor.apiKeys.first(where: { $0.provider == provider }) {
            updatedKey.key = cookieHeader
            updatedKey.name = updatedKey.name.isEmpty ? config.defaultKeyName : updatedKey.name
            updatedKey.note = updatedKey.note ?? L10n.t(.dashboardSession)
            updatedKey.quotaLabel = L10n.t(.cookieSaved)
            updatedKey.lastUpdated = Date()
            monitor.updateKey(updatedKey)
        } else {
            let newKey = APIKey(
                name: config.defaultKeyName,
                key: cookieHeader,
                provider: provider,
                note: L10n.t(.dashboardSession),
                lastUpdated: Date(),
                quotaLabel: L10n.t(.cookieSaved)
            )
            monitor.addKey(newKey)
        }

        isSaving = false
        statusMessage = L10n.t(.cookieSaved)
        monitor.refreshProvider(provider)
        dismiss()
    }
}

struct DashboardWebView: NSViewRepresentable {
    let url: URL
    let cookieDomains: [String]
    let requiredCookieNames: [String]
    let onCookiesAvailable: (String) -> Void

    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        if webView.url == nil {
            webView.load(URLRequest(url: url))
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(
            cookieDomains: cookieDomains,
            requiredCookieNames: requiredCookieNames,
            onCookiesAvailable: onCookiesAvailable
        )
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        private let cookieDomains: [String]
        private let requiredCookieNames: [String]
        private let onCookiesAvailable: (String) -> Void
        private var didEmitCookies = false

        init(cookieDomains: [String], requiredCookieNames: [String], onCookiesAvailable: @escaping (String) -> Void) {
            self.cookieDomains = cookieDomains
            self.requiredCookieNames = requiredCookieNames
            self.onCookiesAvailable = onCookiesAvailable
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            guard !didEmitCookies,
                  let host = webView.url?.host,
                  matchesAllowedDomain(host) else {
                return
            }

            WKWebsiteDataStore.default().httpCookieStore.getAllCookies { [weak self] cookies in
                guard let self, !self.didEmitCookies else { return }
                let cookieHeader = DashboardCookieBuilder.cookieHeader(
                    from: cookies,
                    domains: self.cookieDomains
                )
                guard !cookieHeader.isEmpty else { return }
                guard DashboardCookieBuilder.containsRequiredCookie(
                    from: cookies,
                    domains: self.cookieDomains,
                    requiredNames: self.requiredCookieNames
                ) else {
                    return
                }

                self.didEmitCookies = true
                DispatchQueue.main.async {
                    self.onCookiesAvailable(cookieHeader)
                }
            }
        }

        private func matchesAllowedDomain(_ host: String) -> Bool {
            let normalizedHost = normalizeDomain(host)
            return cookieDomains.map(normalizeDomain).contains { allowedDomain in
                normalizedHost == allowedDomain || normalizedHost.hasSuffix(".\(allowedDomain)")
            }
        }

        private func normalizeDomain(_ domain: String) -> String {
            domain
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .trimmingCharacters(in: CharacterSet(charactersIn: "."))
                .lowercased()
        }
    }
}
