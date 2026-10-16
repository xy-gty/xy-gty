import PhotosUI
import SwiftUI

struct CaptureImportView: View {
    @EnvironmentObject private var appModel: AppModel
    @State private var showCamera = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Capture or import")
                    .font(.title.bold())
                    .foregroundStyle(LoopwellTheme.ink)

                Text("Camera for yarn / WIP photos; Photo library for prior shots into the coach flow.")
                    .foregroundStyle(LoopwellTheme.muted)

                if appModel.importBusy {
                    ProgressView("Importing…")
                }

                Button {
                    showCamera = true
                } label: {
                    Label("Camera", systemImage: "camera.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(LoopwellTheme.fuchsia)
                .accessibilityIdentifier("cta-camera")

                PhotosPicker(
                    selection: $appModel.selectedPhotoItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    Label("Photo library", systemImage: "photo.on.rectangle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(LoopwellTheme.fuchsia)
                .accessibilityIdentifier("cta-photo-library")
                .onChange(of: appModel.selectedPhotoItem) { _, _ in
                    Task { await appModel.importPhotoFromLibrary() }
                }

                if let status = appModel.statusMessage {
                    Text(status)
                        .font(.footnote)
                        .foregroundStyle(LoopwellTheme.ink)
                }
            }
            .padding(20)
        }
        .loopwellScreen()
        .navigationTitle("Capture")
        .sheet(isPresented: $showCamera) {
            CameraPicker { image in
                appModel.importCameraImage(image)
            }
            .ignoresSafeArea()
        }
    }
}
