import StopCueDomain
import SwiftUI

struct StopCoachView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(appModel.activeProject?.title ?? "StopCoach")
                    .font(.title2.bold())
                    .foregroundStyle(StopCueTheme.ink)

                FilmSprocketTimeline(
                    labels: appModel.frameLabels,
                    selectedIndex: $appModel.currentFrameIndex,
                    onSelect: { appModel.selectFrame($0) }
                )

                Toggle(isOn: $appModel.showOnionSkin) {
                    Text("Onion-skin overlay")
                        .foregroundStyle(StopCueTheme.ink)
                }
                .tint(StopCueTheme.accent)

                if appModel.showOnionSkin {
                    Slider(value: $appModel.onionOpacity, in: 0.15...0.7)
                        .tint(StopCueTheme.accent)
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
                    Text(msg).font(.footnote).foregroundStyle(StopCueTheme.muted)
                }
            }
            .padding(20)
        }
        .stopCueScreen()
        .navigationTitle("StopCoach")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Capture") { appModel.push(.captureImport) }
                    .foregroundStyle(StopCueTheme.accent)
            }
        }
    }

    private func navButton(_ title: String, icon: String, route: StopCueRoute) -> some View {
        Button {
            appModel.push(route)
        } label: {
            Label(title, systemImage: icon)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        }
        .buttonStyle(.bordered)
        .tint(StopCueTheme.primary)
    }
}
