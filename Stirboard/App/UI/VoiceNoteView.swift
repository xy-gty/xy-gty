import SwiftUI

struct VoiceNoteView: View {
    @EnvironmentObject private var appModel: AppModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Hands-free voice note")
                    .font(.title2.bold())
                    .foregroundStyle(StirboardTheme.ink)
                Text("Record while both hands shake or stir. Mic permission is required; typed coach chat still works if denied.")
                    .font(.body)
                    .foregroundStyle(StirboardTheme.muted)
                    .multilineTextAlignment(.center)

                if appModel.voiceRecorder.isRecording {
                    Text("Recording…")
                        .font(.headline)
                        .foregroundStyle(StirboardTheme.primary)
                }

                if let err = appModel.voiceRecorder.lastError {
                    StatusBanner(text: err, isError: true)
                }

                Button {
                    if appModel.voiceRecorder.isRecording {
                        appModel.stopVoiceNote()
                        dismiss()
                    } else {
                        appModel.startVoiceNote()
                    }
                } label: {
                    Label(
                        appModel.voiceRecorder.isRecording ? "Stop & save" : "Start recording",
                        systemImage: appModel.voiceRecorder.isRecording ? "stop.circle.fill" : "mic.circle.fill"
                    )
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .tint(StirboardTheme.accent)

                Spacer()
            }
            .padding(24)
            .stirboardScreen()
            .navigationTitle("Voice note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .accessibilityIdentifier("VoiceNote")
    }
}
