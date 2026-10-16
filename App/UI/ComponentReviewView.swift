import SwiftUI
import TablehostDomain

struct ComponentReviewView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Component & phase draft")
                    .font(.title2.bold())
                    .foregroundStyle(TablehostTheme.ink)

                if let draft = appModel.pendingDraft {
                    Text("Photo \(draft.tablePhotoId.prefix(8))…")
                        .font(.caption)
                        .foregroundStyle(TablehostTheme.muted)
                }

                Text("Components")
                    .font(.headline)
                TextField("Component summary", text: $appModel.editingComponentSummary, axis: .vertical)
                    .lineLimit(3 ... 6)
                    .padding(12)
                    .background(TablehostTheme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                Text("Phases")
                    .font(.headline)
                TextField("Phase summary", text: $appModel.editingPhaseSummary, axis: .vertical)
                    .lineLimit(3 ... 6)
                    .padding(12)
                    .background(TablehostTheme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                if !appModel.pendingZoneLabels.isEmpty {
                    Text("Proposed zones")
                        .font(.headline)
                    TableZoneCards(
                        zones: appModel.pendingZoneLabels,
                        selectedIndex: min(appModel.selectedZoneIndex, appModel.pendingZoneLabels.count - 1),
                        onSelect: { appModel.selectedZoneIndex = $0 }
                    )
                }

                HStack(spacing: 10) {
                    Button(ComponentReviewBar.confirm) { appModel.keepComponentDraft() }
                        .buttonStyle(.borderedProminent)
                        .tint(TablehostTheme.accent)
                    Button(ComponentReviewBar.reject) { appModel.discardComponentDraft() }
                        .buttonStyle(.bordered)
                    Button(ComponentReviewBar.edit) {
                        appModel.statusMessage = "Edit the fields above, then Keep."
                    }
                    .buttonStyle(.bordered)
                }

                if let reason = appModel.aiUnavailableReason {
                    Text(reason)
                        .font(.footnote)
                        .foregroundStyle(TablehostTheme.muted)
                }
            }
            .padding(20)
        }
        .tablehostScreen()
        .navigationTitle("Review")
    }
}
