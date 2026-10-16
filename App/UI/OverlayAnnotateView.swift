import SwiftUI
import UIKit
import GillnoteDomain

struct OverlayAnnotateView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        VStack(spacing: 12) {
            DisclaimerBanner()
                .padding(.horizontal, 16)

            ZStack {
                if let path = appModel.activeSession?.photoLocalURL,
                   let image = UIImage(contentsOfFile: path) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                } else {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(GillnoteTheme.barFace)
                        .frame(height: 280)
                }

                GeometryReader { geo in
                    ForEach(Array(appModel.draftCallouts.enumerated()), id: \.offset) { _, callout in
                        let rect = callout.normalizedRect
                        let x = (rect.count > 0 ? rect[0] : 0.1) * geo.size.width
                        let y = (rect.count > 1 ? rect[1] : 0.2) * geo.size.height
                        Text(callout.label)
                            .font(.caption.weight(.bold))
                            .padding(6)
                            .background(Capsule().fill(GillnoteTheme.accent.opacity(0.9)))
                            .foregroundStyle(.white)
                            .position(x: x + 40, y: y + 20)
                    }
                }
            }
            .padding(.horizontal, 16)

            List {
                ForEach(Array(appModel.draftCallouts.enumerated()), id: \.offset) { idx, callout in
                    VStack(alignment: .leading, spacing: 4) {
                        TextField(
                            "Label",
                            text: Binding(
                                get: { appModel.draftCallouts[idx].label },
                                set: { appModel.draftCallouts[idx].label = $0 }
                            )
                        )
                        Text(callout.region.uppercased())
                            .font(.caption2)
                            .foregroundStyle(GillnoteTheme.muted)
                    }
                }
            }
            .scrollContentBackground(.hidden)

            HStack(spacing: 12) {
                Button("Dismiss") { appModel.rejectOverlayDraft() }
                    .buttonStyle(.bordered)
                Button("Keep") { appModel.keepOverlay() }
                    .buttonStyle(.borderedProminent)
                    .tint(GillnoteTheme.accent)
                Button("Edit callouts") {}
                    .foregroundStyle(GillnoteTheme.primary)
            }
            .padding(.bottom, 16)
        }
        .sporeScreen()
        .navigationTitle("Annotate")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("OverlayAnnotate")
    }
}
