import AppRuntimeCore
import SwiftUI

struct DictateNoteView: View {
    @EnvironmentObject private var appModel: AppModel
    @FocusState private var noteFocused: Bool

    var body: some View {
        RuntimeForm(dismissFocus: { noteFocused = false }) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Dictate pattern notes")
                    .font(.title2.bold())
                    .foregroundStyle(LoopwellTheme.ink)

                Text("Microphone + speech recognition fill the note; you can still type if permission is denied.")
                    .foregroundStyle(LoopwellTheme.muted)

                TextField("Pattern note / row intent", text: $appModel.dictateBuffer, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .focused($noteFocused)
                    .frame(minHeight: 120, alignment: .top)

                if !appModel.speechTranscript.isEmpty {
                    Text("Last transcript: \(appModel.speechTranscript)")
                        .font(.footnote)
                        .foregroundStyle(LoopwellTheme.muted)
                }

                if let status = appModel.statusMessage {
                    Text(status).font(.footnote)
                }
            }
            .padding(20)
        } actions: {
            HStack {
                Button {
                    Task { await appModel.startDictate() }
                } label: {
                    Label(appModel.speechBusy ? "Recording…" : "Record", systemImage: "mic.circle.fill")
                        .frame(maxWidth: .infinity, minHeight: 48)
                }
                .buttonStyle(.borderedProminent)
                .tint(LoopwellTheme.fuchsia)
                .disabled(appModel.speechBusy)

                Button("Save note") { appModel.saveDictatedNote() }
                    .buttonStyle(.bordered)
                    .frame(maxWidth: .infinity, minHeight: 48)
            }
            .padding()
        }
        .loopwellScreen()
        .navigationTitle("Dictate")
    }
}
