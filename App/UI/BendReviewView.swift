import SwiftUI
import BendCoachDomain

struct BendReviewView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        ZStack {
            BendCoachTheme.bg.ignoresSafeArea()
            if let draft = model.editingDraft ?? model.drafts.last {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Proposed bend")
                        .font(.caption)
                        .foregroundStyle(BendCoachTheme.muted)
                    TextField("Bend type", text: Binding(
                        get: { model.editingDraft?.proposedBendType ?? draft.proposedBendType },
                        set: { model.updateDraftBendType($0) }
                    ))
                    .padding()
                    .background(BendCoachTheme.surface)
                    .foregroundStyle(BendCoachTheme.ink)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    ForEach(Array((model.editingDraft?.markupHints ?? draft.markupHints).enumerated()), id: \.offset) { idx, hint in
                        TextField("Mark \(idx + 1)", text: Binding(
                            get: {
                                let hints = model.editingDraft?.markupHints ?? draft.markupHints
                                return hints.indices.contains(idx) ? hints[idx] : hint
                            },
                            set: { model.updateDraftHint(at: idx, text: $0) }
                        ))
                        .padding()
                        .background(BendCoachTheme.surface)
                        .foregroundStyle(BendCoachTheme.ink)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    Text(BendCoachIdentity.assistiveDisclaimer)
                        .font(.footnote)
                        .foregroundStyle(BendCoachTheme.warn)

                    HStack {
                        Button(BendCoachReviewControls.reject) { model.rejectRecognitionDraft() }
                            .buttonStyle(.bordered)
                        Button(BendCoachReviewControls.edit) {
                            if model.editingDraft == nil { model.editingDraft = draft }
                        }
                        .buttonStyle(.bordered)
                        Spacer()
                        Button(BendCoachReviewControls.confirm) { model.saveRecognitionDraft() }
                            .buttonStyle(.borderedProminent)
                            .tint(BendCoachTheme.cta)
                            .accessibilityIdentifier("save_marks")
                    }
                    Spacer()
                }
                .padding()
                .onAppear {
                    if model.editingDraft == nil { model.editingDraft = draft }
                }
            } else {
                VStack(spacing: 12) {
                    Text("No recognition draft yet")
                        .foregroundStyle(BendCoachTheme.ink)
                    NavigationLink(value: CoachRoute.captureImport) {
                        Text("Capture / import photo")
                    }
                }
            }
        }
        .navigationTitle("Bend review")
        .foregroundStyle(BendCoachTheme.ink)
    }
}
