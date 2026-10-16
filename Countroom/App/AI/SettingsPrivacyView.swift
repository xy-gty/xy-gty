import CountroomDomain
import SwiftUI

struct SettingsPrivacyView: View {
    @ObservedObject var appModel: AppModel

    var body: some View {
        List {
            Section("AI data sharing") {
                HStack {
                    Text("Consent status")
                    Spacer()
                    Text(appModel.consentGranted ? "Allowed" : "Off")
                        .foregroundStyle(appModel.consentGranted ? CountroomTheme.mint : CountroomTheme.muted)
                }
                Button("Revoke AI consent", role: .destructive) {
                    appModel.revokeConsent()
                }
                .disabled(!appModel.consentGranted)
                if let reason = appModel.aiUnavailableReason {
                    Text(reason)
                        .font(.caption)
                        .foregroundStyle(CountroomTheme.muted)
                }
            }

            Section("Legal") {
                ForEach(LocalLegalPage.allCases) { page in
                    NavigationLink(page.title) {
                        LocalLegalWebView(page: page)
                    }
                }
            }

            Section("Permissions") {
                Label(PrivacyUsageCopy.camera, systemImage: "camera")
                Label(PrivacyUsageCopy.photoLibrary, systemImage: "photo")
                Label(PrivacyUsageCopy.microphone, systemImage: "mic")
                Label(PrivacyUsageCopy.speechRecognition, systemImage: "waveform")
            }
        }
        .scrollContentBackground(.hidden)
        .background(CountroomTheme.lilac)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}
