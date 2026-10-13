import SwiftUI
import UIKit
import SnagCueDomain

struct SnagRecognitionReviewView: View {
    @EnvironmentObject private var model: AppModel
    @State private var sheetDraft: SnagDraft?

    var body: some View {
        List {
            if let msg = model.statusMessage {
                Section { StatusBanner(message: msg) }
            }
            if let reason = model.aiUnavailableReason, model.activeDrafts.isEmpty {
                Section {
                    Text(reason).font(.footnote).foregroundStyle(.secondary)
                }
            }
            if model.recognitionBusy {
                Section { ProgressView("Detecting snags…") }
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
                        draftPhotoRow(for: draft)
                        Text(draft.label).font(.headline)
                        Text("Location hint: \(draft.approxLocationHint.isEmpty ? "—" : draft.approxLocationHint)")
                        Text("Severity: \(draft.severityGuess)")
                        Text(draft.notesHint).font(.footnote).foregroundStyle(.secondary)
                        HStack {
                            Button(SnagReviewBar.confirm) { model.saveDraft(draft) }
                                .buttonStyle(.borderedProminent)
                                .tint(SnagTheme.steel)
                            Button(SnagReviewBar.reject) { model.rejectDraft(draft) }
                            Button(SnagReviewBar.edit) {
                                model.beginEditDraft(draft)
                                sheetDraft = draft
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Snag review")
        .sheet(item: $sheetDraft) { draft in
            SnagDraftEditSheet(draft: draft) {
                sheetDraft = nil
                model.editingDraft = nil
            }
            .environmentObject(model)
        }
        .onChange(of: model.editingDraft) { _, new in
            if let new { sheetDraft = new }
        }
    }

    @ViewBuilder
    private func draftPhotoRow(for draft: SnagDraft) -> some View {
        if let photo = model.activePhotos.first(where: { $0.id == draft.photoId }),
           let ui = UIImage(contentsOfFile: model.photoURL(for: photo).path) {
            Image(uiImage: ui)
                .resizable()
                .scaledToFill()
                .frame(height: 120)
                .frame(maxWidth: .infinity)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
    }
}

private struct SnagDraftEditSheet: View {
    @EnvironmentObject private var model: AppModel
    @State private var working: SnagDraft
    let onDismiss: () -> Void

    init(draft: SnagDraft, onDismiss: @escaping () -> Void) {
        _working = State(initialValue: draft)
        self.onDismiss = onDismiss
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Label", text: $working.label)
                TextField("Location", text: $working.approxLocationHint)
                TextField("Severity", text: $working.severityGuess)
                TextField("Notes", text: $working.notesHint, axis: .vertical)
                    .lineLimit(2...5)
            }
            .navigationTitle(SnagReviewBar.edit)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        model.editingDraft = working
                        model.applyEditedDraft()
                        onDismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onDismiss)
                }
            }
        }
    }
}
