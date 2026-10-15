import StopCueDomain
import SwiftUI

struct OnionSkinGuideView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Onion-skin annotated guide")
                .font(.title3.bold())
                .foregroundStyle(StopCueTheme.ink)
            Text("Tap to place an alignment mark. Keep writes OnionSkinGuide.")
                .font(.subheadline)
                .foregroundStyle(StopCueTheme.muted)
            OnionSkinOverlayCanvas(
                currentImage: appModel.currentFrameImage(),
                previousImage: appModel.previousFrameImage(),
                onionEnabled: true,
                onionOpacity: appModel.onionOpacity,
                marks: appModel.overlayMarks,
                onTap: { appModel.placeDraftOverlay(at: $0) }
            )
            .frame(height: 320)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            TextField("Guide notes", text: $appModel.onionDraftNotes, axis: .vertical)
                .lineLimit(2...4)
                .textFieldStyle(.roundedBorder)
            HStack {
                Button(FrameReviewBar.reject) { appModel.discardOnionGuide() }
                    .buttonStyle(.bordered)
                Button(FrameReviewBar.confirm) { appModel.keepOnionGuide() }
                    .buttonStyle(.borderedProminent)
                    .tint(StopCueTheme.accent)
            }
            Spacer()
        }
        .padding(20)
        .stopCueScreen()
        .navigationTitle("Onion guide")
    }
}
