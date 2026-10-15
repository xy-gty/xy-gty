import SwiftUI
import RuleCueDomain

struct ComponentReviewView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Component & phase draft")
                    .font(.title2.bold())
                    .foregroundStyle(RuleCueTheme.ink)

                if let draft = appModel.pendingDraft {
                    Text("Photo \(draft.tablePhotoId.prefix(8))…")
                        .font(.caption)
                        .foregroundStyle(RuleCueTheme.muted)
                }

                Text("Components")
                    .font(.headline)
                TextField("Component summary", text: $appModel.editingComponentSummary, axis: .vertical)
                    .lineLimit(3 ... 6)
                    .padding(12)
                    .background(RuleCueTheme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                Text("Phases")
                    .font(.headline)
                TextField("Phase summary", text: $appModel.editingPhaseSummary, axis: .vertical)
                    .lineLimit(3 ... 6)
                    .padding(12)
                    .background(RuleCueTheme.card)
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
                        .tint(RuleCueTheme.accent)
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
                        .foregroundStyle(RuleCueTheme.muted)
                }
            }
            .padding(20)
        }
        .ruleCueScreen()
        .navigationTitle("Review")
    }
}
