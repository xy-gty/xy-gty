import SwiftUI

struct DictateIntervalView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        Form {
            Section("Interval fields") {
                TextField("Interval ms", text: $appModel.intervalField)
                    .keyboardType(.numberPad)
                TextField("Line text", text: $appModel.cueTextField)
                TextField("Notes", text: $appModel.notesField, axis: .vertical)
                    .lineLimit(2...4)
            }
            Section("Speech") {
                Button {
                    appModel.startDictate(fieldKey: "interval")
                } label: {
                    Label(appModel.speechBusy ? "Listening…" : "Dictate the interval", systemImage: "mic.fill")
                }
                .disabled(appModel.speechBusy)
                if !appModel.speechTranscript.isEmpty {
                    Text("Transcript: \(appModel.speechTranscript)")
                        .font(.footnote)
                        .foregroundStyle(OnionreelTheme.muted)
                }
            }
            Section {
                Button("Save dictated interval") {
                    appModel.saveDictatedInterval()
                }
                .tint(OnionreelTheme.primary)
            }
            if let msg = appModel.statusMessage {
                Section {
                    Text(msg).font(.footnote)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(OnionreelTheme.secondary.ignoresSafeArea())
        .navigationTitle("Dictate")
    }
}
