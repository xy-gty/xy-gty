import FrameCueDomain
import SwiftUI

struct SlateStageView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                let title = appModel.activeSession?.title ?? "Slate"
                ClapperFrameCanvas(
                    title: title,
                    shotLabel: appModel.selectedChip,
                    pulse: appModel.ttsPulse
                ) {
                    ZStack {
                        if let still = appModel.sessionStills.last,
                           let image = appModel.stillImage(still) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .overlay { overlayGuides }
                        } else {
                            VStack(spacing: 8) {
                                Image(systemName: "rectangle.dashed")
                                    .font(.largeTitle)
                                    .foregroundStyle(FrameCueTheme.primary.opacity(0.4))
                                Text("No still yet — capture or import")
                                    .foregroundStyle(FrameCueTheme.muted)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 240)
                }

                ShotSizeChipBar(
                    chips: appModel.chips,
                    selected: appModel.selectedChip,
                    onSelect: { appModel.selectChip($0) }
                )

                if let note = appModel.sessionNote {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Kept composition")
                            .font(.headline)
                            .foregroundStyle(FrameCueTheme.ink)
                        Text(note.subject)
                            .font(.subheadline)
                            .foregroundStyle(FrameCueTheme.muted)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 10).fill(FrameCueTheme.card))
                }

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    navButton("Ask coach", "bubble.left.and.bubble.right.fill") { appModel.push(.coachChat) }
                    navButton("Overlays", "square.dashed") { appModel.push(.overlayMarks) }
                    navButton("Hands-free", "speaker.wave.2.fill") { appModel.push(.handsFreeTTS) }
                    navButton("Dictate", "mic.fill") { appModel.push(.dictateShot) }
                    navButton("Capture", "camera.fill") { appModel.push(.captureImport) }
                }

                if let status = appModel.statusMessage {
                    Text(status).font(.footnote).foregroundStyle(FrameCueTheme.muted)
                }
            }
            .padding(16)
        }
        .frameCueScreen()
        .navigationTitle("Stage")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var overlayGuides: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            ZStack {
                if appModel.safeFrameEnabled || appModel.sessionOverlays.first?.safeFrameEnabled == true {
                    Rectangle()
                        .stroke(FrameCueTheme.accent.opacity(0.85), lineWidth: 2)
                        .padding(w * 0.06)
                }
                if appModel.ruleOfThirdsEnabled || appModel.sessionOverlays.first?.ruleOfThirdsEnabled == true {
                    Path { p in
                        p.move(to: CGPoint(x: w / 3, y: 0)); p.addLine(to: CGPoint(x: w / 3, y: h))
                        p.move(to: CGPoint(x: 2 * w / 3, y: 0)); p.addLine(to: CGPoint(x: 2 * w / 3, y: h))
                        p.move(to: CGPoint(x: 0, y: h / 3)); p.addLine(to: CGPoint(x: w, y: h / 3))
                        p.move(to: CGPoint(x: 0, y: 2 * h / 3)); p.addLine(to: CGPoint(x: w, y: 2 * h / 3))
                    }
                    .stroke(FrameCueTheme.primary.opacity(0.55), lineWidth: 1)
                }
            }
        }
        .allowsHitTesting(false)
    }

    private func navButton(_ title: String, _ icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        }
        .buttonStyle(.bordered)
        .tint(FrameCueTheme.primary)
    }
}
