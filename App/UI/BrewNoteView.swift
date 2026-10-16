import SwiftUI
import BrewCueDomain

struct BrewNoteView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                ComplianceBanner()
                if let note = appModel.sessionNotes.first {
                    Text("Brew note")
                        .font(.title2.bold())
                        .foregroundStyle(BrewCueTheme.primary)
                    LabeledContent("Ratio", value: note.ratioSummary)
                    LabeledContent("Grind", value: note.grindSummary)
                    LabeledContent("Steps", value: note.stepSummary)
                    Text("Status: \(note.status)")
                        .font(.caption)
                        .foregroundStyle(BrewCueTheme.muted)
                } else {
                    ContentUnavailableView("No note yet", systemImage: "note.text")
                }
                Button("Back home") { appModel.popToHome() }
                    .buttonStyle(.borderedProminent)
                    .tint(BrewCueTheme.accent)
            }
            .padding(20)
        }
        .brewCueScreen()
        .navigationTitle("Note")
        .accessibilityIdentifier("BrewNote")
    }
}
