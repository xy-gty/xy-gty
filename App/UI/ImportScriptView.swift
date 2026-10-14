import SwiftUI
import PhotosUI
import UIKit

struct ImportScriptView: View {
    @EnvironmentObject private var model: AppModel
    @State private var showCamera = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Import a script page")
                .font(.title2.weight(.bold))
                .foregroundStyle(CueTheme.ink)
            Text("Camera for handwritten/print drafts, or photo library for existing stills. OCR runs on device before review.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            PhotosPicker(selection: $model.selectedPhotoItem, matching: .images) {
                labelRow(title: "Photo library", systemImage: "photo.on.rectangle")
            }
            .onChange(of: model.selectedPhotoItem) { _, _ in
                Task { await model.importPhotoFromPicker() }
            }

            Button { showCamera = true } label: {
                labelRow(title: "Camera", systemImage: "camera")
            }

            Button {
                Task { await model.importSimulatorTestStill() }
            } label: {
                labelRow(title: "Simulator test still", systemImage: "wand.and.stars")
            }

            if model.ocrBusy {
                ProgressView("Running OCR…")
            }

            Spacer()
        }
        .padding()
        .background(CueTheme.background.ignoresSafeArea())
        .navigationTitle("Import script")
        .sheet(isPresented: $showCamera) {
            CameraCaptureView { data in
                showCamera = false
                guard let data else { return }
                Task {
                    // Stash into a temporary picker-like import via PhotoImportSession path
                    model.selectedPhotoItem = nil
                    await model.importCameraData(data)
                }
            }
        }
    }

    private func labelRow(title: String, systemImage: String) -> some View {
        Label(title, systemImage: systemImage)
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(CueTheme.panel)
            .foregroundStyle(CueTheme.ink)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(CueTheme.curtain.opacity(0.25), lineWidth: 1)
            )
    }
}

struct CameraCaptureView: UIViewControllerRepresentable {
    var onFinish: (Data?) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = UIImagePickerController.isSourceTypeAvailable(.camera) ? .camera : .photoLibrary
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(onFinish: onFinish) }

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let onFinish: (Data?) -> Void
        init(onFinish: @escaping (Data?) -> Void) { self.onFinish = onFinish }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) { onFinish(nil) }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            let image = info[.originalImage] as? UIImage
            onFinish(image?.jpegData(compressionQuality: 0.9))
        }
    }
}
