import SwiftUI
import BightstepDomain

struct StageReviewView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Review proposed stage")
                    .font(.title2.bold())
                    .foregroundStyle(BightstepTheme.primary)
                if let draft = model.editingDraft {
                    Text(draft.proposedStageTags.joined(separator: " · "))
                        .font(.headline)
                    if let wrong = draft.proposedWrongHauls.first {
                        Text(wrong).foregroundStyle(BightstepTheme.warn)
                    }
                    if let mm = draft.proposedRopeDiameterMM {
                        Text("\(Int(mm)) mm rope").foregroundStyle(BightstepTheme.accent)
                    }
                    TextField("Edit stage tags", text: $model.stageEditBuffer)
                        .textFieldStyle(.roundedBorder)
                }
                Button(BightstepReviewControls.confirm) { model.keepStage() }
                    .buttonStyle(BightstepTheme.PrimaryButtonStyle())
                Button(BightstepReviewControls.edit) { model.beginEditStage() }
                    .buttonStyle(BightstepTheme.SecondaryButtonStyle())
                Button(BightstepReviewControls.reject) { model.rejectDraft() }
                    .buttonStyle(BightstepTheme.SecondaryButtonStyle())
                Text(BightstepIdentity.coachingDisclaimer)
                    .font(.footnote)
                    .foregroundStyle(BightstepTheme.muted)
            }
            .padding(20)
        }
        .background(BightstepTheme.secondary.ignoresSafeArea())
        .navigationTitle("Stage review")
    }
}
