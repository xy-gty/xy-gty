import NightCueDomain
import SwiftUI

struct ExposureReviewView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Exposure / noise diagnosis")
                    .font(.title2.bold())
                    .foregroundStyle(NightCueTheme.ink)

                if let draft = appModel.pendingDraft,
                   let frame = appModel.nightFrames.first(where: { $0.id == draft.nightFrameId }),
                   let image = appModel.loadFrameImage(frame) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            ExposureDiagnosisOverlayCanvas(
                                marks: appModel.pendingDiagnosisOverlayMarks,
                                showOverlays: true
                            )
                        )
                }

                Group {
                    labeledField("Exposure", text: $appModel.editingExposure)
                    labeledField("Noise", text: $appModel.editingNoise)
                    labeledField("Trail signs", text: $appModel.editingTrail)
                }

                HStack(spacing: 12) {
                    Button(ExposureReviewBar.reject) { appModel.discardExposureDraft() }
                        .buttonStyle(.bordered)
                    Button(ExposureReviewBar.edit) {
                        appModel.statusMessage = "Edit the fields above, then Keep."
                    }
                    .buttonStyle(.bordered)
                    Button(ExposureReviewBar.confirm) { appModel.keepExposureDraft() }
                        .buttonStyle(.borderedProminent)
                        .tint(NightCueTheme.primary)
                }

                if let status = appModel.statusMessage {
                    Text(status).font(.footnote).foregroundStyle(NightCueTheme.primary)
                }
            }
            .padding(20)
        }
        .nightCueScreen()
        .navigationTitle("Review")
        .navigationBarBackButtonHidden(true)
    }

    private func labeledField(_ title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.caption.bold()).foregroundStyle(NightCueTheme.muted)
            TextField(title, text: text, axis: .vertical)
                .lineLimit(2 ... 4)
                .padding(10)
                .background(NightCueTheme.card)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
    }
}

extension AppModel {
    var pendingDiagnosisOverlayMarks: [ExposureDiagnosisOverlayCanvas.Mark] {
        // Preview marks from local recognizer are already mirrored into confirmed overlays on Keep;
        // for draft review, surface editing summaries as soft zones.
        [
            .init(id: "d1", xNorm: 0.32, yNorm: 0.38, diagnosisValue: 0.7, label: "underexposed"),
            .init(id: "d2", xNorm: 0.55, yNorm: 0.62, diagnosisValue: 0.55, label: "noise"),
        ]
    }
}
