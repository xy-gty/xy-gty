import SwiftUI
import SnagCueDomain

/// Human review of AI-proposed punch field patches (contract: FieldReview).
struct FieldReviewView: View {
    @EnvironmentObject private var model: AppModel
    let patch: FieldPatchDraft

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Suggested fields")
                .font(.headline)
            Text(patch.rationale)
                .font(.footnote)
                .foregroundStyle(.secondary)
            fieldRow("Location", patch.location)
            fieldRow("Severity", patch.severity)
            fieldRow("Assignee", patch.assignee)
            fieldRow("Due", patch.dueDate)
            fieldRow("Notes", patch.notes)
            HStack {
                Button(PunchFieldReview.confirm) { model.saveFieldPatch() }
                    .buttonStyle(.borderedProminent)
                    .tint(SnagTheme.steel)
                Button(PunchFieldReview.reject) { model.rejectFieldPatch() }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(SnagTheme.panel)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func fieldRow(_ title: String, _ value: String?) -> some View {
        Text("\(title): \(value?.isEmpty == false ? value! : "—")")
            .font(.subheadline)
    }
}
