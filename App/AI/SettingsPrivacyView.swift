import SwiftUI
import MatteboxDomain

struct SettingsPrivacyView: View {
    @ObservedObject var appModel: AppModel

    var body: some View {
        List {
            Section("AI consent") {
                LabeledContent("Provider", value: AIConsentContract.provider)
                LabeledContent("Disclosure", value: AIConsentContract.disclosureVersion)
                LabeledContent("Status", value: appModel.consentGranted ? "Granted" : "Not granted")
                if let reason = appModel.aiUnavailableReason {
                    Text(reason)
                        .font(.footnote)
                        .foregroundStyle(MatteboxTheme.muted)
                }
                Button("Revoke AI consent", role: .destructive) {
                    appModel.revokeConsent()
                }
                .disabled(!appModel.consentGranted)
            }

            Section("Permissions (usage)") {
                permissionRow("Camera", PrivacyUsageCopy.camera)
                permissionRow("Photos", PrivacyUsageCopy.photoLibrary)
                permissionRow("Microphone", PrivacyUsageCopy.microphone)
                permissionRow("Speech Recognition", PrivacyUsageCopy.speechRecognition)
            }

            Section("Local legal") {
                NavigationLink("Privacy") { LegalPageView(title: "Privacy", fileName: "privacy") }
                NavigationLink("Terms") { LegalPageView(title: "Terms", fileName: "terms") }
                NavigationLink("Support") { LegalPageView(title: "Support", fileName: "support") }
                NavigationLink("Provider policy") { LegalPageView(title: "Provider policy", fileName: "provider-policy") }
            }

            Section("Identity") {
                LabeledContent("App", value: MatteboxIdentity.appName)
                LabeledContent("Bundle", value: MatteboxIdentity.developmentBundleId)
                LabeledContent("Palette", value: "\(MatteboxPalette.primary) / \(MatteboxPalette.secondary) / \(MatteboxPalette.accent)")
                Text("Clapper frame canvas with a shot-size chip bar for on-set framing.")
                    .font(.footnote)
                    .foregroundStyle(MatteboxTheme.muted)
            }
        }
        .scrollContentBackground(.hidden)
        .matteboxScreen()
        .navigationTitle("Settings")
    }

    private func permissionRow(_ title: String, _ copy: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.headline).foregroundStyle(MatteboxTheme.ink)
            Text(copy).font(.footnote).foregroundStyle(MatteboxTheme.muted)
        }
        .padding(.vertical, 2)
    }
}
