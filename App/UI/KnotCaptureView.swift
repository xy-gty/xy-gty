import SwiftUI
import PhotosUI

struct KnotCaptureView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        VStack(spacing: 20) {
            Text("Photograph or import a rope knot in progress.")
                .multilineTextAlignment(.center)
                .foregroundStyle(KnotCueTheme.ink)
                .padding(.top, 24)
            Button("Take photo") { model.beginTakePhoto() }
                .buttonStyle(KnotCueTheme.PrimaryButtonStyle())
            PhotosPicker(selection: $model.selectedPhotoItem, matching: .images) {
                Text("Import from Photos")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(KnotCueTheme.SecondaryButtonStyle())
            .onChange(of: model.selectedPhotoItem) { _, _ in
                model.handlePickedPhoto()
            }
            Button("Use demo bowline still") { model.importDemoKnotPhoto() }
                .buttonStyle(KnotCueTheme.SecondaryButtonStyle())
            Spacer()
        }
        .padding(20)
        .background(KnotCueTheme.secondary.ignoresSafeArea())
        .navigationTitle("Knot capture")
    }
}
