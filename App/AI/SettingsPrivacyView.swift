import SwiftUI
import HeatbarDomain

struct SettingsPrivacyView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        Form {
            Section("AI data sharing") {
                Toggle("Allow outbound AI", isOn: Binding(
                    get: { appModel.consentGranted },
                    set: { on in
                        if on {
                            if !appModel.consentGranted {
                                appModel.showConsent = true
                            }
                        } else {
                            appModel.revokeConsent()
                        }
                    }
                ))
                Text("Provider: \(AIConsentContract.provider) · \(AIConsentContract.disclosureVersion)")
                    .font(.caption)
                    .foregroundStyle(HeatbarTheme.muted)
                if let reason = appModel.aiUnavailableReason {
                    Text(reason).font(.caption).foregroundStyle(HeatbarTheme.muted)
                }
            }

            Section("Local legal") {
                Button("Privacy") { appModel.openLegal("privacy") }
                Button("Terms") { appModel.openLegal("terms") }
                Button("Support") { appModel.openLegal("support") }
                Button("DeepSeek provider policy") { appModel.openLegal("provider-policy") }
            }

            Section("Compliance") {
                ForEach(HeatbarCompliance.requiredDisclaimers, id: \.self) { line in
                    Text(line).font(.caption)
                }
            }

            Section("Callouts") {
                Toggle("TTS enabled", isOn: Binding(
                    get: { appModel.state.settings.ttsEnabled },
                    set: { appModel.state.settings.ttsEnabled = $0; appModel.persist() }
                ))
                Toggle("Speech input", isOn: Binding(
                    get: { appModel.state.settings.speechInputEnabled },
                    set: { appModel.state.settings.speechInputEnabled = $0; appModel.persist() }
                ))
            }
        }
        .scrollContentBackground(.hidden)
        .heatbarScreen()
        .navigationTitle("Settings")
        .accessibilityIdentifier("SettingsPrivacy")
    }
}
