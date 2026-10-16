import PhotosUI
import SwiftUI

struct CaptureImportView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Capture / import brood frame")
                    .font(.title2.bold())
                    .foregroundStyle(BroodcheckTheme.ink)

                Text("Camera for the live frame · Photo library for history compare.")
                    .font(.subheadline)
                    .foregroundStyle(BroodcheckTheme.muted)

                Button {
                    appModel.showCamera = true
                } label: {
                    Label("Camera", systemImage: "camera.fill")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .tint(BroodcheckTheme.primary)
                .accessibilityLabel("Open camera for brood frame")

                PhotosPicker(
                    selection: $appModel.selectedPhotoItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    Label("Photo library", systemImage: "photo.on.rectangle")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.bordered)
                .tint(BroodcheckTheme.accent)
                .onChange(of: appModel.selectedPhotoItem) { _, _ in
                    Task { await appModel.importPhotoFromLibrary() }
                }

                if appModel.importBusy {
                    ProgressView("Importing…")
                        .tint(BroodcheckTheme.primary)
                }

                if let status = appModel.statusMessage {
                    Text(status)
                        .font(.footnote)
                        .foregroundStyle(BroodcheckTheme.primary)
                }

                Text("Simulator: camera may open the photo library stub. Device camera is the real capture path.")
                    .font(.caption)
                    .foregroundStyle(BroodcheckTheme.muted)
            }
            .padding(20)
        }
        .broodcheckScreen()
        .navigationTitle("Capture")
        .sheet(isPresented: $appModel.showCamera) {
            CameraPicker { image in
                appModel.importCameraImage(image)
            }
            .ignoresSafeArea()
        }
    }
}
