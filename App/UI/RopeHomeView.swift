import SwiftUI
import PhotosUI
import BightstepDomain

struct RopeHomeView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Bightstep")
                        .font(.largeTitle.bold())
                        .foregroundStyle(BightstepTheme.primary)
                    Text("Vertical rope-diameter step carousel")
                        .font(.subheadline)
                        .foregroundStyle(BightstepTheme.muted)
                }
                if model.stages.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("No stages yet")
                            .font(.title3.bold())
                            .foregroundStyle(BightstepTheme.ink)
                        Text("Snap or import a knot to recognize stage, then keep it on the rope carousel.")
                            .foregroundStyle(BightstepTheme.muted)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(BightstepTheme.surface)
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
                    .buttonStyle(BightstepTheme.PrimaryButtonStyle())
                Button("Ask coach") {
                    model.selectedTab = .coach
                    if model.chatText.isEmpty {
                        model.chatText = "What's the next haul for a bowline at step 3?"
                    }
                }
                .buttonStyle(BightstepTheme.SecondaryButtonStyle())
                if model.recognitionBusy {
                    ProgressView("Reading knot stage…")
                }
            }
            .padding(20)
        }
        .background(BightstepTheme.secondary.ignoresSafeArea())
        .navigationTitle("Rope")
        .navigationBarTitleDisplayMode(.inline)
    }
}
