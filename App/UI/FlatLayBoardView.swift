import SwiftUI
import ClosetCueDomain

struct FlatLayBoardView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        VStack(spacing: 20) {
            if let board = appModel.pendingBoard, let image = appModel.image(for: board) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .padding(.horizontal, 16)
            } else {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(ClosetCueTheme.surface)
                    .overlay {
                        ClosetCueTheme.mutedText("Flat-lay preview")
                    }
                    .frame(height: 420)
                    .padding(.horizontal, 16)
            }

            Spacer()

            VStack(spacing: 10) {
                Button(ClosetCueReviewControls.FlatLayPreview.confirm) {
                    appModel.saveLook()
                }
                .buttonStyle(CCPrimaryButtonStyle())
                .padding(.horizontal, 24)

                Button(ClosetCueReviewControls.FlatLayPreview.reject) {
                    appModel.discardLook()
                }
                .buttonStyle(CCSecondaryButtonStyle())
                .padding(.horizontal, 24)
            }
            .padding(.bottom, 24)
        }
        .closetCueScene()
        .navigationTitle("Flat-lay")
        .navigationBarTitleDisplayMode(.inline)
    }
}
