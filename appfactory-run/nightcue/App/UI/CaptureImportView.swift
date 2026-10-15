import PhotosUI
import SwiftUI

struct CaptureImportView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Capture or import a night test frame")
                    .font(.title2.bold())
                    .foregroundStyle(NightCueTheme.ink)

                Text("Camera for fresh tripod shots · Photos for history compare. Permissions are required for the real flows.")
                    .font(.subheadline)
                    .foregroundStyle(NightCueTheme.muted)

                Button {
                    appModel.showCamera = true
                } label: {
                    Label("Camera", systemImage: "camera.fill")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .tint(NightCueTheme.primary)

                PhotosPicker(selection: $appModel.selectedPhotoItem, matching: .images) {
                    Label("Photo library", systemImage: "photo.on.rectangle")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.bordered)
                .tint(NightCueTheme.primary)
                .onChange(of: appModel.selectedPhotoItem) { _, _ in
                    Task { await appModel.importPhotoFromLibrary() }
                }

                if appModel.importBusy {
                    ProgressView("Importing…")
                }

                if let status = appModel.statusMessage {
                    Text(status)
                        .font(.footnote)
                        .foregroundStyle(NightCueTheme.primary)
                }
            }
            .padding(20)
        }
        .nightCueScreen()
        .navigationTitle("Capture")
        .sheet(isPresented: $appModel.showCamera) {
            CameraPicker { image in
                appModel.importCameraImage(image)
            }
            .ignoresSafeArea()
        }
    }
}
