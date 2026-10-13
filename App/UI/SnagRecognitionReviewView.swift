import SwiftUI
import SnagCueDomain

struct SnagRecognitionReviewView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        List {
            if let msg = model.statusMessage {
                Section { StatusBanner(message: msg) }
            }
            if model.activeDrafts.isEmpty {
                Section {
                    Text("No snag drafts. Detect snags or add one manually.")
                        .foregroundStyle(.secondary)
                    Button("Add snag") { model.addManualSnag() }
                    Button("Detect snags") { model.detectSnags() }
                }
            } else {
                ForEach(model.activeDrafts) { draft in
                    Section {
                        Text(draft.label).font(.headline)
                        Text("Location hint: \(draft.approxLocationHint.isEmpty ? "—" : draft.approxLocationHint)")
                        Text("Severity: \(draft.severityGuess)")
                        Text(draft.notesHint).font(.footnote).foregroundStyle(.secondary)
                        HStack {
                            Button(SnagReviewBar.confirm) { model.saveDraft(draft) }
                                .buttonStyle(.borderedProminent)
                            Button(SnagReviewBar.reject) { model.rejectDraft(draft) }
                            Button(SnagReviewBar.edit) { model.beginEditDraft(draft) }
                        }
                    }
                }
            }
        }
        .navigationTitle("Snag review")
        .sheet(item: $model.editingDraft) { draft in
            NavigationStack {
                Form {
                    TextField("Label", text: Binding(
                        get: { model.editingDraft?.label ?? draft.label },
                        set: { model.editingDraft?.label = $0 }
                    ))
                    TextField("Location", text: Binding(
                        get: { model.editingDraft?.approxLocationHint ?? "" },
                        set: { model.editingDraft?.approxLocationHint = $0 }
                    ))
                    TextField("Severity", text: Binding(
                        get: { model.editingDraft?.severityGuess ?? "medium" },
                        set: { model.editingDraft?.severityGuess = $0 }
                    ))
                    TextField("Notes", text: Binding(
                        get: { model.editingDraft?.notesHint ?? "" },
                        set: { model.editingDraft?.notesHint = $0 }
                    ))
                }
                .navigationTitle(SnagReviewBar.edit)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") { model.applyEditedDraft() }
                    }
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { model.editingDraft = nil }
                    }
                }
            }
        }
    }
}
