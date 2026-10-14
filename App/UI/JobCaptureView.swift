import SwiftUI
import PhotosUI

struct JobCaptureView: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Capture or import a duct run photo. You review tags before saving.")
                    .font(.subheadline)
                    .foregroundStyle(DuctCueTheme.ink.opacity(0.85))

                PhotosPicker(selection: $model.selectedPhotoItem, matching: .images) {
                    Label("Choose from library", systemImage: "photo.on.rectangle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(DuctCueTheme.SecondaryButtonStyle())
                .onChange(of: model.selectedPhotoItem) { _, _ in
                    model.handlePickedPhoto()
                }

                Button("Take photo") {
                    model.beginTakePhoto()
                }
                .buttonStyle(DuctCueTheme.PrimaryButtonStyle())
                .accessibilityIdentifier("take_photo")

                Button("Use demo job photo") {
                    model.importDemoJobPhoto()
                }
                .buttonStyle(DuctCueTheme.SecondaryButtonStyle())

                if model.recognitionBusy {
                    ProgressView("Reading duct run…")
                        .padding(.top, 8)
                }
            }
            .padding()
        }
        .background(DuctCueTheme.secondary.ignoresSafeArea())
        .navigationTitle("Job photo")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    if model.path.last == .jobCapture {
                        model.path.removeLast()
                        model.persistPath()
                    } else {
                        dismiss()
                    }
                }
            }
        }
    }
}
