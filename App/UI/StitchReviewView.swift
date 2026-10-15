import SwiftUI
import UIKit
import YarnCueDomain

struct StitchReviewView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Stitch / row review")
                    .font(.title2.bold())
                    .foregroundStyle(YarnCueTheme.ink)

                if let draft = appModel.pendingDraft,
                   let shot = appModel.wipShots.first(where: { $0.id == draft.wipShotId }),
                   let image = appModel.loadShotImage(shot) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                TextField("Stitch name", text: $appModel.editingStitchName)
                    .textFieldStyle(.roundedBorder)
                Stepper("Row \(appModel.editingRowNumber)", value: $appModel.editingRowNumber, in: 1...999)
                TextField("Notes", text: $appModel.editingNotes, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Done") {
                            UIApplication.shared.sendAction(
                                #selector(UIResponder.resignFirstResponder),
                                to: nil, from: nil, for: nil
                            )
                        }
                    }
                }

                HStack(spacing: 12) {
                    Button(StitchReviewBar.confirm) { appModel.keepStitchDraft() }
                        .buttonStyle(.borderedProminent)
                        .tint(YarnCueTheme.lime)
                    Button(StitchReviewBar.reject) { appModel.discardStitchDraft() }
                        .buttonStyle(.bordered)
                    Button(StitchReviewBar.edit) {
                        appModel.statusMessage = "Edit fields above, then Keep."
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(20)
        }
        .yarnCueScreen()
        .navigationTitle("Review")
    }
}
