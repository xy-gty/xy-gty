import SwiftUI
import BroodcheckDomain

struct SettingsPrivacyView: View {
    @ObservedObject var appModel: AppModel

    var body: some View {
        List {
            Section("AI consent") {
                HStack {
                    Text("Outbound AI")
                    Spacer()
                    Text(appModel.consentGranted ? "Allowed" : "Blocked")
                        .foregroundStyle(appModel.consentGranted ? BroodcheckTheme.accent : BroodcheckTheme.primary)
                        .fontWeight(.semibold)
                }
                if let reason = appModel.aiUnavailableReason {
                    Text(reason)
                        .font(.caption)
                        .foregroundStyle(BroodcheckTheme.muted)
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
                LabeledContent("App", value: BroodcheckIdentity.appName)
                LabeledContent("Bundle", value: BroodcheckIdentity.developmentBundleId)
                LabeledContent("Simulator target", value: BroodcheckDevicePolicy.targetDevice)
            }
        }
        .scrollContentBackground(.hidden)
        .background(BroodcheckTheme.secondary.ignoresSafeArea())
        .navigationTitle("Settings")
    }
}
