import SwiftUI
import BroodcheckDomain

struct BroodReviewView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Brood review")
                    .font(.title2.bold())
                    .foregroundStyle(BroodcheckTheme.ink)

                if let shotId = appModel.pendingDraft?.frameShotId,
                   let shot = appModel.frameShots.first(where: { $0.id == shotId }),
                   let image = appModel.loadShotImage(shot) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }

                labeledEditor("Brood", text: $appModel.editingBrood)
                labeledEditor("Stores", text: $appModel.editingStores)
                labeledEditor("Pest signs", text: $appModel.editingPests)

                HStack(spacing: 10) {
                    Button(BroodReviewBar.confirm) { appModel.keepBroodDraft() }
                        .buttonStyle(.borderedProminent)
                        .tint(BroodcheckTheme.accent)
                    Button(BroodReviewBar.reject) { appModel.discardBroodDraft() }
                        .buttonStyle(.bordered)
                    Button(BroodReviewBar.edit) {
                        appModel.statusMessage = "Edit the fields above, then Keep."
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(20)
        }
        .broodcheckScreen()
        .navigationTitle("Review")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func labeledEditor(_ title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(BroodcheckTheme.muted)
            TextEditor(text: text)
                .frame(minHeight: 72)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(BroodcheckTheme.card)
                )
        }
    }
}
