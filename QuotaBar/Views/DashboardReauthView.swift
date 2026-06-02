import SwiftUI
import WebKit

struct DashboardReauthSheet: View {
    @ObservedObject var monitor: QuotaMonitor
    @Environment(\.dismiss) private var dismiss

    let provider: Provider
    let key: APIKey?

    @State private var statusMessage: String?
    @State private var isSaving = false

    private var config: DashboardReauthConfig? {
        DashboardReauthConfig(provider: provider)
    }

    var body: some View {
        VStack(spacing: 14) {
            HStack(spacing: 12) {
                ProviderIcon(provider: provider, size: 34)

                VStack(alignment: .leading, spacing: 2) {
                    Text(L10n.format(.reauthTitle, provider.rawValue))
                        .font(.headline)

                    Text(L10n.t(.reauthDescription))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            if let config {
                DashboardWebView(url: config.loginURL)
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
                if let statusMessage {
                    Text(statusMessage)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

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

        WKWebsiteDataStore.default().httpCookieStore.getAllCookies { cookies in
            let cookieHeader = DashboardCookieBuilder.cookieHeader(
                from: cookies,
                domains: config.cookieDomains
            )

            DispatchQueue.main.async {
                isSaving = false
                guard !cookieHeader.isEmpty else {
                    statusMessage = L10n.t(.noCookiesFound)
                    return
                }

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

                monitor.refreshProvider(provider)
                dismiss()
            }
        }
    }
}

struct DashboardWebView: NSViewRepresentable {
    let url: URL

    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.allowsBackForwardNavigationGestures = true
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        if webView.url == nil {
            webView.load(URLRequest(url: url))
        }
    }
}
