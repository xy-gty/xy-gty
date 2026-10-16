import OnionreelDomain
import SwiftUI

struct StopCoachView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(appModel.activeProject?.title ?? "StopCoach")
                    .font(.title2.bold())
                    .foregroundStyle(OnionreelTheme.ink)

                FilmSprocketTimeline(
                    labels: appModel.frameLabels,
                    selectedIndex: $appModel.currentFrameIndex,
                    onSelect: { appModel.selectFrame($0) }
                )

                Toggle(isOn: $appModel.showOnionSkin) {
                    Text("Onion-skin overlay")
                        .foregroundStyle(OnionreelTheme.ink)
                }
                .tint(OnionreelTheme.accent)

                if appModel.showOnionSkin {
                    Slider(value: $appModel.onionOpacity, in: 0.15...0.7)
                        .tint(OnionreelTheme.accent)
                }

                OnionSkinOverlayCanvas(
                    currentImage: appModel.currentFrameImage(),
                    previousImage: appModel.previousFrameImage(),
                    onionEnabled: appModel.showOnionSkin,
                    onionOpacity: appModel.onionOpacity,
                    marks: appModel.overlayMarks,
                    onTap: nil
                )
                .frame(height: 280)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    navButton("Chat", icon: "bubble.left", route: .coachChat)
                    navButton("Onion", icon: "square.on.square", route: .onionSkinGuide)
                    navButton("Countdown", icon: "speaker.wave.2", route: .countdownTTS)
                    navButton("Dictate", icon: "mic", route: .dictateInterval)
                }

                if let msg = appModel.statusMessage {
                    Text(msg).font(.footnote).foregroundStyle(OnionreelTheme.muted)
                }
            }
            .padding(20)
        }
        .onionreelScreen()
        .navigationTitle("StopCoach")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Capture") { appModel.push(.captureImport) }
                    .foregroundStyle(OnionreelTheme.accent)
            }
        }
    }

    private func navButton(_ title: String, icon: String, route: OnionreelRoute) -> some View {
        Button {
            appModel.push(route)
        } label: {
            Label(title, systemImage: icon)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        }
        .buttonStyle(.bordered)
        .tint(OnionreelTheme.primary)
    }
}
