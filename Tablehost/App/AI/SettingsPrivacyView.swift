import SwiftUI
import TablehostDomain

struct SettingsPrivacyView: View {
    @ObservedObject var appModel: AppModel

    var body: some View {
        List {
            Section("AI consent") {
                HStack {
                    Text("Sharing allowed")
                    Spacer()
                    Text(appModel.consentGranted ? "Yes" : "No")
                        .foregroundStyle(appModel.consentGranted ? TablehostTheme.accent : TablehostTheme.muted)
                }
                Button("Revoke AI consent", role: .destructive) {
                    appModel.revokeConsent()
                }
                if let reason = appModel.aiUnavailableReason {
                    Text(reason)
                        .font(.footnote)
                        .foregroundStyle(TablehostTheme.muted)
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
                    .foregroundStyle(TablehostTheme.muted)
            }

            Section("Identity") {
                LabeledContent("App", value: TablehostIdentity.appName)
                LabeledContent("Bundle", value: TablehostIdentity.developmentBundleId)
                LabeledContent("Product dir", value: TablehostIdentity.productDir)
            }
        }
        .navigationTitle("Settings")
        .tablehostScreen()
    }

    private func permissionRow(_ title: String, _ copy: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
                .foregroundStyle(TablehostTheme.ink)
            Text(copy)
                .font(.caption)
                .foregroundStyle(TablehostTheme.muted)
        }
        .padding(.vertical, 4)
    }
}
