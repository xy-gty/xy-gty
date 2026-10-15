import NightCueDomain
import SwiftUI

struct NightCoachView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let session = appModel.activeSession {
                    Text(session.locationLabel)
                        .font(.title2.bold())
                        .foregroundStyle(NightCueTheme.primary)
                    Text(session.sceneGoal)
                        .font(.subheadline)
                        .foregroundStyle(NightCueTheme.muted)
                }

                NightFrameRail(
                    labels: appModel.frameLabels,
                    selectedIndex: $appModel.currentFrameIndex,
                    onSelect: { appModel.selectFrame($0) }
                )

                Toggle("Exposure-diagnosis overlays", isOn: $appModel.showOverlays)
                    .tint(NightCueTheme.accent)

                ZStack {
                    if let frame = appModel.sessionFrames.first,
                       let image = appModel.loadFrameImage(frame) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    } else {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(NightCueTheme.primary.opacity(0.12))
                            .frame(height: 220)
                            .overlay(
                                VStack(spacing: 8) {
                                    Image(systemName: "moon.stars")
                                        .font(.largeTitle)
                                        .foregroundStyle(NightCueTheme.primary)
                                    Text("Capture a night frame to fill the rail")
                                        .font(.caption)
                                        .foregroundStyle(NightCueTheme.muted)
                                }
                            )
                    }
                    ExposureDiagnosisOverlayCanvas(
                        marks: appModel.overlayMarks,
                        showOverlays: appModel.showOverlays
                    )
                }
                .frame(minHeight: 220)

                if let finding = appModel.sessionFindings.first {
                    Text("Latest: \(finding.tag) — \(finding.detail)")
                        .font(.footnote)
                        .foregroundStyle(NightCueTheme.ink)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(NightCueTheme.card)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }

                VStack(spacing: 10) {
                    Button("Ask coach") { appModel.push(.coachChat) }
                        .buttonStyle(.borderedProminent)
                        .tint(NightCueTheme.primary)
                        .frame(maxWidth: .infinity)
                    HStack {
                        Button("Annotate") { appModel.push(.annotatedOverlay) }
                            .buttonStyle(.bordered)
                        Button("Field cues") { appModel.push(.fieldCueTTS) }
                            .buttonStyle(.bordered)
                        Button("Dictate") { appModel.push(.dictateExposure) }
                            .buttonStyle(.bordered)
                    }
                    Button("Capture another frame") { appModel.push(.captureImport) }
                        .buttonStyle(.bordered)
                }

                if let status = appModel.statusMessage {
                    Text(status).font(.footnote).foregroundStyle(NightCueTheme.primary)
                }
            }
            .padding(20)
        }
        .nightCueScreen()
        .navigationTitle("Night coach")
    }
}
