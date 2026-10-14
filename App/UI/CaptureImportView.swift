import PhotosUI
import ScoutCueDomain
import SwiftUI

struct CaptureImportView: View {
    @EnvironmentObject private var appModel: AppModel
    @State private var showCamera = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Shoot on-site or import a prior scouting landscape.")
                    .foregroundStyle(ScoutCueTheme.muted)

                Text(PrivacyUsageCopy.camera)
                    .font(.caption)
                    .foregroundStyle(ScoutCueTheme.muted)
                Text(PrivacyUsageCopy.photoLibrary)
                    .font(.caption)
                    .foregroundStyle(ScoutCueTheme.muted)

                Button {
                    showCamera = true
                } label: {
                    Label("Take photo", systemImage: "camera")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.borderedProminent)
                .tint(ScoutCueTheme.indigo)

                PhotosPicker(selection: $appModel.selectedPhotoItem, matching: .images) {
                    Label("Choose from library", systemImage: "photo.on.rectangle")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.bordered)
                .tint(ScoutCueTheme.indigo)
                .disabled(appModel.importBusy)

                if appModel.importBusy {
                    ProgressView("Importing…")
                }

                if let status = appModel.statusMessage {
                    Text(status).font(.footnote).foregroundStyle(ScoutCueTheme.muted)
                }
            }
            .padding(20)
        }
        .scoutCueScreen()
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
