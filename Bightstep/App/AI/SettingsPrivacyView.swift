import SwiftUI
import BightstepDomain

struct SettingsPrivacyView: View {
    @EnvironmentObject private var model: AppModel
    @State private var legalPage: LocalLegalWebView.Page?

    var body: some View {
        List {
            Section("AI sharing") {
                Toggle("Allow DeepSeek outbound", isOn: Binding(
                    get: { model.consentGranted },
                    set: { newValue in
                        if newValue { model.requireConsentThen {} }
                        else { model.revokeConsent() }
                    }
                ))
                if let reason = model.aiUnavailableReason {
                    Text(reason).font(.footnote).foregroundStyle(.secondary)
                }
            }
            Section("Legal (local)") {
                Button("Privacy Policy") { legalPage = .privacy }
                Button("Terms of Use") { legalPage = .terms }
                Button("Support") { legalPage = .support }
                Button("DeepSeek provider policy") { legalPage = .deepseekPrivacy }
            }
            Section("Gaps") {
                Text("External privacy/support URLs: UNKNOWN (replace before submission)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Settings")
        .sheet(item: $legalPage) { page in
            LocalLegalWebView(page: page)
        }
    }
}

extension LocalLegalWebView.Page: Hashable {}
