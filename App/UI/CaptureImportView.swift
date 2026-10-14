import SwiftUI
import PhotosUI
import BendCoachDomain

struct CaptureImportView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        ZStack {
            BendCoachTheme.bg.ignoresSafeArea()
            VStack(spacing: 20) {
                Text("Capture or import a job-site bend photo")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(BendCoachTheme.ink)
                    .multilineTextAlignment(.center)

                Button { model.beginTakePhoto() } label: {
                    Label("Capture photo", systemImage: "camera.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(BendCoachTheme.cta)
                        .foregroundStyle(Color.black.opacity(0.85))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .accessibilityIdentifier("capture_photo")

                PhotosPicker(selection: $model.selectedPhotoItem, matching: .images) {
                    Label("Import from library", systemImage: "photo.on.rectangle")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(BendCoachTheme.surface)
                        .foregroundStyle(BendCoachTheme.ink)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .accessibilityIdentifier("import_library")
                .onChange(of: model.selectedPhotoItem) { _, _ in
                    Task { await model.importPhoto() }
                }

                if model.recognitionBusy {
                    ProgressView("Reading field marks…")
                        .tint(BendCoachTheme.cta)
                }

                if !model.activePhotos.isEmpty {
                    Text("\(model.activePhotos.count) photo(s) on this job")
                        .foregroundStyle(BendCoachTheme.muted)
                    NavigationLink(value: CoachRoute.bendReview) {
                        Text("Review bend draft")
                            .foregroundStyle(BendCoachTheme.diagram)
                    }
                }
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Capture")
        .fullScreenCover(isPresented: $model.showCameraPicker) {
            CameraCapturePicker(
                onImageData: { data in Task { await model.handleCameraImageData(data) } },
                onCancel: { model.cancelCameraPicker() }
            )
            .ignoresSafeArea()
        }
    }
}
