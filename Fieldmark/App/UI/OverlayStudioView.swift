import SwiftUI
import FieldmarkDomain

struct OverlayStudioView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                if let image = appModel.photoImage(for: appModel.activeSession) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                } else {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(FieldmarkTheme.primary.opacity(0.1))
                        .overlay(Text("No photo").foregroundStyle(FieldmarkTheme.muted))
                }

                GeometryReader { geo in
                    ForEach(Array(appModel.overlayCallouts.enumerated()), id: \.offset) { _, callout in
                        Text(callout.label)
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .padding(6)
                            .background(FieldmarkTheme.accent.opacity(0.9))
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            .position(
                                x: callout.x * geo.size.width,
                                y: callout.y * geo.size.height
                            )
                            .gesture(
                                DragGesture().onChanged { value in
                                    if let idx = appModel.overlayCallouts.firstIndex(where: { $0.markId == callout.markId }) {
                                        appModel.overlayCallouts[idx].x = min(max(value.location.x / geo.size.width, 0.05), 0.95)
                                        appModel.overlayCallouts[idx].y = min(max(value.location.y / geo.size.height, 0.05), 0.95)
                                    }
                                }
                            )
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(FieldmarkTheme.primary, lineWidth: 2)
            )
            .padding(.horizontal)

            OversizedFieldMarkChips(marks: appModel.sessionMarks)
                .padding(.horizontal)

            Button("Save overlay") {
                appModel.saveOverlay()
            }
            .buttonStyle(.borderedProminent)
            .tint(FieldmarkTheme.accent)

            Button("Speak tip") {
                appModel.speakTip()
            }
            .foregroundStyle(FieldmarkTheme.primary)

            Spacer()
        }
        .padding(.top, 12)
        .fieldmarkScreen()
        .navigationTitle("Overlay studio")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("OverlayStudioView")
    }
}
