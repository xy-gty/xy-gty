import SwiftUI

struct AnnotatedFormView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Annotated form")
                    .font(.title2.bold())
                    .foregroundStyle(WorkrestTheme.ink)

                PolaroidFormStrip(
                    titles: appModel.polaroidTitles,
                    selectedIndex: appModel.selectedPolaroidIndex
                ) { idx in
                    appModel.selectedPolaroidIndex = idx
                }

                if let shot = appModel.sessionShots.first,
                   let image = appModel.loadShotImage(shot) {
                    GeometryReader { geo in
                        ZStack {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity)
                            ForEach(appModel.sessionOverlays.filter { $0.formShotId == shot.id }, id: \.id) { mark in
                                Circle()
                                    .fill(WorkrestTheme.accent)
                                    .frame(width: 14, height: 14)
                                    .position(
                                        x: mark.xNorm * geo.size.width,
                                        y: mark.yNorm * min(geo.size.width * image.size.height / max(image.size.width, 1), geo.size.height)
                                    )
                                    .overlay(
                                        Text(mark.label)
                                            .font(.caption2.bold())
                                            .foregroundStyle(WorkrestTheme.ink)
                                            .offset(y: 16)
                                    )
                            }
                        }
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onEnded { value in
                                    appModel.beginOverlayTap(at: value.location, in: geo.size)
                                }
                        )
                    }
                    .frame(height: 320)
                    .background(WorkrestTheme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    ContentUnavailableView(
                        "No form photo",
                        systemImage: "camera.viewfinder",
                        description: Text("Capture a mid-set pose first.")
                    )
                    Button("Capture form") { appModel.push(.captureImport) }
                        .buttonStyle(.borderedProminent)
                        .tint(WorkrestTheme.primary)
                }

                TextField("Mark label", text: $appModel.overlayDraftLabel)
                    .textFieldStyle(.roundedBorder)

                HStack {
                    Button("Keep marks") { appModel.keepOverlayMark() }
                        .buttonStyle(.borderedProminent)
                        .tint(WorkrestTheme.primary)
                        .accessibilityIdentifier("cta-keep-marks")
                    Button("Discard") { appModel.discardOverlayDraft() }
                        .buttonStyle(.bordered)
                }

                if let status = appModel.statusMessage {
                    Text(status).font(.footnote).foregroundStyle(WorkrestTheme.ink)
                }
            }
            .padding(20)
        }
        .workrestScreen()
        .navigationTitle("Polaroid marks")
    }
}
