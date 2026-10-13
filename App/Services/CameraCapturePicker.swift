import SwiftUI
import UIKit

/// UIImagePicker camera bridge. Simulator without camera uses AppModel synthetic path instead.
struct CameraCapturePicker: UIViewControllerRepresentable {
    var onImageData: (Data) -> Void
    var onCancel: () -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
            picker.cameraCaptureMode = .photo
        } else {
            picker.sourceType = .photoLibrary
        }
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onImageData: onImageData, onCancel: onCancel)
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onImageData: (Data) -> Void
        let onCancel: () -> Void

        init(onImageData: @escaping (Data) -> Void, onCancel: @escaping () -> Void) {
            self.onImageData = onImageData
            self.onCancel = onCancel
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            onCancel()
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            let image = (info[.editedImage] as? UIImage) ?? (info[.originalImage] as? UIImage)
            if let image, let data = image.jpegData(compressionQuality: 0.9) {
                onImageData(data)
            } else {
                onCancel()
            }
        }
    }
}

enum CameraCaptureAvailability {
    static var cameraHardwareAvailable: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }
}
