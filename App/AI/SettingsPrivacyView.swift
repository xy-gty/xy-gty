import SwiftUI
import LuxCueDomain

struct SettingsPrivacyView: View {
    @ObservedObject var appModel: AppModel

    var body: some View {
        Form {
            Section {
                ComplianceBanner()
                    .listRowBackground(Color.clear)
            }

            Section("AI") {
                Toggle("TTS set callouts", isOn: Binding(
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
                Button("Revoke AI consent", role: .destructive) {
                    appModel.revokeAIConsent()
                }
                if let reason = appModel.aiUnavailableReason {
                    Text(reason)
                        .font(.caption)
                        .foregroundStyle(LuxCueTheme.muted)
                }
            }

            Section("Legal (local)") {
                Button("Privacy") { appModel.openLegal("privacy") }
                Button("Terms") { appModel.openLegal("terms") }
                Button("Support") { appModel.openLegal("support") }
                Button("Provider policy") { appModel.openLegal("provider-policy") }
            }

            Section("Identity") {
                Text("Bundle \(LuxCueIdentity.developmentBundleId)")
                    .font(.caption)
                Text("Product dir \(LuxCueIdentity.productDir)")
                    .font(.caption)
                Text("Simulator prefer \(LuxCueIdentity.simulatorPrefUDID)")
                    .font(.caption)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("Settings")
    }
}
