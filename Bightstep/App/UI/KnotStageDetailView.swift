import SwiftUI
import BightstepDomain

struct KnotStageDetailView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let stage = model.selectedStage {
                    Text(stage.stageTags.joined(separator: " · "))
                        .font(.title2.bold())
                        .foregroundStyle(BightstepTheme.ink)
                    if let mm = stage.ropeDiameterMM {
                        Text("\(Int(mm)) mm").foregroundStyle(BightstepTheme.accent)
                    }
                    ForEach(stage.wrongHauls, id: \.self) { wrong in
                        Text(wrong).foregroundStyle(BightstepTheme.warn)
                    }
                    Button("Ask coach with this stage") {
                        model.selectedTab = .coach
                        model.chatText = "Next haul for \(stage.stageTags.first ?? "this stage")?"
                    }
                    .buttonStyle(BightstepTheme.PrimaryButtonStyle())
                    Button("Make step overlay") { model.makeStepOverlay() }
                        .buttonStyle(BightstepTheme.SecondaryButtonStyle())
                    Button("Hands-free coach") { model.openHandsFree(stage: stage) }
                        .buttonStyle(BightstepTheme.SecondaryButtonStyle())
                } else {
                    Text("No stage selected.")
                }
            }
            .padding(20)
        }
        .background(BightstepTheme.secondary.ignoresSafeArea())
        .navigationTitle("Stage")
    }
}
