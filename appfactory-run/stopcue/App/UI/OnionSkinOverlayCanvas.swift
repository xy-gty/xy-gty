import SwiftUI
import UIKit

/// Semi-transparent previous-frame onion-skin overlay for stop-motion alignment.
struct OnionSkinOverlayCanvas: View {
    struct Mark: Identifiable {
        let id: String
        let xNorm: Double
        let yNorm: Double
        let label: String
    }

    let currentImage: UIImage?
    let previousImage: UIImage?
    let onionEnabled: Bool
    let onionOpacity: Double
    let marks: [Mark]
    var onTap: ((CGPoint) -> Void)?

    var body: some View {
        GeometryReader { geo in
            ZStack {
                StopCueTheme.card
                if let currentImage {
                    Image(uiImage: currentImage)
                        .resizable()
                        .scaledToFit()
                } else {
                    ContentUnavailableView("No current frame", systemImage: "film", description: Text("Capture or import a frame sequence."))
                }
                if onionEnabled, let previousImage {
                    Image(uiImage: previousImage)
                        .resizable()
                        .scaledToFit()
                        .opacity(onionOpacity)
                        .blendMode(.plusLighter)
                        .allowsHitTesting(false)
                        .overlay(
                            Text("Onion skin")
                                .font(.caption2.bold())
                                .padding(6)
                                .background(StopCueTheme.accent.opacity(0.85))
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                                .padding(8),
                            alignment: .topLeading
                        )
                }
                ForEach(marks) { mark in
                    Circle()
                        .fill(StopCueTheme.accent)
                        .frame(width: 14, height: 14)
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                        .position(
                            x: CGFloat(mark.xNorm) * geo.size.width,
                            y: CGFloat(mark.yNorm) * geo.size.height
                        )
                        .accessibilityLabel(mark.label)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { location in
                guard geo.size.width > 0, geo.size.height > 0 else { return }
                onTap?(CGPoint(x: location.x / geo.size.width, y: location.y / geo.size.height))
            }
        }
        .accessibilityIdentifier("onion-skin-overlay-canvas")
    }
}
