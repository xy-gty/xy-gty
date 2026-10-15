import SwiftUI
import HiveCueDomain

struct SettingsPrivacyView: View {
    @ObservedObject var appModel: AppModel

    var body: some View {
        List {
            Section("AI consent") {
                HStack {
                    Text("Outbound AI")
                    Spacer()
                    Text(appModel.consentGranted ? "Allowed" : "Blocked")
                        .foregroundStyle(appModel.consentGranted ? HiveCueTheme.accent : HiveCueTheme.primary)
                        .fontWeight(.semibold)
                }
                if let reason = appModel.aiUnavailableReason {
                    Text(reason)
                        .font(.caption)
                        .foregroundStyle(HiveCueTheme.muted)
                }
                Button("Revoke AI consent", role: .destructive) {
                    appModel.revokeConsent()
                }
            }

            Section("Permissions used") {
                Label(PrivacyUsageCopy.camera, systemImage: "camera.fill")
                Label(PrivacyUsageCopy.photoLibrary, systemImage: "photo.on.rectangle")
                Label(PrivacyUsageCopy.microphone, systemImage: "mic.fill")
                Label(PrivacyUsageCopy.speechRecognition, systemImage: "waveform")
            }
            .font(.footnote)

            Section("Local legal") {
                NavigationLink("Privacy") {
                    LocalLegalWebView(resourceName: "privacy")
                        .navigationTitle("Privacy")
                }
                NavigationLink("Terms") {
                    LocalLegalWebView(resourceName: "terms")
                        .navigationTitle("Terms")
                }
                NavigationLink("Support") {
                    LocalLegalWebView(resourceName: "support")
                        .navigationTitle("Support")
                }
                NavigationLink("Provider policy") {
                    LocalLegalWebView(resourceName: "provider-policy")
                        .navigationTitle("Provider policy")
                }
            }

            Section("Identity") {
                LabeledContent("App", value: HiveCueIdentity.appName)
                LabeledContent("Bundle", value: HiveCueIdentity.developmentBundleId)
                LabeledContent("Simulator target", value: HiveCueDevicePolicy.targetDevice)
            }
        }
        .scrollContentBackground(.hidden)
        .background(HiveCueTheme.secondary.ignoresSafeArea())
        .navigationTitle("Settings")
    }
}
