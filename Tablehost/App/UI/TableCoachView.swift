import SwiftUI

struct TableCoachView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                if let session = appModel.activeSession {
                    Text(session.gameName)
                        .font(.title2.bold())
                        .foregroundStyle(TablehostTheme.primary)
                    Text("\(session.playerCount) players · zone \(appModel.currentZoneLabel)")
                        .foregroundStyle(TablehostTheme.muted)
                }

                TurnStepBar(
                    steps: appModel.sessionPhases,
                    currentIndex: appModel.currentStepIndex,
                    onSelect: { appModel.selectStep($0) }
                )

                Text("Table zones")
                    .font(.headline)
                    .foregroundStyle(TablehostTheme.ink)

                TableZoneCards(
                    zones: appModel.zoneLabels,
                    selectedIndex: min(appModel.selectedZoneIndex, max(appModel.zoneLabels.count - 1, 0)),
                    onSelect: { appModel.selectZone($0) }
                )

                if let overlay = appModel.sessionOverlays.first {
                    Text("Confirmed overlay: \(overlay.notes)")
                        .font(.footnote)
                        .foregroundStyle(TablehostTheme.accent)
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(TablehostTheme.card)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    coachButton("Chat", icon: "bubble.left.and.bubble.right.fill") {
                        appModel.push(.coachChat)
                    }
                    coachButton("Overlay", icon: "square.dashed") {
                        appModel.push(.setupOverlay)
                    }
                    coachButton("Host", icon: "speaker.wave.2.fill") {
                        appModel.push(.hostTTS)
                    }
                    coachButton("Dictate", icon: "mic.fill") {
                        appModel.push(.dictateRules)
                    }
                }

                if let status = appModel.statusMessage {
                    Text(status)
                        .font(.footnote)
                        .foregroundStyle(TablehostTheme.muted)
                }
            }
            .padding(20)
        }
        .tablehostScreen()
        .navigationTitle("Table coach")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Capture") { appModel.push(.captureImport) }
            }
        }
    }

    private func coachButton(_ title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(TablehostTheme.accent)
                Text(title)
                    .font(.headline)
                    .foregroundStyle(TablehostTheme.ink)
            }
            .frame(maxWidth: .infinity, minHeight: 88)
            .background(TablehostTheme.card)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(TablehostTheme.primary.opacity(0.25), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
