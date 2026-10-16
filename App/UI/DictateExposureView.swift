import ShutterduskDomain
import SwiftUI

struct DictateExposureView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        Form {
            Section("Exposure fields") {
                TextField("ISO", text: $appModel.isoField)
                TextField("Shutter (s)", text: $appModel.shutterField)
                TextField("Aperture", text: $appModel.apertureField)
                TextField("Notes", text: $appModel.notesField, axis: .vertical)
                    .lineLimit(2 ... 4)
            }

            Section("Speech / microphone") {
                if appModel.speechBusy {
                    ProgressView("Listening…")
                }
                Button("Record ISO") { appModel.startDictate(fieldKey: "iso") }
                Button("Record shutter") { appModel.startDictate(fieldKey: "shutter") }
                Button("Record aperture") { appModel.startDictate(fieldKey: "aperture") }
                Button("Record notes") { appModel.startDictate(fieldKey: "notes") }
                if !appModel.speechTranscript.isEmpty {
                    Text("Transcript: \(appModel.speechTranscript)")
                        .font(.caption)
                        .foregroundStyle(ShutterduskTheme.muted)
                }
            }

            Section {
                Button("Save into coach") {
                    appModel.saveDictatedExposure()
                }
                .tint(ShutterduskTheme.primary)
            }

            if let status = appModel.statusMessage {
                Section {
                    Text(status).font(.footnote).foregroundStyle(ShutterduskTheme.primary)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(ShutterduskTheme.secondary.ignoresSafeArea())
        .navigationTitle("Dictate")
    }
}
