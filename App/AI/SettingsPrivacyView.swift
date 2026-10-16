import SwiftUI
import GillnoteDomain

struct SettingsPrivacyView: View {
    @ObservedObject var appModel: AppModel

    var body: some View {
        List {
            Section {
                DisclaimerBanner()
                    .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                    .listRowBackground(Color.clear)
            }

            Section("AI") {
                Toggle("TTS field briefs", isOn: Binding(
                    get: { appModel.state.settings.ttsEnabled },
                    set: { appModel.setTTSEnabled($0) }
                ))
                Toggle("Speech input", isOn: Binding(
                    get: { appModel.state.settings.speechInputEnabled },
                    set: { appModel.setSpeechEnabled($0) }
                ))
                Toggle("Always show edibility disclaimer", isOn: Binding(
                    get: { appModel.state.settings.alwaysShowEdibilityDisclaimer },
                    set: { appModel.setAlwaysShowDisclaimer($0) }
                ))
                Button("Revoke AI consent", role: .destructive) {
                    appModel.revokeAIConsent()
                }
                Text(appModel.consentGranted ? "Consent: granted" : "Consent: not granted")
                    .font(.caption)
                    .foregroundStyle(GillnoteTheme.muted)
            }

            Section("Permissions (foraging coach)") {
                Text("Camera — cap / gill / pore capture")
                Text("Photos — hike album import")
                Text("Microphone — hands-free field notes")
                Text("Speech Recognition — spoken lookalike questions")
            }

            Section("Local legal") {
                Button("Privacy") { appModel.openLegal("privacy") }
                    .accessibilityIdentifier("LegalPrivacy")
                Button("Terms") { appModel.openLegal("terms") }
                    .accessibilityIdentifier("LegalTerms")
                Button("Support") { appModel.openLegal("support") }
                    .accessibilityIdentifier("LegalSupport")
                Button("Provider policy") { appModel.openLegal("provider-policy") }
                    .accessibilityIdentifier("LegalProviderPolicy")
            }

            Section("Gaps") {
                Text("privacy_url: \(GillnoteGaps.privacyURL)")
                Text("terms_url: \(GillnoteGaps.termsURL)")
                Text("support_url: \(GillnoteGaps.supportURL)")
                Text("ai_key: \(GillnoteGaps.aiKey)")
                Text("cloudkit: \(GillnoteGaps.cloudkit)")
            }
        }
        .scrollContentBackground(.hidden)
        .sporeScreen()
        .navigationTitle("Settings")
        .accessibilityIdentifier("Settings")
    }
}

struct LegalPageView: View {
    let title: String
    let fileName: String

    var body: some View {
        VStack(spacing: 0) {
            DisclaimerBanner()
                .padding(.horizontal, 12)
                .padding(.top, 8)
            LocalLegalWebView(fileName: fileName)
        }
        .sporeScreen()
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("LegalPage")
    }
}
