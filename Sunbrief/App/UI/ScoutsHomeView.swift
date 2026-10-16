import SunbriefDomain
import SwiftUI

struct ScoutsHomeView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Sunbrief")
                            .font(.largeTitle.bold())
                            .foregroundStyle(SunbriefTheme.indigo)
                        Text("AI photo scout · timing planner")
                            .font(.subheadline)
                            .foregroundStyle(SunbriefTheme.muted)
                    }
                    Spacer()
                    Button {
                        appModel.push(.settings)
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundStyle(SunbriefTheme.indigo)
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
                .tint(SunbriefTheme.indigo)

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
                        .foregroundStyle(SunbriefTheme.muted)
                }
            }
            .padding(20)
        }
        .sunbriefScreen()
        .navigationBarHidden(true)
    }

    private func navChip(_ title: String, icon: String, route: SunbriefRoute) -> some View {
        Button {
            appModel.push(route)
        } label: {
            VStack(spacing: 6) {
                Image(systemName: icon)
                Text(title).font(.caption2.weight(.semibold))
            }
            .foregroundStyle(SunbriefTheme.indigo)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: SunbriefTheme.indigo.opacity(0.1), radius: 6, y: 2)
            )
        }
        .buttonStyle(.plain)
    }
}
