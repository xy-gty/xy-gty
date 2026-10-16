import SwiftUI
import BloomkettleDomain

struct BrewNoteView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                ComplianceBanner()
                if let note = appModel.sessionNotes.first {
                    Text("Brew note")
                        .font(.title2.bold())
                        .foregroundStyle(BloomkettleTheme.primary)
                    LabeledContent("Ratio", value: note.ratioSummary)
                    LabeledContent("Grind", value: note.grindSummary)
                    LabeledContent("Steps", value: note.stepSummary)
                    Text("Status: \(note.status)")
                        .font(.caption)
                        .foregroundStyle(BloomkettleTheme.muted)
                } else {
                    ContentUnavailableView("No note yet", systemImage: "note.text")
                }
                Button("Back home") { appModel.popToHome() }
                    .buttonStyle(.borderedProminent)
                    .tint(BloomkettleTheme.accent)
            }
            .padding(20)
        }
        .bloomkettleScreen()
        .navigationTitle("Note")
        .accessibilityIdentifier("BrewNote")
    }
}
