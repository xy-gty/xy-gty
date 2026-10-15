import SwiftUI

struct VoiceNoteView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                ComplianceBanner(showAgeGate: false)

                Text("Hands-free bin note")
                    .font(.title2.bold())
                    .foregroundStyle(CellarCueTheme.ink)

                Text("Record while carrying bottles. Extends cellar coach — not a separate side product.")
                    .font(.subheadline)
                    .foregroundStyle(CellarCueTheme.muted)
                    .multilineTextAlignment(.center)

                if appModel.voiceRecorder.isRecording {
                    Text("Recording…")
                        .font(.headline)
                        .foregroundStyle(CellarCueTheme.accent)
                }

                if let err = appModel.voiceRecorder.lastError {
                    Text(err)
                        .font(.caption)
                        .foregroundStyle(.red)
                }

                HStack(spacing: 16) {
                    Button("Start") { appModel.startVoiceNote() }
                        .buttonStyle(.borderedProminent)
                        .tint(CellarCueTheme.accent)
                        .disabled(appModel.voiceRecorder.isRecording)

                    Button("Stop & save") { appModel.stopVoiceNote() }
                        .buttonStyle(.bordered)
                        .disabled(!appModel.voiceRecorder.isRecording)
                }

                Spacer()
            }
            .padding(24)
            .cellarScreen()
            .navigationTitle("Voice note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { appModel.showVoiceNote = false }
                }
            }
        }
        .accessibilityIdentifier("VoiceNoteView")
    }
}
