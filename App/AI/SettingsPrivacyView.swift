import SwiftUI
import WingCueDomain

struct SettingsPrivacyView: View {
    @ObservedObject var appModel: AppModel

    var body: some View {
        List {
            Section("Field coaching") {
                Toggle("Speak tips (TTS)", isOn: Binding(
                    get: { appModel.state.settings.ttsEnabled },
                    set: { appModel.setTTSEnabled($0) }
                ))
                Toggle("Speech questions", isOn: Binding(
                    get: { appModel.state.settings.speechInputEnabled },
                    set: { appModel.setSpeechEnabled($0) }
                ))
            }

            Section("AI consent") {
                Text(appModel.consentGranted
                     ? "Sharing allowed with \(AIConsentContract.provider)"
                     : "Outbound AI blocked until you allow sharing")
                    .font(.subheadline)
                    .foregroundStyle(WingCueTheme.muted)
                if appModel.consentGranted {
                    Button("Revoke AI consent", role: .destructive) {
                        appModel.revokeConsent()
                    }
                } else {
                    Button("Review AI consent") {
                        appModel.showConsent = true
                    }
                    .foregroundStyle(WingCueTheme.primary)
                }
                if let reason = appModel.aiUnavailableReason {
                    Text(reason)
                        .font(.caption)
                        .foregroundStyle(WingCueTheme.accent)
                }
            }

            Section("Permissions (status)") {
                Label("Camera — plumage capture", systemImage: "camera.fill")
                Label("Photos — trip album import", systemImage: "photo.on.rectangle")
                Label("Microphone — hands-free notes", systemImage: "mic.fill")
                Label("Speech — coach questions", systemImage: "waveform")
            }
            .foregroundStyle(WingCueTheme.ink)

            Section("Legal (local)") {
                NavigationLink("Privacy") { LegalPageView(title: "Privacy", fileName: "privacy") }
                NavigationLink("Terms") { LegalPageView(title: "Terms", fileName: "terms") }
                NavigationLink("Support") { LegalPageView(title: "Support", fileName: "support") }
                NavigationLink("Provider policy") {
                    LegalPageView(title: "Provider policy", fileName: "provider-policy")
                }
            }

            Section("Gaps") {
                Text("External privacy/terms/support URLs: UNKNOWN (local_only)")
                Text("AI key / CloudKit: UNKNOWN until configured")
            }
            .font(.caption)
            .foregroundStyle(WingCueTheme.muted)
        }
        .scrollContentBackground(.hidden)
        .wingCueScreen()
        .navigationTitle("Settings")
        .accessibilityIdentifier("SettingsPrivacyView")
    }
}
