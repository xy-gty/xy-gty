import NightCueDomain
import SwiftUI

struct AnnotatedOverlayView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        VStack(spacing: 16) {
            Text("Confirm diagnosis marks on the night frame")
                .font(.headline)
                .foregroundStyle(NightCueTheme.ink)
                .frame(maxWidth: .infinity, alignment: .leading)

            Picker("Mark type", selection: $appModel.overlayDraftLabel) {
                Text("Underexposed").tag("underexposed")
                Text("Noise").tag("noise")
                Text("Trail").tag("trail")
                Text("Highlight").tag("highlight")
            }
            .pickerStyle(.segmented)

            GeometryReader { geo in
                ZStack {
                    if let frame = appModel.sessionFrames.first,
                       let image = appModel.loadFrameImage(frame) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: geo.size.width, height: geo.size.height)
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(NightCueTheme.primary.opacity(0.1))
                    }
                    ExposureDiagnosisOverlayCanvas(marks: appModel.overlayMarks, showOverlays: true)
                    if let point = appModel.draftOverlayPoint {
                        Circle()
                            .strokeBorder(NightCueTheme.accent, lineWidth: 3)
                            .frame(width: 36, height: 36)
                            .position(
                                x: point.x * geo.size.width,
                                y: point.y * geo.size.height
                            )
                    }
                }
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0).onEnded { value in
                        let x = min(max(value.location.x / geo.size.width, 0), 1)
                        let y = min(max(value.location.y / geo.size.height, 0), 1)
                        appModel.placeDraftOverlay(at: CGPoint(x: x, y: y))
                    }
                )
            }
            .frame(height: 280)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            HStack {
                Button("Discard") { appModel.discardOverlayDraft() }
                    .buttonStyle(.bordered)
                Button("Keep marks") { appModel.keepOverlayMarks() }
                    .buttonStyle(.borderedProminent)
                    .tint(NightCueTheme.primary)
            }

            if let status = appModel.statusMessage {
                Text(status).font(.footnote).foregroundStyle(NightCueTheme.primary)
            }
        }
        .padding(20)
        .nightCueScreen()
        .navigationTitle("Annotate")
    }
}
