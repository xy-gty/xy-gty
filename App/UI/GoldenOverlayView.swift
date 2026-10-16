import SunbriefDomain
import SwiftUI

struct GoldenOverlayView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Tap the scenery to place soft golden-hour pins — not measuring rods.")
                    .foregroundStyle(SunbriefTheme.muted)

                ZStack {
                    if let shot = appModel.activeShot, let image = appModel.loadShotImage(shot) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay {
                                GeometryReader { geo in
                                    ForEach(appModel.cardOverlays, id: \.id) { mark in
                                        pin(mark.text, color: SunbriefTheme.rose)
                                            .position(
                                                x: CGFloat(mark.xNorm) * geo.size.width,
                                                y: CGFloat(mark.yNorm) * geo.size.height
                                            )
                                    }
                                    Color.clear
                                        .contentShape(Rectangle())
                                        .gesture(
                                            DragGesture(minimumDistance: 0).onEnded { value in
                                                let p = CGPoint(
                                                    x: min(max(value.location.x / geo.size.width, 0.05), 0.95),
                                                    y: min(max(value.location.y / geo.size.height, 0.05), 0.95)
                                                )
                                                appModel.beginOverlayTap(at: p)
                                            }
                                        )
                                }
                            }
                    } else {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(SunbriefTheme.mist)
                            .frame(height: 220)
                            .overlay(Text("Keep a scout card with a photo first.").foregroundStyle(SunbriefTheme.muted))
                    }
                }

                TextField("Pin label", text: $appModel.overlayDraftText)
                    .textFieldStyle(.roundedBorder)

                HStack {
                    Button("Discard") { appModel.discardOverlayDraft() }
                        .buttonStyle(.bordered)
                    Button("Save overlay") { appModel.saveOverlayMark() }
                        .buttonStyle(.borderedProminent)
                        .tint(SunbriefTheme.indigo)
                }

                ForEach(appModel.cardOverlays, id: \.id) { mark in
                    Label(mark.text, systemImage: "mappin.and.ellipse")
                        .foregroundStyle(SunbriefTheme.indigo)
                }

                if let status = appModel.statusMessage {
                    Text(status).font(.footnote).foregroundStyle(SunbriefTheme.muted)
                }
            }
            .padding(20)
        }
        .sunbriefScreen()
        .navigationTitle("Golden overlay")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func pin(_ text: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
                .shadow(radius: 2)
            Text(text)
                .font(.caption2.weight(.semibold))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.white.opacity(0.92))
                .clipShape(Capsule())
                .foregroundStyle(SunbriefTheme.ink)
        }
    }
}
