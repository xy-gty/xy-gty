import ScoutCueDomain
import SwiftUI

struct DictateNoteView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Dictate shoot notes into the scout plan.")
                    .foregroundStyle(ScoutCueTheme.muted)
                Text(PrivacyUsageCopy.microphone)
                    .font(.caption)
                    .foregroundStyle(ScoutCueTheme.muted)
                Text(PrivacyUsageCopy.speechRecognition)
                    .font(.caption)
                    .foregroundStyle(ScoutCueTheme.muted)

                Button {
                    Task { await appModel.startDictation() }
                } label: {
                    if appModel.speechBusy {
                        ProgressView().frame(maxWidth: .infinity).padding(.vertical, 12)
                    } else {
                        Label("Start microphone", systemImage: "mic.fill")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(ScoutCueTheme.rose)
                .disabled(appModel.speechBusy)

                TextField("Transcript / typed note", text: $appModel.speechTranscript, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(3 ... 8)

                HStack {
                    Button("Cancel") { appModel.cancelDictation() }
                        .buttonStyle(.bordered)
                    Button("Save note") { appModel.saveShootNote() }
                        .buttonStyle(.borderedProminent)
                        .tint(ScoutCueTheme.indigo)
                }

                ForEach(appModel.planNotes, id: \.id) { note in
                    Text(note.transcript)
                        .font(.footnote)
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                if let status = appModel.statusMessage {
                    Text(status).font(.footnote).foregroundStyle(ScoutCueTheme.muted)
                }
            }
            .padding(20)
        }
        .scoutCueScreen()
        .navigationTitle("Dictate")
        .navigationBarTitleDisplayMode(.inline)
    }
}
