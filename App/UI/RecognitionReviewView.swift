import SwiftUI
import DocBriefDomain

struct RecognitionReviewView: View {
    @EnvironmentObject private var model: AppModel
    @State private var editMode = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                DocBriefAIStatusBanner(retry: { model.runRecognition() })

                if let draft = model.editingDraft ?? model.activeDraft {
                    Text("Proposed type: \(draft.proposedType)")
                        .font(.title3.weight(.semibold))
                    ForEach(draft.proposedFields) { field in
                        if editMode {
                            VStack(alignment: .leading) {
                                TextField("Key", text: Binding(
                                    get: { field.key },
                                    set: { model.updateEditingField(id: field.id, key: $0, value: field.value) }
                                ))
                                TextField("Value", text: Binding(
                                    get: { field.value },
                                    set: { model.updateEditingField(id: field.id, key: field.key, value: $0) }
                                ))
                            }
                            .padding()
                            .background(DocBriefTheme.mist)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        } else {
                            LabeledContent(field.key, value: field.value)
                                .padding()
                                .background(DocBriefTheme.mist)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }

                    HStack(spacing: 12) {
                        Button(DocBriefReviewControls.RecognitionReviewBar.confirm) {
                            model.saveRecognitionDraft()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(DocBriefTheme.amber)

                        Button(DocBriefReviewControls.RecognitionReviewBar.reject) {
                            model.rejectRecognitionDraft()
                        }
                        .buttonStyle(.bordered)

                        Button(DocBriefReviewControls.RecognitionReviewBar.edit) {
                            editMode.toggle()
                            if model.editingDraft == nil {
                                model.editingDraft = draft
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                } else {
                    Text("No recognition draft yet. Import a photo and tap Recognize.")
                        .foregroundStyle(.secondary)
                    Button("Recognize") { model.runRecognition() }
                        .buttonStyle(.borderedProminent)
                        .tint(DocBriefTheme.teal)
                    ManualFieldAdder()
                }

                if let message = model.statusMessage {
                    DocBriefErrorRetryBanner(message: message) {
                        model.runRecognition()
                    }
                }

                Text(DocBriefIdentity.nonCertificationDisclaimer)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
        .background(DocBriefTheme.paper.ignoresSafeArea())
        .navigationTitle("Review fields")
        .overlay {
            if model.recognitionBusy { ProgressView("Recognizing…") }
        }
    }
}

private struct ManualFieldAdder: View {
    @EnvironmentObject private var model: AppModel
    @State private var key = ""
    @State private var value = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Add field manually")
                .font(.headline)
            TextField("Key", text: $key)
            TextField("Value", text: $value)
            Button("Add field") {
                model.addManualField(key: key, value: value)
                key = ""
                value = ""
            }
            .disabled(key.isEmpty || value.isEmpty)
        }
        .padding()
        .background(DocBriefTheme.mist)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
