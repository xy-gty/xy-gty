import SwiftUI

struct DictateIntentView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Dictate intent")
                    .font(.title2.bold())
                    .foregroundStyle(FormCueTheme.ink)

                Text("Say “skip rest” or your next coach intent while both hands train.")
                    .foregroundStyle(FormCueTheme.muted)

                TextField("Transcript / typed intent", text: $appModel.dictateBuffer, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(2...5)

                HStack(spacing: 12) {
                    Button {
                        Task { await appModel.startDictate() }
                    } label: {
                        Label(appModel.speechBusy ? "Listening…" : "Record", systemImage: "mic.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(FormCueTheme.primary)
                    .disabled(appModel.speechBusy)
                    .accessibilityIdentifier("cta-record")

                    Button("Apply intent") { appModel.applyDictateIntent() }
                        .buttonStyle(.bordered)
                        .tint(FormCueTheme.accent)
                }

                if !appModel.speechTranscript.isEmpty {
                    Text("Last heard: \(appModel.speechTranscript)")
                        .font(.footnote)
                        .foregroundStyle(FormCueTheme.muted)
                }

                if let status = appModel.statusMessage {
                    Text(status).font(.footnote).foregroundStyle(FormCueTheme.ink)
                }
            }
            .padding(20)
        }
        .formCueScreen()
        .navigationTitle("Dictate")
    }
}
