import SwiftUI
import CellarCueDomain

struct SettingsPrivacyView: View {
    @ObservedObject var appModel: AppModel

    var body: some View {
        Form {
            Section {
                ComplianceBanner()
                    .listRowBackground(Color.clear)
            }

            Section("AI") {
                Toggle("TTS pull briefs", isOn: Binding(
                    get: { appModel.state.settings.ttsEnabled },
                    set: { appModel.setTTSEnabled($0) }
                ))
                Toggle("Speech input", isOn: Binding(
                    get: { appModel.state.settings.speechInputEnabled },
                    set: { appModel.setSpeechEnabled($0) }
                ))
                Toggle("Always show compliance banners", isOn: Binding(
                    get: { appModel.state.settings.alwaysShowComplianceBanner },
                    set: { appModel.setAlwaysShowCompliance($0) }
                ))
                Button("Acknowledge 21+ age gate") {
                    appModel.acknowledgeAgeGate()
                }
                Button("Revoke AI consent", role: .destructive) {
                    appModel.revokeAIConsent()
                }
                if let reason = appModel.aiUnavailableReason {
                    Text(reason)
                        .font(.caption)
                        .foregroundStyle(CellarCueTheme.muted)
                }
            }

            Section("Legal (local)") {
                Button("Privacy") { appModel.openLegal("privacy") }
                Button("Terms") { appModel.openLegal("terms") }
                Button("Support") { appModel.openLegal("support") }
                Button("Provider policy") { appModel.openLegal("provider-policy") }
            }

            Section("Identity") {
                Text("Bundle \(CellarCueIdentity.developmentBundleId)")
                    .font(.caption)
                Text("Product dir \(CellarCueIdentity.productDir)")
                    .font(.caption)
                Text("Simulator prefer \(CellarCueDevicePolicy.preferredUDID)")
                    .font(.caption)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("Settings")
    }
}
