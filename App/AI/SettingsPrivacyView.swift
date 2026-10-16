import SwiftUI
import BrewCueDomain

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
                    .foregroundStyle(BrewCueTheme.muted)
                if let reason = appModel.aiUnavailableReason {
                    Text(reason).font(.caption).foregroundStyle(BrewCueTheme.muted)
                }
            }

            Section("Local legal") {
                Button("Privacy") { appModel.openLegal("privacy") }
                Button("Terms") { appModel.openLegal("terms") }
                Button("Support") { appModel.openLegal("support") }
                Button("DeepSeek provider policy") { appModel.openLegal("provider-policy") }
            }

            Section("Compliance") {
                ForEach(BrewCueCompliance.requiredDisclaimers, id: \.self) { line in
                    Text(line).font(.caption)
                }
            }

            Section("Speech") {
                Toggle("Speech input", isOn: Binding(
                    get: { appModel.state.settings.speechInputEnabled },
                    set: { appModel.state.settings.speechInputEnabled = $0; appModel.persist() }
                ))
            }
        }
        .scrollContentBackground(.hidden)
        .brewCueScreen()
        .navigationTitle("Settings")
        .accessibilityIdentifier("SettingsPrivacy")
    }
}
