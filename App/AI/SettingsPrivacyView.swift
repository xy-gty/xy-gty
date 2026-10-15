import SwiftUI
import MixCueDomain

struct SettingsPrivacyView: View {
    @ObservedObject var appModel: AppModel

    var body: some View {
        List {
            Section("AI") {
                Toggle("TTS shake/stir steps", isOn: Binding(
                    get: { appModel.state.settings.ttsEnabled },
                    set: { appModel.setTTSEnabled($0) }
                ))
                Toggle("Speech input", isOn: Binding(
                    get: { appModel.state.settings.speechInputEnabled },
                    set: { appModel.setSpeechEnabled($0) }
                ))
                Button("Revoke AI consent", role: .destructive) {
                    appModel.revokeAIConsent()
                }
                Text(appModel.consentGranted ? "Consent: granted" : "Consent: not granted")
                    .font(.caption)
                    .foregroundStyle(MixCueTheme.muted)
            }

            Section("Permissions (core coach)") {
                Text("Camera — bottle / label / garnish capture")
                Text("Photos — bar-shelf album import")
                Text("Microphone — hands-free notes while shaking")
                Text("Speech Recognition — spoken coach questions")
            }

            Section("Local legal") {
                Button("Privacy") { appModel.openLegal("privacy") }
                Button("Terms") { appModel.openLegal("terms") }
                Button("Support") { appModel.openLegal("support") }
                Button("Provider policy") { appModel.openLegal("provider-policy") }
            }

            Section("Gaps") {
                Text("privacy_url: \(MixCueGaps.privacyURL)")
                Text("terms_url: \(MixCueGaps.termsURL)")
                Text("support_url: \(MixCueGaps.supportURL)")
                Text("ai_key: \(MixCueGaps.aiKey)")
                Text("cloudkit: \(MixCueGaps.cloudkit)")
            }
        }
        .scrollContentBackground(.hidden)
        .mixCueScreen()
        .navigationTitle("Settings")
        .accessibilityIdentifier("Settings")
    }
}

struct LegalPageView: View {
    let title: String
    let fileName: String

    var body: some View {
        LocalLegalWebView(fileName: fileName)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .accessibilityIdentifier("LegalPage")
    }
}
