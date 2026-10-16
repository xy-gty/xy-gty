import SwiftUI
import PhotosUI
import BrewCueDomain

struct CaptureImportView: View {
    @EnvironmentObject private var appModel: AppModel
    private let kinds = ["beans", "grounds", "bloom", "pour", "crema"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Capture or import")
                    .font(.title2.bold())
                    .foregroundStyle(BrewCueTheme.ink)
                Text("Choose what the shot shows, then snap with Camera or import from Photos.")
                    .font(.subheadline)
                    .foregroundStyle(BrewCueTheme.muted)

                Text("Shot kind")
                    .font(.headline)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(kinds, id: \.self) { kind in
                            Button {
                                appModel.shotKind = kind
                            } label: {
                                Text(kind.capitalized)
                                    .font(.subheadline.weight(.semibold))
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule().fill(appModel.shotKind == kind ? BrewCueTheme.accent : BrewCueTheme.secondary)
                                    )
                                    .foregroundStyle(appModel.shotKind == kind ? Color.white : BrewCueTheme.ink)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                Button {
                    appModel.showCamera = true
                } label: {
                    Label("Snap brew", systemImage: "camera.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(BrewCueTheme.primary)
                .accessibilityIdentifier("SnapBrew")

                PhotosPicker(selection: $appModel.selectedPhotoItem, matching: .images) {
                    Label("Import shot", systemImage: "photo.on.rectangle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(BrewCueTheme.accent)
                .accessibilityIdentifier("ImportShot")
                .onChange(of: appModel.selectedPhotoItem) { _, _ in
                    appModel.handlePhotoItemChange()
                }

                Button("Cancel") {
                    appModel.popToHome()
                }
                .foregroundStyle(BrewCueTheme.muted)
            }
            .padding(20)
        }
        .brewCueScreen()
        .navigationTitle("Capture")
        .accessibilityIdentifier("CaptureImport")
    }
}
