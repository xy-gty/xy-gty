import ScoutCueDomain
import SwiftUI

struct ScoutsHomeView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("ScoutCue")
                            .font(.largeTitle.bold())
                            .foregroundStyle(ScoutCueTheme.indigo)
                        Text("AI photo scout · timing planner")
                            .font(.subheadline)
                            .foregroundStyle(ScoutCueTheme.muted)
                    }
                    Spacer()
                    Button {
                        appModel.push(.settings)
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundStyle(ScoutCueTheme.indigo)
                            .padding(10)
                            .background(Circle().fill(Color.white))
                    }
                    .accessibilityLabel("Settings")
                }

                SkyArcTimelineView(
                    windows: appModel.ensureDayWindows(),
                    selectedId: appModel.selectedWindowId
                ) { window in
                    appModel.selectWindow(window)
                }

                SoftCardStackView(
                    cards: appModel.cards,
                    activeId: appModel.activeCardId
                ) { card in
                    appModel.activeCardId = card.id
                    appModel.push(.scoutCardDetail)
                }

                Button {
                    appModel.push(.captureImport)
                } label: {
                    Label("Capture / Import scenery", systemImage: "camera.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.borderedProminent)
                .tint(ScoutCueTheme.indigo)

                if appModel.activeCard != nil {
                    HStack(spacing: 10) {
                        navChip("Coach", icon: "bubble.left.and.bubble.right", route: .coachChat)
                        navChip("Overlay", icon: "pencil.tip.crop.circle", route: .goldenOverlay)
                        navChip("Brief", icon: "speaker.wave.2.fill", route: .nextStopBriefing)
                        navChip("Note", icon: "mic.fill", route: .dictateNote)
                    }
                }

                if let status = appModel.statusMessage {
                    Text(status)
                        .font(.footnote)
                        .foregroundStyle(ScoutCueTheme.muted)
                }
            }
            .padding(20)
        }
        .scoutCueScreen()
        .navigationBarHidden(true)
    }

    private func navChip(_ title: String, icon: String, route: ScoutCueRoute) -> some View {
        Button {
            appModel.push(route)
        } label: {
            VStack(spacing: 6) {
                Image(systemName: icon)
                Text(title).font(.caption2.weight(.semibold))
            }
            .foregroundStyle(ScoutCueTheme.indigo)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: ScoutCueTheme.indigo.opacity(0.1), radius: 6, y: 2)
            )
        }
        .buttonStyle(.plain)
    }
}
