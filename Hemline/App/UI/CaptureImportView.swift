import SwiftUI
import PhotosUI
import HemlineDomain

struct CaptureImportView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: appModel.cameraHardwareAvailable ? "camera.viewfinder" : "photo.on.rectangle")
                .font(.system(size: 56))
                .foregroundStyle(HemlineTheme.cta)
            HemlineTheme.sectionTitle("Add a piece")
            HemlineTheme.mutedText(
                appModel.cameraHardwareAvailable
                    ? "Snap a garment or pick from your library."
                    : "Camera unavailable here — use the photo library or demo piece."
            )

            if appModel.cameraHardwareAvailable {
                Button("Open camera") {
                    appModel.showCameraPicker = true
                }
                .buttonStyle(CCPrimaryButtonStyle())
                .padding(.horizontal, 24)
            }

            PhotosPicker(selection: $appModel.selectedPhotoItem, matching: .images) {
                Text("Photo library")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(HemlineTheme.ink)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(HemlineTheme.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(HemlineTheme.line, lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .padding(.horizontal, 24)

            Button("Demo piece") {
                appModel.importDemoPiece()
            }
            .buttonStyle(CCSecondaryButtonStyle())
            .padding(.horizontal, 24)

            Spacer()
        }
        .hemlineScene()
        .navigationTitle("Capture")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: appModel.selectedPhotoItem) { _, item in
            guard let item else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    appModel.importPhotoData(data, sourceKind: HemlinePhotoImportFacade.librarySourceKind)
                }
                appModel.selectedPhotoItem = nil
            }
        }
    }
}
