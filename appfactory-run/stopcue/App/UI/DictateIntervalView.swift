import SwiftUI

struct DictateIntervalView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        Form {
            Section("Interval / cue fields") {
                TextField("Interval ms", text: $appModel.intervalField)
                    .keyboardType(.numberPad)
                TextField("Cue text", text: $appModel.cueTextField)
                TextField("Notes", text: $appModel.notesField, axis: .vertical)
                    .lineLimit(2...4)
            }
            Section("Speech") {
                Button {
                    appModel.startDictate(fieldKey: "interval")
                } label: {
                    Label(appModel.speechBusy ? "Listening…" : "Dictate interval / cue", systemImage: "mic.fill")
                }
                .disabled(appModel.speechBusy)
                if !appModel.speechTranscript.isEmpty {
                    Text("Transcript: \(appModel.speechTranscript)")
                        .font(.footnote)
                        .foregroundStyle(StopCueTheme.muted)
                }
            }
            Section {
                Button("Save dictated interval") {
                    appModel.saveDictatedInterval()
                }
                .tint(StopCueTheme.primary)
            }
            if let msg = appModel.statusMessage {
                Section {
                    Text(msg).font(.footnote)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(StopCueTheme.secondary.ignoresSafeArea())
        .navigationTitle("Dictate")
    }
}
