import SwiftUI
import BroodcheckDomain

struct InspectionCoachView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let inspection = appModel.activeInspection {
                    Text(inspection.hiveLabel)
                        .font(.title2.bold())
                        .foregroundStyle(BroodcheckTheme.primary)
                    Text("Frame \(inspection.currentFrameLabel)")
                        .font(.subheadline)
                        .foregroundStyle(BroodcheckTheme.muted)
                }

                HexCombGrid(
                    labels: appModel.frameLabels,
                    selectedIndex: appModel.currentFrameIndex,
                    onSelect: { appModel.selectFrame($0) }
                )

                InspectionRail(
                    steps: appModel.railSteps,
                    currentIndex: appModel.currentFrameIndex,
                    nextHint: appModel.nextRailHint,
                    onSelect: { appModel.selectFrame($0) }
                )

                if let shot = appModel.inspectionShots.first {
                    HeatOverlayCanvas(
                        image: appModel.loadShotImage(shot),
                        overlays: appModel.inspectionOverlays.filter { $0.frameShotId == shot.id },
                        draftPoint: nil,
                        onTapNormalized: nil
                    )
                    .frame(maxHeight: 260)
                }

                if !appModel.inspectionFindings.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Findings")
                            .font(.headline)
                            .foregroundStyle(BroodcheckTheme.ink)
                        ForEach(appModel.inspectionFindings.prefix(4), id: \.id) { finding in
                            HStack(alignment: .top, spacing: 8) {
                                Text(finding.tag.uppercased())
                                    .font(.caption2.bold())
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Capsule().fill(BroodcheckTheme.accent.opacity(0.2)))
                                    .foregroundStyle(BroodcheckTheme.accent)
                                Text(finding.detail)
                                    .font(.footnote)
                                    .foregroundStyle(BroodcheckTheme.ink)
                            }
                        }
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(BroodcheckTheme.card)
                    )
                }

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    actionButton("Ask coach", icon: "bubble.left.fill") {
                        appModel.push(.coachChat)
                    }
                    actionButton("Heat overlay", icon: "flame.fill") {
                        appModel.push(.annotatedFrame)
                    }
                    actionButton("Hands-free", icon: "speaker.wave.2.fill") {
                        appModel.push(.handsFreeTTS)
                    }
                    actionButton("Dictate", icon: "mic.fill") {
                        appModel.push(.dictateFields)
                    }
                    actionButton("Capture", icon: "camera.fill") {
                        appModel.push(.captureImport)
                    }
                }

                if let status = appModel.statusMessage {
                    Text(status)
                        .font(.footnote)
                        .foregroundStyle(BroodcheckTheme.primary)
                }
            }
            .padding(20)
        }
        .broodcheckScreen()
        .navigationTitle("Inspection coach")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func actionButton(_ title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        }
        .buttonStyle(.borderedProminent)
        .tint(BroodcheckTheme.primary)
    }
}
