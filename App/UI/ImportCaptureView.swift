import SwiftUI
import PhotosUI

struct ImportCaptureView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        VStack(spacing: 16) {
            Text("Import a document, whiteboard, or receipt photo.")
                .multilineTextAlignment(.center)
                .foregroundStyle(DocBriefTheme.ink.opacity(0.8))
                .padding(.horizontal)

            Text("Leaving this screen keeps photos already added to the brief. Discard batch clears a pending picker selection only.")
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            PhotosPicker(selection: $model.selectedPhotoItem, matching: .images) {
                Label("Add photos", systemImage: "photo.on.rectangle")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                    .background(DocBriefTheme.amber)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .onChange(of: model.selectedPhotoItem) { _, _ in
                Task { await model.importPhoto() }
            }

            if model.recognitionBusy {
                ProgressView("Importing…")
            }

            if !model.activePhotos.isEmpty {
                List(model.activePhotos) { photo in
                    HStack {
                        AsyncImage(url: model.photoURL(for: photo)) { phase in
                            switch phase {
                            case .success(let image):
                                image.resizable().scaledToFill()
                            default:
                                DocBriefTheme.mist
                            }
                        }
                        .frame(width: 44, height: 44)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        Text(photo.localFileName)
                            .font(.footnote)
                    }
                }
                .frame(maxHeight: 180)
                .scrollContentBackground(.hidden)
            }

            if model.selectedPhotoItem != nil {
                Button("Discard batch") {
                    model.selectedPhotoItem = nil
                    model.statusMessage = "Pending photo selection cleared. Saved imports kept."
                }
                .buttonStyle(.bordered)
            }

            Button("Recognize type & fields") {
                model.runRecognition()
            }
            .buttonStyle(.borderedProminent)
            .tint(DocBriefTheme.teal)
            .disabled(model.activePhotos.isEmpty)

            NavigationLink(value: BriefRoute.recognitionReview) {
                Text("Open recognition review")
            }

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DocBriefTheme.paper.ignoresSafeArea())
        .navigationTitle("Import")
    }
}
