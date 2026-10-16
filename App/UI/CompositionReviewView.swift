import MatteboxDomain
import SwiftUI

struct CompositionReviewView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Composition review")
                    .font(.title2.bold())
                    .foregroundStyle(MatteboxTheme.ink)

                TextEditor(text: $appModel.editingIssueSummary)
                    .frame(minHeight: 140)
                    .padding(8)
                    .background(RoundedRectangle(cornerRadius: 10).fill(MatteboxTheme.card))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(MatteboxTheme.primary.opacity(0.25)))

                Group {
                    labelRow("Subject", appModel.pendingSubject)
                    labelRow("Edges", appModel.pendingEdges)
                    labelRow("Negative space", appModel.pendingSpace)
                    labelRow("Symmetry", appModel.pendingSymmetry)
                }

                HStack(spacing: 12) {
                    Button(CompositionReviewBar.reject) { appModel.discardCompositionDraft() }
                        .buttonStyle(.bordered)
                    Button(CompositionReviewBar.edit) {
                        // TextEditor already editable
                    }
                    .buttonStyle(.bordered)
                    Button(CompositionReviewBar.confirm) { appModel.keepCompositionDraft() }
                        .buttonStyle(.borderedProminent)
                        .tint(MatteboxTheme.primary)
                }
            }
            .padding(20)
        }
        .matteboxScreen()
        .navigationTitle("Review")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func labelRow(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.caption.weight(.semibold)).foregroundStyle(MatteboxTheme.accent)
            Text(value).font(.subheadline).foregroundStyle(MatteboxTheme.ink)
        }
    }
}
