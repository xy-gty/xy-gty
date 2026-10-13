import SwiftUI
import UIKit
import PhotosUI

struct CaptureView: View {
    @EnvironmentObject private var model: AppModel
    @State private var showCamera = false

    private var cameraAvailable: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(model.activeAudit?.title ?? "No audit")
                    .font(.title3.weight(.semibold))
                Text("Import walkthrough photos from library. Camera capture is available on device; Simulator uses photo library.")
                    .foregroundStyle(.secondary)

                if let msg = model.statusMessage {
                    StatusBanner(message: msg)
                }

                PhotosPicker(selection: $model.selectedPhotoItem, matching: .images) {
                    Label("Add photos", systemImage: "photo.on.rectangle")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .tint(SnagTheme.steel)
                .disabled(model.recognitionBusy)

                if cameraAvailable {
                    Button {
                        showCamera = true
                    } label: {
                        Label("Take photo (camera)", systemImage: "camera.fill")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                    .buttonStyle(.bordered)
                    .disabled(model.recognitionBusy)
                } else {
                    Text("Camera capture: 真机待测 (Simulator has no camera; use photo library here).")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                if model.recognitionBusy {
                    ProgressView("Working…")
                }

                ForEach(model.activePhotos) { photo in
                    HStack {
                        if let ui = UIImage(contentsOfFile: model.photoURL(for: photo).path) {
                            Image(uiImage: ui)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 64, height: 64)
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        VStack(alignment: .leading) {
                            Text("Photo \(photo.sequence)")
                            Text(photo.relativePath)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                PrimaryCTA(title: "Detect snags", systemImage: "sparkles") {
                    model.detectSnags()
                }
                .disabled(model.activePhotos.isEmpty || model.recognitionBusy)

                if !model.activePhotos.isEmpty {
                    NavigationLink(value: SnagRoute.review) {
                        Label("Review snag drafts", systemImage: "eye")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(.bordered)
                }

                Text("Leaving this screen keeps imported photos for this audit. Discard only removes unsaved snag drafts from review.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
        .background(SnagTheme.background.ignoresSafeArea())
        .navigationTitle("Capture")
        .onChange(of: model.selectedPhotoItem) { _, _ in
            Task { await model.importPhoto() }
        }
        .fullScreenCover(isPresented: $showCamera) {
            WalkthroughCameraPicker { data in
                Task { await model.importCapturedImage(data) }
            }
            .ignoresSafeArea()
        }
    }
}

private struct WalkthroughCameraPicker: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    var onImageData: (Data) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onImageData: onImageData, dismiss: dismiss)
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onImageData: (Data) -> Void
        let dismiss: DismissAction

        init(onImageData: @escaping (Data) -> Void, dismiss: DismissAction) {
            self.onImageData = onImageData
            self.dismiss = dismiss
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            defer { dismiss() }
            guard let image = info[.originalImage] as? UIImage,
                  let data = image.jpegData(compressionQuality: 0.85) else { return }
            onImageData(data)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            dismiss()
        }
    }
}
