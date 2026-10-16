import PhotosUI
import SunbriefDomain
import SwiftUI

struct CaptureImportView: View {
    @EnvironmentObject private var appModel: AppModel
    @State private var showCamera = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Shoot on-site or import a prior scouting landscape.")
                    .foregroundStyle(SunbriefTheme.muted)

                Text(PrivacyUsageCopy.camera)
                    .font(.caption)
                    .foregroundStyle(SunbriefTheme.muted)
                Text(PrivacyUsageCopy.photoLibrary)
                    .font(.caption)
                    .foregroundStyle(SunbriefTheme.muted)

                Button {
                    showCamera = true
                } label: {
                    Label("Take photo", systemImage: "camera")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.borderedProminent)
                .tint(SunbriefTheme.indigo)

                PhotosPicker(selection: $appModel.selectedPhotoItem, matching: .images) {
                    Label("Choose from library", systemImage: "photo.on.rectangle")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.bordered)
                .tint(SunbriefTheme.indigo)
                .disabled(appModel.importBusy)

                if appModel.importBusy {
                    ProgressView("Importing…")
                }

                if let status = appModel.statusMessage {
                    Text(status).font(.footnote).foregroundStyle(SunbriefTheme.muted)
                }
            }
            .padding(20)
        }
        .sunbriefScreen()
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
