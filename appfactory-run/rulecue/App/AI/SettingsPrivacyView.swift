import SwiftUI
import RuleCueDomain

struct SettingsPrivacyView: View {
    @ObservedObject var appModel: AppModel

    var body: some View {
        List {
            Section("AI consent") {
                HStack {
                    Text("Sharing allowed")
                    Spacer()
                    Text(appModel.consentGranted ? "Yes" : "No")
                        .foregroundStyle(appModel.consentGranted ? RuleCueTheme.accent : RuleCueTheme.muted)
                }
                Button("Revoke AI consent", role: .destructive) {
                    appModel.revokeConsent()
                }
                if let reason = appModel.aiUnavailableReason {
                    Text(reason)
                        .font(.footnote)
                        .foregroundStyle(RuleCueTheme.muted)
                }
            }

            Section("Permissions") {
                permissionRow("Camera", PrivacyUsageCopy.camera)
                permissionRow("Photos", PrivacyUsageCopy.photoLibrary)
                permissionRow("Microphone", PrivacyUsageCopy.microphone)
                permissionRow("Speech Recognition", PrivacyUsageCopy.speechRecognition)
            }

            Section("Legal (local)") {
                NavigationLink("Open local legal pages") {
                    LegalPagesView()
                }
                Text("Remote privacy/terms/support URLs are UNKNOWN gaps (local_only).")
                    .font(.caption)
                    .foregroundStyle(RuleCueTheme.muted)
            }

            Section("Identity") {
                LabeledContent("App", value: RuleCueIdentity.appName)
                LabeledContent("Bundle", value: RuleCueIdentity.developmentBundleId)
                LabeledContent("Product dir", value: RuleCueIdentity.productDir)
            }
        }
        .navigationTitle("Settings")
        .ruleCueScreen()
    }

    private func permissionRow(_ title: String, _ copy: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
                .foregroundStyle(RuleCueTheme.ink)
            Text(copy)
                .font(.caption)
                .foregroundStyle(RuleCueTheme.muted)
        }
        .padding(.vertical, 4)
    }
}
