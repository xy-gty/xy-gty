import PhotosUI
import SwiftUI

struct CaptureImportView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ClapperFrameCanvas(title: "Capture", shotLabel: appModel.selectedChip) {
                    VStack(spacing: 10) {
                        Image(systemName: "camera.viewfinder")
                            .font(.system(size: 40))
                            .foregroundStyle(FrameCueTheme.primary)
                        Text("Shoot a trial frame or import a scout still.")
                            .multilineTextAlignment(.center)
                            .foregroundStyle(FrameCueTheme.ink)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, minHeight: 180)
                }

                Button {
                    appModel.showCamera = true
                } label: {
                    Label("Camera", systemImage: "camera.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(FrameCueTheme.primary)

                PhotosPicker(selection: $appModel.selectedPhotoItem, matching: .images) {
                    Label("Photo library", systemImage: "photo.on.rectangle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(FrameCueTheme.accent)
                .onChange(of: appModel.selectedPhotoItem) { _, _ in
                    Task { await appModel.importPhotoFromLibrary() }
                }

                if appModel.importBusy {
                    ProgressView("Importing…")
                }

                if let status = appModel.statusMessage {
                    Text(status).font(.footnote).foregroundStyle(FrameCueTheme.muted)
                }
            }
            .padding(20)
        }
        .frameCueScreen()
        .navigationTitle("Capture / Import")
        .sheet(isPresented: $appModel.showCamera) {
            CameraPicker { image in
                appModel.importCameraImage(image)
            }
            .ignoresSafeArea()
        }
    }
}
