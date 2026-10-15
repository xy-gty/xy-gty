import FrameCueDomain
import SwiftUI

struct OverlayMarksView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ClapperFrameCanvas(title: "Overlays", shotLabel: appModel.selectedChip) {
                    ZStack {
                        if let still = appModel.sessionStills.last,
                           let image = appModel.stillImage(still) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                        } else {
                            Text("Import a still to mark safe-frame / thirds")
                                .foregroundStyle(FrameCueTheme.muted)
                                .padding()
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 200)
                }

                Toggle("Safe frame", isOn: $appModel.safeFrameEnabled)
                    .tint(FrameCueTheme.accent)
                Toggle("Rule of thirds", isOn: $appModel.ruleOfThirdsEnabled)
                    .tint(FrameCueTheme.primary)

                TextField("Notes", text: $appModel.overlayDraftNotes, axis: .vertical)
                    .lineLimit(2...4)
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 10).fill(FrameCueTheme.card))

                HStack {
                    Button(OverlayEditor.reject) { appModel.discardOverlayMarks() }
                        .buttonStyle(.bordered)
                    Spacer()
                    Button(OverlayEditor.confirm) { appModel.keepOverlayMarks() }
                        .buttonStyle(.borderedProminent)
                        .tint(FrameCueTheme.primary)
                }

                if !appModel.sessionOverlays.isEmpty {
                    Text("Confirmed overlays: \(appModel.sessionOverlays.count)")
                        .font(.footnote)
                        .foregroundStyle(FrameCueTheme.muted)
                }
            }
            .padding(16)
        }
        .frameCueScreen()
        .navigationTitle("Overlay marks")
    }
}
