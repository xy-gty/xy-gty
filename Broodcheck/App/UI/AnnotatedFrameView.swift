import SwiftUI

struct AnnotatedFrameView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Heat overlay")
                    .font(.title2.bold())
                    .foregroundStyle(BroodcheckTheme.ink)

                Text("Tap the brood frame to place a heat / region mark, then Keep marks.")
                    .font(.subheadline)
                    .foregroundStyle(BroodcheckTheme.muted)

                if let shot = appModel.inspectionShots.first {
                    HeatOverlayCanvas(
                        image: appModel.loadShotImage(shot),
                        overlays: appModel.inspectionOverlays.filter { $0.frameShotId == shot.id },
                        draftPoint: appModel.draftOverlayPoint,
                        onTapNormalized: { point in
                            appModel.placeDraftOverlay(at: point)
                        }
                    )
                } else {
                    ContentUnavailableView(
                        "No brood photo",
                        systemImage: "photo",
                        description: Text("Capture or import a frame first.")
                    )
                    .frame(minHeight: 220)
                }

                Picker("Mark label", selection: $appModel.overlayDraftLabel) {
                    Text("brood").tag("brood")
                    Text("stores").tag("stores")
                    Text("pest").tag("pest")
                    Text("check").tag("check")
                }
                .pickerStyle(.segmented)

                HStack(spacing: 12) {
                    Button("Keep marks") { appModel.keepOverlayMarks() }
                        .buttonStyle(.borderedProminent)
                        .tint(BroodcheckTheme.accent)
                    Button("Discard") { appModel.discardOverlayDraft() }
                        .buttonStyle(.bordered)
                }
            }
            .padding(20)
        }
        .broodcheckScreen()
        .navigationTitle("Annotated frame")
    }
}
