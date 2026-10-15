import PhotosUI
import SwiftUI

struct CaptureImportView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Capture or import")
                    .font(.title2.bold())
                    .foregroundStyle(RuleCueTheme.ink)
                Text("Snap rulebook pages, component close-ups, or the current table layout — or import past table photos.")
                    .foregroundStyle(RuleCueTheme.muted)

                if let status = appModel.statusMessage {
                    Text(status)
                        .font(.footnote)
                        .foregroundStyle(RuleCueTheme.accent)
                }

                Button {
                    appModel.showCamera = true
                } label: {
                    Label("Capture page / table", systemImage: "camera.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .tint(RuleCueTheme.primary)

                PhotosPicker(
                    selection: $appModel.selectedPhotoItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    Label("Import photos", systemImage: "photo.on.rectangle")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.bordered)
                .tint(RuleCueTheme.accent)
                .onChange(of: appModel.selectedPhotoItem) { _, _ in
                    Task { await appModel.importPhotoFromLibrary() }
                }

                if appModel.importBusy {
                    ProgressView("Importing…")
                }

                if !appModel.sessionPhotos.isEmpty {
                    Text("Photos in session: \(appModel.sessionPhotos.count)")
                        .font(.subheadline)
                        .foregroundStyle(RuleCueTheme.ink)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(appModel.sessionPhotos, id: \.id) { photo in
                                if let image = appModel.photoImage(photo) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 88, height: 88)
                                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                }
                            }
                        }
                    }
                }

                Text("Permission denied? You can still browse a local empty session and type questions later.")
                    .font(.caption)
                    .foregroundStyle(RuleCueTheme.muted)
            }
            .padding(20)
        }
        .ruleCueScreen()
        .navigationTitle("Capture / Import")
        .sheet(isPresented: $appModel.showCamera) {
            CameraPicker { image in
                appModel.importCameraImage(image)
            }
            .ignoresSafeArea()
        }
    }
}
