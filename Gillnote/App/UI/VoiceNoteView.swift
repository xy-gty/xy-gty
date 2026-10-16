import SwiftUI
import GillnoteDomain

struct VoiceNoteView: View {
    @EnvironmentObject private var appModel: AppModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                DisclaimerBanner()

                Text("Hands-free field note")
                    .font(.title2.bold())
                    .foregroundStyle(GillnoteTheme.ink)

                Text("Record while holding a knife or basket. Notes attach to the active find.")
                    .font(.subheadline)
                    .foregroundStyle(GillnoteTheme.muted)
                    .multilineTextAlignment(.center)

                if appModel.voiceRecorder.isRecording {
                    Image(systemName: "waveform.circle.fill")
                        .font(.system(size: 72))
                        .foregroundStyle(GillnoteTheme.primary)
                    Text("Recording…")
                        .font(.headline)
                        .foregroundStyle(GillnoteTheme.primary)
                } else {
                    Image(systemName: "mic.circle")
                        .font(.system(size: 72))
                        .foregroundStyle(GillnoteTheme.accent)
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
                        .tint(GillnoteTheme.primary)
                    } else {
                        Button("Start") {
                            appModel.startVoiceNote()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(GillnoteTheme.accent)
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
