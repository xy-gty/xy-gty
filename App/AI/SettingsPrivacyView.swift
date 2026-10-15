import SwiftUI
import FolioCueDomain

struct SettingsPrivacyView: View {
    @ObservedObject var appModel: AppModel

    var body: some View {
        Form {
            Section("FolioCue") {
                Text(FolioCueCompliance.personalBookshelfCoach)
                Text(FolioCueCompliance.notBookstoreCatalogScraping)
                Text(FolioCueCompliance.notFullTextPiracyReader)
                Text(FolioCueCompliance.notHomeworkGrading)
            }

            Section("AI data sharing") {
                Toggle("Share with DeepSeek", isOn: Binding(
                    get: { appModel.consentGranted },
                    set: { on in
                        if on {
                            if !appModel.consentGranted {
                                appModel.showConsent = true
                            }
                        } else {
                            appModel.revokeAIConsent()
                        }
                    }
                ))
                if let reason = appModel.aiUnavailableReason {
                    Text(reason)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            Section("Coach inputs") {
                Toggle("TTS find callouts", isOn: Binding(
                    get: { appModel.state.settings.ttsEnabled },
                    set: { appModel.setTTSEnabled($0) }
                ))
                Toggle("Speech coach questions", isOn: Binding(
                    get: { appModel.state.settings.speechInputEnabled },
                    set: { appModel.setSpeechEnabled($0) }
                ))
            }

            Section("Legal (local)") {
                Button("Privacy") { appModel.openLegal("privacy") }
                Button("Terms") { appModel.openLegal("terms") }
                Button("Support") { appModel.openLegal("support") }
                Button("Provider policy") { appModel.openLegal("provider-policy") }
            }
        }
        .navigationTitle("Settings")
        .accessibilityIdentifier("SettingsPrivacy")
    }
}

struct LegalPageView: View {
    let title: String
    let fileName: String

    var body: some View {
        LocalLegalWebView(fileName: fileName)
            .navigationTitle(title)
            .accessibilityIdentifier("LegalPage-\(fileName)")
    }
}
