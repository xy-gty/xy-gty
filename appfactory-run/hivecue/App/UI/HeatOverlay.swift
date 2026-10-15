import SwiftUI
import UIKit
import HiveCueDomain

/// Heat / region overlay canvas on a brood-frame photo.
struct HeatOverlayCanvas: View {
    let image: UIImage?
    let overlays: [AnnotatedOverlay]
    var draftPoint: CGPoint?
    var onTapNormalized: ((CGPoint) -> Void)?

    var body: some View {
        GeometryReader { geo in
            ZStack {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                } else {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(HiveCueTheme.primary.opacity(0.08))
                        .overlay {
                            VStack(spacing: 8) {
                                Image(systemName: "hexagon.fill")
                                    .font(.largeTitle)
                                    .foregroundStyle(HiveCueTheme.primary.opacity(0.45))
                                Text("No brood frame yet")
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(HiveCueTheme.muted)
                            }
                        }
                }

                ForEach(overlays, id: \.id) { mark in
                    Circle()
                        .fill(heatColor(mark.heatValue).opacity(0.55))
                        .frame(width: 36 + mark.heatValue * 28, height: 36 + mark.heatValue * 28)
                        .position(
                            x: mark.xNorm * geo.size.width,
                            y: mark.yNorm * geo.size.height
                        )
                        .overlay {
                            Text(mark.label)
                                .font(.caption2.bold())
                                .foregroundStyle(HiveCueTheme.ink)
                                .position(
                                    x: mark.xNorm * geo.size.width,
                                    y: max(14, mark.yNorm * geo.size.height - 22)
                                )
                        }
                }

                if let draftPoint {
                    Circle()
                        .strokeBorder(HiveCueTheme.accent, lineWidth: 3)
                        .background(Circle().fill(HiveCueTheme.accent.opacity(0.25)))
                        .frame(width: 44, height: 44)
                        .position(
                            x: draftPoint.x * geo.size.width,
                            y: draftPoint.y * geo.size.height
                        )
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { location in
                let nx = min(max(location.x / geo.size.width, 0), 1)
                let ny = min(max(location.y / geo.size.height, 0), 1)
                onTapNormalized?(CGPoint(x: nx, y: ny))
            }
        }
        .aspectRatio(3 / 4, contentMode: .fit)
        .accessibilityLabel("Heat overlay on brood frame")
    }

    private func heatColor(_ value: Double) -> Color {
        value >= 0.55 ? HiveCueTheme.heatHot : HiveCueTheme.heatCool
    }
}
