import SwiftUI
import SporeCueDomain

struct VoiceNoteView: View {
    @EnvironmentObject private var appModel: AppModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                DisclaimerBanner()

                Text("Hands-free field note")
                    .font(.title2.bold())
                    .foregroundStyle(SporeCueTheme.ink)

                Text("Record while holding a knife or basket. Notes attach to the active find.")
                    .font(.subheadline)
                    .foregroundStyle(SporeCueTheme.muted)
                    .multilineTextAlignment(.center)

                if appModel.voiceRecorder.isRecording {
                    Image(systemName: "waveform.circle.fill")
                        .font(.system(size: 72))
                        .foregroundStyle(SporeCueTheme.primary)
                    Text("Recording…")
                        .font(.headline)
                        .foregroundStyle(SporeCueTheme.primary)
                } else {
                    Image(systemName: "mic.circle")
                        .font(.system(size: 72))
                        .foregroundStyle(SporeCueTheme.accent)
                }

                if let err = appModel.voiceRecorder.lastError {
                    StatusBanner(text: err, isError: true)
                }

                HStack(spacing: 16) {
                    if appModel.voiceRecorder.isRecording {
                        Button("Stop & save") {
                            appModel.stopVoiceNote()
                            dismiss()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(SporeCueTheme.primary)
                    } else {
                        Button("Start") {
                            appModel.startVoiceNote()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(SporeCueTheme.accent)
                    }
                    Button("Close") { dismiss() }
                        .buttonStyle(.bordered)
                }

                Spacer()
            }
            .padding(24)
            .sporeScreen()
            .navigationTitle("Voice note")
            .navigationBarTitleDisplayMode(.inline)
        }
        .accessibilityIdentifier("VoiceNote")
    }
}
