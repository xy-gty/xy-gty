import OnionreelDomain
import SwiftUI

struct FrameReviewView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Shot-plan draft")
                    .font(.title2.bold())
                    .foregroundStyle(OnionreelTheme.ink)
                if let img = appModel.currentFrameImage() ?? appModel.frameImage(at: max((appModel.activeSequence?.frameRefs.count ?? 1) - 1, 0)) {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                TextField("Shot plan", text: $appModel.editingShotPlan, axis: .vertical)
                    .lineLimit(3...6)
                    .textFieldStyle(.roundedBorder)
                TextField("Timing", text: $appModel.editingTiming, axis: .vertical)
                    .lineLimit(2...4)
                    .textFieldStyle(.roundedBorder)
                if let reason = appModel.aiUnavailableReason {
                    Text(reason).font(.caption).foregroundStyle(OnionreelTheme.muted)
                }
                HStack {
                    Button(FrameReviewBar.reject) { appModel.discardShotPlanDraft() }
                        .buttonStyle(.bordered)
                    Button(FrameReviewBar.edit) { /* fields already editable */ }
                        .buttonStyle(.bordered)
                    Button(FrameReviewBar.confirm) { appModel.keepShotPlanDraft() }
                        .buttonStyle(.borderedProminent)
                        .tint(OnionreelTheme.primary)
                }
            }
            .padding(20)
        }
        .onionreelScreen()
        .navigationTitle("Frame review")
    }
}
