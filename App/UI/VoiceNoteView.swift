import SwiftUI

struct VoiceNoteView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Voice notes")
                .font(.title2.weight(.bold))
                .foregroundStyle(CueTheme.ink)
            Text("Record a rehearsal note. Simulator may show a limited journey; full capture is device-tested.")
                .font(.footnote)
                .foregroundStyle(.secondary)

            Button(model.isRecordingVoice ? "Stop" : "Record") {
                Task {
                    if model.isRecordingVoice {
                        await model.stopVoiceNote()
                    } else {
                        await model.startVoiceNote()
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(CueTheme.amber)
            .disabled(model.voiceNoteBusy)

            List {
                ForEach(model.activeVoiceNotes, id: \.id) { note in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(note.relativeAudioPath).font(.caption.weight(.semibold))
                        if let t = note.transcript, !t.isEmpty {
                            Text(t).font(.footnote)
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
        }
        .padding()
        .background(CueTheme.background.ignoresSafeArea())
        .navigationTitle("Voice note")
    }
}
