import ScoutCueDomain
import SwiftUI

struct SceneReviewView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let draft = appModel.pendingSceneDraft,
                   let shot = appModel.shots.first(where: { $0.id == draft.shotId }),
                   let image = appModel.loadShotImage(shot) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 220)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }

                SoftSceneCard(
                    card: appModel.pendingSceneDraft ?? SceneCard(
                        id: "draft",
                        shotId: "",
                        placeLabel: "Recognizing…",
                        lightQuality: "—",
                        facingHint: "—",
                        status: "draft",
                        updatedAt: Date()
                    ),
                    highlighted: true
                )

                SkyArcTimelineView(
                    windows: appModel.ensureDayWindows(),
                    selectedId: appModel.selectedWindowId
                ) { window in
                    appModel.selectWindow(window)
                }

                TextField("Edit labels (place · light · facing)", text: $appModel.editingLabels)
                    .textFieldStyle(.roundedBorder)
                    .accessibilityLabel(SceneReviewBar.edit)

                HStack(spacing: 12) {
                    Button(SceneReviewBar.reject) {
                        appModel.discardSceneDraft()
                    }
                    .buttonStyle(.bordered)
                    .tint(ScoutCueTheme.muted)

                    Button(SceneReviewBar.confirm) {
                        appModel.keepSceneDraft()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(ScoutCueTheme.indigo)
                }

                Text("Local heuristic labels always available; AI refinement needs key + consent.")
                    .font(.caption)
                    .foregroundStyle(ScoutCueTheme.muted)
            }
            .padding(20)
        }
        .scoutCueScreen()
        .navigationTitle("Scene review")
        .navigationBarTitleDisplayMode(.inline)
    }
}
