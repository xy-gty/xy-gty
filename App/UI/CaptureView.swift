import SwiftUI
import UIKit
import PhotosUI

struct CaptureView: View {
    @EnvironmentObject private var model: AppModel

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

                if model.recognitionBusy {
                    ProgressView("Importing…")
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
            }
            .padding()
        }
        .background(SnagTheme.background.ignoresSafeArea())
        .navigationTitle("Capture")
        .onChange(of: model.selectedPhotoItem) { _, _ in
            Task { await model.importPhoto() }
        }
    }
}
