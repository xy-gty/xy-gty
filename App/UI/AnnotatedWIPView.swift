import SwiftUI

struct AnnotatedWIPView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Annotated WIP")
                    .font(.title2.bold())
                    .foregroundStyle(YarnCueTheme.ink)

                Text("Tap the photo to place a stitch mark, then Keep marks.")
                    .foregroundStyle(YarnCueTheme.muted)

                if let shot = appModel.projectShots.first,
                   let image = appModel.loadShotImage(shot) {
                    GeometryReader { geo in
                        ZStack {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: geo.size.width)
                            ForEach(appModel.projectOverlays.filter { $0.wipShotId == shot.id }, id: \.id) { mark in
                                Text(mark.label)
                                    .font(.caption2.bold())
                                    .padding(6)
                                    .background(Capsule().fill(YarnCueTheme.lime))
                                    .position(
                                        x: mark.xNorm * geo.size.width,
                                        y: mark.yNorm * max(geo.size.width * image.size.height / max(image.size.width, 1), 1)
                                    )
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture { location in
                            let height = geo.size.width * image.size.height / max(image.size.width, 1)
                            appModel.beginOverlayTap(at: location, in: CGSize(width: geo.size.width, height: height))
                        }
                    }
                    .frame(height: 320)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                } else {
                    Text("Capture a WIP photo first.")
                        .foregroundStyle(YarnCueTheme.muted)
                }

                TextField("Mark label", text: $appModel.overlayDraftLabel)
                    .textFieldStyle(.roundedBorder)

                HStack {
                    Button("Keep marks") { appModel.keepOverlayMark() }
                        .buttonStyle(.borderedProminent)
                        .tint(YarnCueTheme.lime)
                    Button("Discard") { appModel.discardOverlayDraft() }
                        .buttonStyle(.bordered)
                }
            }
            .padding(20)
        }
        .yarnCueScreen()
        .navigationTitle("Annotate")
    }
}
