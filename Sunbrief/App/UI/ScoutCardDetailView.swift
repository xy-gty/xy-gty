import SunbriefDomain
import SwiftUI

struct ScoutCardDetailView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let card = appModel.activeCard {
                    SoftSceneCard(card: card, highlighted: true)

                    if let shot = appModel.activeShot, let image = appModel.loadShotImage(shot) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 180)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }

                    SkyArcTimelineView(
                        windows: appModel.cardWindows,
                        selectedId: appModel.selectedWindowId
                    ) { window in
                        appModel.selectWindow(window)
                    }

                    if let plan = appModel.activePlan {
                        Text(plan.title)
                            .font(.headline)
                            .foregroundStyle(SunbriefTheme.ink)
                        if !plan.notes.isEmpty {
                            Text(plan.notes)
                                .font(.footnote)
                                .foregroundStyle(SunbriefTheme.muted)
                        }
                    }

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        detailButton("Open coach", icon: "bubble.left", route: .coachChat)
                        detailButton("Golden overlay", icon: "pencil.tip", route: .goldenOverlay)
                        detailButton("Next-stop brief", icon: "speaker.wave.2", route: .nextStopBriefing)
                        detailButton("Dictate note", icon: "mic", route: .dictateNote)
                    }
                } else {
                    Text("No scout card yet — capture scenery first.")
                        .foregroundStyle(SunbriefTheme.muted)
                }

                if let status = appModel.statusMessage {
                    Text(status).font(.footnote).foregroundStyle(SunbriefTheme.muted)
                }
            }
            .padding(20)
        }
        .sunbriefScreen()
        .navigationTitle("Scout card")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func detailButton(_ title: String, icon: String, route: SunbriefRoute) -> some View {
        Button {
            appModel.push(route)
        } label: {
            Label(title, systemImage: icon)
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
        }
        .buttonStyle(.borderedProminent)
        .tint(route == .coachChat ? SunbriefTheme.indigo : SunbriefTheme.rose.opacity(0.85))
    }
}
