import PhotosUI
import SwiftUI

struct CaptureImportView: View {
    @EnvironmentObject private var appModel: AppModel
    @State private var showCamera = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Capture or import sheet music / fingering photos for coaching.")
                    .foregroundStyle(PitchCueTheme.muted)

                PhotosPicker(selection: $appModel.selectedPhotoItem, matching: .images) {
                    Label("Photo library", systemImage: "photo.on.rectangle")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .tint(PitchCueTheme.violet)
                .disabled(appModel.importBusy)

                Button {
                    showCamera = true
                } label: {
                    Label("Camera", systemImage: "camera")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.bordered)
                .tint(PitchCueTheme.violet)

                if appModel.importBusy {
                    ProgressView("Importing…")
                }

                if let photo = appModel.activePhoto {
                    Text("Imported: \(photo.relativePath) (\(photo.source))")
                        .font(.footnote)
                    Button("Continue to Coach chat") {
                        appModel.push(.coachChat)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(PitchCueTheme.mint)
                }

                if let status = appModel.statusMessage {
                    Text(status).font(.footnote).foregroundStyle(PitchCueTheme.muted)
                }
            }
            .padding(20)
        }
        .pitchCueScreen()
        .navigationTitle("Capture / Import")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: appModel.selectedPhotoItem) { _, _ in
            Task { await appModel.importPhotoFromLibrary() }
        }
        .sheet(isPresented: $showCamera) {
            CameraPicker { image in
                appModel.importCameraImage(image)
            }
            .ignoresSafeArea()
        }
    }
}
