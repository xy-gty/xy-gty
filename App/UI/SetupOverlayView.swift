import SwiftUI

struct SetupOverlayView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Setup / zone overlay")
                    .font(.title2.bold())
                    .foregroundStyle(RuleCueTheme.ink)
                Text("Confirm annotated zone marks for the current table layout.")
                    .foregroundStyle(RuleCueTheme.muted)

                TableZoneCards(
                    zones: appModel.zoneLabels,
                    selectedIndex: min(appModel.selectedZoneIndex, max(appModel.zoneLabels.count - 1, 0)),
                    onSelect: { appModel.selectZone($0) }
                )

                TextField("Mark label", text: $appModel.draftMarkLabel)
                    .padding(12)
                    .background(RuleCueTheme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                TextField("Overlay notes", text: $appModel.overlayDraftNotes, axis: .vertical)
                    .lineLimit(3 ... 6)
                    .padding(12)
                    .background(RuleCueTheme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                if let existing = appModel.sessionOverlays.first {
                    Text("Last kept: \(existing.notes)")
                        .font(.footnote)
                        .foregroundStyle(RuleCueTheme.accent)
                }

                HStack {
                    Button("Keep guide") { appModel.keepSetupOverlay() }
                        .buttonStyle(.borderedProminent)
                        .tint(RuleCueTheme.accent)
                    Button("Discard") { appModel.discardSetupOverlay() }
                        .buttonStyle(.bordered)
                }
            }
            .padding(20)
        }
        .ruleCueScreen()
        .navigationTitle("Setup overlay")
    }
}
