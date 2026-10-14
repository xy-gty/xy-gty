import SwiftUI
import PhotosUI
import KnotCueDomain

struct RopeHomeView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("KnotCue")
                        .font(.largeTitle.bold())
                        .foregroundStyle(KnotCueTheme.primary)
                    Text("Vertical rope-diameter step carousel")
                        .font(.subheadline)
                        .foregroundStyle(KnotCueTheme.muted)
                }
                if model.stages.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("No stages yet")
                            .font(.title3.bold())
                            .foregroundStyle(KnotCueTheme.ink)
                        Text("Snap or import a knot to recognize stage, then keep it on the rope carousel.")
                            .foregroundStyle(KnotCueTheme.muted)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(KnotCueTheme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                RopeDiameterCarousel(
                    diameters: model.diameterChips,
                    selected: model.selectedDiameter,
                    stages: model.stages,
                    onSelectDiameter: { model.selectedDiameter = $0 },
                    onSelectStage: { stage in
                        model.selectedStageID = stage.id
                        model.push(.knotStageDetail)
                    }
                )
                Button("Snap knot") { model.push(.knotCapture) }
                    .buttonStyle(KnotCueTheme.PrimaryButtonStyle())
                Button("Ask coach") {
                    model.selectedTab = .coach
                    if model.chatText.isEmpty {
                        model.chatText = "What's the next haul for a bowline at step 3?"
                    }
                }
                .buttonStyle(KnotCueTheme.SecondaryButtonStyle())
                if model.recognitionBusy {
                    ProgressView("Reading knot stage…")
                }
            }
            .padding(20)
        }
        .background(KnotCueTheme.secondary.ignoresSafeArea())
        .navigationTitle("Rope")
        .navigationBarTitleDisplayMode(.inline)
    }
}
