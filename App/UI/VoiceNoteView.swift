import SwiftUI

struct VoiceNoteView: View {
    @EnvironmentObject private var appModel: AppModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Hands-free field note")
                    .font(.title2.bold())
                    .foregroundStyle(FieldmarkTheme.ink)

                Text("Keep binoculars up — tap to record a short mic note.")
                    .font(.subheadline)
                    .foregroundStyle(FieldmarkTheme.muted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Image(systemName: appModel.voiceRecorder.isRecording ? "mic.circle.fill" : "mic.circle")
                    .font(.system(size: 72))
                    .foregroundStyle(appModel.voiceRecorder.isRecording ? FieldmarkTheme.accent : FieldmarkTheme.primary)
                    .symbolEffect(.pulse, isActive: appModel.voiceRecorder.isRecording)

                if let err = appModel.voiceRecorder.lastError {
                    StatusBanner(text: err, isError: true)
                        .padding(.horizontal)
                }

                HStack(spacing: 16) {
                    if appModel.voiceRecorder.isRecording {
                        Button("Stop & save") {
                            appModel.stopVoiceNote()
                            dismiss()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(FieldmarkTheme.accent)
                    } else {
                        Button("Start recording") {
                            appModel.startVoiceNote()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(FieldmarkTheme.primary)
                    }

                    Button("Close") { dismiss() }
                        .buttonStyle(.bordered)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .fieldmarkScreen()
            .navigationTitle("Voice note")
            .navigationBarTitleDisplayMode(.inline)
        }
        .accessibilityIdentifier("VoiceNoteView")
    }
}
