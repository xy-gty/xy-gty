import SwiftUI
import WorkrestDomain

struct SettingsPrivacyView: View {
    @ObservedObject var appModel: AppModel
    @State private var legalPage: LegalPage?

    enum LegalPage: String, Identifiable {
        case privacy, terms, support, provider
        var id: String { rawValue }
        var file: String {
            switch self {
            case .privacy: return "privacy"
            case .terms: return "terms"
            case .support: return "support"
            case .provider: return "provider-policy"
            }
        }
        var title: String {
            switch self {
            case .privacy: return "Privacy"
            case .terms: return "Terms"
            case .support: return "Support"
            case .provider: return "DeepSeek policy"
            }
        }
    }

    var body: some View {
        List {
            Section("AI data sharing") {
                Toggle("Allow outbound AI", isOn: Binding(
                    get: { appModel.consentGranted },
                    set: { newValue in
                        if newValue {
                            if !appModel.consentGranted {
                                appModel.showConsent = true
                            }
                        } else {
                            appModel.revokeConsent()
                        }
                    }
                ))
                Text("Disclosure \(AIConsentContract.disclosureVersion) · provider \(AIConsentContract.provider)")
                    .font(.caption)
                    .foregroundStyle(WorkrestTheme.muted)
                if let reason = appModel.aiUnavailableReason {
                    Text(reason).font(.caption).foregroundStyle(WorkrestTheme.muted)
                }
            }

            Section("Local legal pages") {
                Button("Privacy") { legalPage = .privacy }
                Button("Terms") { legalPage = .terms }
                Button("Support") { legalPage = .support }
                Button("Provider policy") { legalPage = .provider }
            }

            Section("Permissions used") {
                Text(PrivacyUsageCopy.camera)
                Text(PrivacyUsageCopy.photoLibrary)
                Text(PrivacyUsageCopy.microphone)
                Text(PrivacyUsageCopy.speechRecognition)
            }
            .font(.footnote)

            Section("Gaps") {
                Text("External privacy/terms/support URLs: UNKNOWN (local_only)")
                Text("AI key / CloudKit: UNKNOWN gaps — outbound stays closed until key + consent")
                Text("One-time unlock / paid packs: operator_pricing_deferred_free_app_only (no coins)")
            }
            .font(.caption)
        }
        .scrollContentBackground(.hidden)
        .background(WorkrestTheme.softWash.ignoresSafeArea())
        .navigationTitle("Settings")
        .sheet(item: $legalPage) { page in
            NavigationStack {
                LocalLegalWebView(resourceName: page.file)
                    .navigationTitle(page.title)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Close") { legalPage = nil }
                        }
                    }
            }
        }
        .sheet(isPresented: $appModel.showConsent) {
            ConsentSheet(appModel: appModel)
        }
    }
}
