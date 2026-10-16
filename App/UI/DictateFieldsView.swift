import SwiftUI
import AppRuntimeCore

struct DictateFieldsView: View {
    @EnvironmentObject private var appModel: AppModel
    @FocusState private var fieldFocused: Bool

    var body: some View {
        RuntimeForm(dismissFocus: { fieldFocused = false }) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Dictate inspection fields")
                    .font(.title2.bold())
                    .foregroundStyle(BroodcheckTheme.ink)

                Text("Microphone + Speech Recognition write queen seen, temperament, and notes.")
                    .font(.subheadline)
                    .foregroundStyle(BroodcheckTheme.muted)

                fieldRow(title: "Queen seen", text: $appModel.queenSeen, key: "queen_seen")
                fieldRow(title: "Temperament", text: $appModel.temperament, key: "temperament")
                fieldRow(title: "Notes", text: $appModel.notesField, key: "notes")

                if appModel.speechBusy {
                    ProgressView("Listening…")
                        .tint(BroodcheckTheme.primary)
                }

                if !appModel.speechTranscript.isEmpty {
                    Text("Last transcript: \(appModel.speechTranscript)")
                        .font(.caption)
                        .foregroundStyle(BroodcheckTheme.muted)
                }

                if let status = appModel.statusMessage {
                    Text(status)
                        .font(.footnote)
                        .foregroundStyle(BroodcheckTheme.primary)
                }
            }
            .padding(20)
        } actions: {
            Button("Save typed fields") {
                fieldFocused = false
                appModel.saveTypedFields()
            }
            .buttonStyle(.borderedProminent)
            .tint(BroodcheckTheme.accent)
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(BroodcheckTheme.secondary)
        }
        .broodcheckScreen()
        .navigationTitle("Dictate")
    }

    private func fieldRow(title: String, text: Binding<String>, key: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(BroodcheckTheme.muted)
            TextField(title, text: text, axis: .vertical)
                .focused($fieldFocused)
                .lineLimit(1 ... 3)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(BroodcheckTheme.card)
                )
            Button {
                appModel.startDictate(fieldKey: key)
            } label: {
                Label("Record \(title)", systemImage: "mic.fill")
            }
            .buttonStyle(.bordered)
            .tint(BroodcheckTheme.primary)
            .accessibilityLabel("Record \(title) with microphone")
        }
    }
}
