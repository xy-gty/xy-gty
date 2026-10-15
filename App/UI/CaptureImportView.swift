import PhotosUI
import SwiftUI

struct CaptureImportView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        VStack(spacing: 20) {
            Text("Capture or import frames")
                .font(.title3.bold())
                .foregroundStyle(StopCueTheme.ink)
            Text("Camera for frame-by-frame capture · Photos for sequence import")
                .font(.subheadline)
                .foregroundStyle(StopCueTheme.muted)
                .multilineTextAlignment(.center)

            Button {
                appModel.showCamera = true
            } label: {
                Label("Capture frame", systemImage: "camera.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(StopCueTheme.primary)

            PhotosPicker(selection: $appModel.selectedPhotoItem, matching: .images) {
                Label("Import sequence frame", systemImage: "photo.on.rectangle")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(StopCueTheme.accent)
            .onChange(of: appModel.selectedPhotoItem) { _, _ in
                Task { await appModel.importPhotoFromLibrary() }
            }

            if appModel.importBusy {
                ProgressView("Importing…")
            }

            if let msg = appModel.statusMessage {
                Text(msg).font(.footnote).foregroundStyle(StopCueTheme.muted)
            }
            Spacer()
        }
        .padding(24)
        .stopCueScreen()
        .navigationTitle("Capture / Import")
        .sheet(isPresented: $appModel.showCamera) {
            CameraPicker { image in
                appModel.importCameraImage(image)
            }
            .ignoresSafeArea()
        }
    }
}
