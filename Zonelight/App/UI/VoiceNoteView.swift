import SwiftUI

struct VoiceNoteView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                ComplianceBanner()
                Text("Hands-free meter notes while holding the camera.")
                    .font(.subheadline)
                    .foregroundStyle(ZonelightTheme.muted)
                    .multilineTextAlignment(.center)
                if appModel.voiceRecorder.isRecording {
                    Label("Recording…", systemImage: "mic.fill")
                        .foregroundStyle(.red)
                    Button("Stop & save") { appModel.stopVoiceNote() }
                        .buttonStyle(.borderedProminent)
                        .tint(ZonelightTheme.primary)
                } else {
                    Button("Start recording") { appModel.startVoiceNote() }
                        .buttonStyle(.borderedProminent)
                        .tint(ZonelightTheme.accent)
                }
                Spacer()
            }
            .padding(24)
            .luxScreen()
            .navigationTitle("Voice note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { appModel.showVoiceNote = false }
                }
            }
        }
    }
}
