import SwiftUI
import KnotCueDomain

struct StageReviewView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Review proposed stage")
                    .font(.title2.bold())
                    .foregroundStyle(KnotCueTheme.primary)
                if let draft = model.editingDraft {
                    Text(draft.proposedStageTags.joined(separator: " · "))
                        .font(.headline)
                    if let wrong = draft.proposedWrongHauls.first {
                        Text(wrong).foregroundStyle(KnotCueTheme.warn)
                    }
                    if let mm = draft.proposedRopeDiameterMM {
                        Text("\(Int(mm)) mm rope").foregroundStyle(KnotCueTheme.accent)
                    }
                    TextField("Edit stage tags", text: $model.stageEditBuffer)
                        .textFieldStyle(.roundedBorder)
                }
                Button(KnotCueReviewControls.confirm) { model.keepStage() }
                    .buttonStyle(KnotCueTheme.PrimaryButtonStyle())
                Button(KnotCueReviewControls.edit) { model.beginEditStage() }
                    .buttonStyle(KnotCueTheme.SecondaryButtonStyle())
                Button(KnotCueReviewControls.reject) { model.rejectDraft() }
                    .buttonStyle(KnotCueTheme.SecondaryButtonStyle())
                Text(KnotCueIdentity.coachingDisclaimer)
                    .font(.footnote)
                    .foregroundStyle(KnotCueTheme.muted)
            }
            .padding(20)
        }
        .background(KnotCueTheme.secondary.ignoresSafeArea())
        .navigationTitle("Stage review")
    }
}
