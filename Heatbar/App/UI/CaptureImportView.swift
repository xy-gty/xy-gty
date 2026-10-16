import SwiftUI
import PhotosUI

struct CaptureImportView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Capture or import finish strip")
                    .font(.title2.bold())
                    .foregroundStyle(HeatbarTheme.ink)

                Text("Camera for on-rack finish slits; Photos for training or amateur-meet strips.")
                    .font(.subheadline)
                    .foregroundStyle(HeatbarTheme.muted)

                Button {
                    appModel.showCamera = true
                } label: {
                    Label("Snap finish", systemImage: "camera.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(HeatbarTheme.primary, in: RoundedRectangle(cornerRadius: 14))
                        .foregroundStyle(.white)
                }
                .accessibilityIdentifier("SnapFinish")

                PhotosPicker(selection: $appModel.selectedPhotoItem, matching: .images) {
                    Label("Import strip", systemImage: "photo.on.rectangle")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(HeatbarTheme.accent, in: RoundedRectangle(cornerRadius: 14))
                        .foregroundStyle(.white)
                }
                .accessibilityIdentifier("ImportStrip")
                .onChange(of: appModel.selectedPhotoItem) { _, _ in
                    appModel.handlePhotoItemChange()
                }

                Button("Cancel") {
                    appModel.popToHome()
                }
                .foregroundStyle(HeatbarTheme.muted)
            }
            .padding(20)
        }
        .heatbarScreen()
        .navigationTitle("Capture")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("CaptureImport")
    }
}
