import PhotosUI
import SwiftUI

struct CaptureImportView: View {
    @EnvironmentObject private var appModel: AppModel
    @State private var showCamera = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Capture or import a mid-set pose")
                    .font(.title2.bold())
                    .foregroundStyle(FormCueTheme.ink)

                Text("Camera for live form · Photos for a reference demo pose.")
                    .foregroundStyle(FormCueTheme.muted)

                Button {
                    showCamera = true
                } label: {
                    Label("Camera", systemImage: "camera.fill")
                        .frame(maxWidth: .infinity, minHeight: 52)
                }
                .buttonStyle(.borderedProminent)
                .tint(FormCueTheme.primary)
                .accessibilityIdentifier("cta-camera")

                PhotosPicker(
                    selection: $appModel.selectedPhotoItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    Label("Photo library", systemImage: "photo.on.rectangle")
                        .frame(maxWidth: .infinity, minHeight: 52)
                }
                .buttonStyle(.bordered)
                .tint(FormCueTheme.accent)
                .accessibilityIdentifier("cta-photo-library")
                .onChange(of: appModel.selectedPhotoItem) { _, _ in
                    Task { await appModel.importPhotoFromLibrary() }
                }

                if appModel.importBusy {
                    ProgressView("Importing…")
                }

                if let status = appModel.statusMessage {
                    Text(status).font(.footnote).foregroundStyle(FormCueTheme.ink)
                }
            }
            .padding(20)
        }
        .formCueScreen()
        .navigationTitle("Capture")
        .sheet(isPresented: $showCamera) {
            CameraPicker { image in
                appModel.importCameraImage(image)
            }
            .ignoresSafeArea()
        }
    }
}
