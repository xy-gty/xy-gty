import WorkrestDomain
import SwiftUI

struct FormReviewView: View {
    @EnvironmentObject private var appModel: AppModel
    @FocusState private var editingFocused: Bool

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Form review")
                    .font(.title2.bold())
                    .foregroundStyle(WorkrestTheme.ink)

                if let draft = appModel.pendingDraft {
                    Text("Draft for shot \(draft.formShotId.prefix(8))…")
                        .font(.caption)
                        .foregroundStyle(WorkrestTheme.muted)
                }

                Text("Posture summary")
                    .font(.headline)
                TextField("Posture", text: $appModel.editingPosture, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .focused($editingFocused)
                    .lineLimit(3...6)

                Text("Correction focus")
                    .font(.headline)
                TextField("Focus", text: $appModel.editingFocus, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(2...4)

                HStack(spacing: 12) {
                    Button(FormReviewBar.confirm) { appModel.keepFormDraft() }
                        .buttonStyle(.borderedProminent)
                        .tint(WorkrestTheme.primary)
                        .accessibilityIdentifier("cta-keep-form")
                    Button(FormReviewBar.reject) { appModel.discardFormDraft() }
                        .buttonStyle(.bordered)
                    Button(FormReviewBar.edit) { editingFocused = true }
                        .buttonStyle(.bordered)
                        .tint(WorkrestTheme.accent)
                }

                if let status = appModel.statusMessage {
                    Text(status).font(.footnote).foregroundStyle(WorkrestTheme.ink)
                }
            }
            .padding(20)
        }
        .workrestScreen()
        .navigationTitle("Review")
    }
}
