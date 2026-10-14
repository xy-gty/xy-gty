import SwiftUI
import UIKit
import DuctCueDomain

struct DuctRunReviewView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let draft = model.editingDraft {
                    draftPreview(draft)
                    tagsSection
                    reviewButtons
                } else {
                    ContentUnavailableView(
                        "No draft",
                        systemImage: "photo.badge.exclamationmark",
                        description: Text("Import a photo to review proposed sizes.")
                    )
                }
            }
            .padding()
        }
        .background(DuctCueTheme.secondary.ignoresSafeArea())
        .navigationTitle("Review run")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func draftPreview(_ draft: DuctRunDraft) -> some View {
        let url = model.storage.photoFileURL(for: draft)
        if let ui = UIImage(contentsOfFile: url.path) {
            Image(uiImage: ui)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 220)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        } else {
            IsometricDuctCanvas(accentChip: draft.proposedSizeTags.first)
        }
        Text("Proposed: \(draft.proposedSizeTags.joined(separator: ", "))")
            .font(.footnote)
            .foregroundStyle(.secondary)
    }

    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Size tags")
                .font(.headline)
                .foregroundStyle(DuctCueTheme.ink)
            TextField("e.g. 10×8, 8\" round", text: $model.sizeEditBuffer, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(2...4)
        }
    }

    private var reviewButtons: some View {
        VStack(spacing: 10) {
            Button(DuctCueReviewControls.confirm) {
                model.useDraft()
            }
            .buttonStyle(DuctCueTheme.PrimaryButtonStyle())

            Button(DuctCueReviewControls.reject) {
                model.rejectDraft()
            }
            .buttonStyle(DuctCueTheme.SecondaryButtonStyle())

            Button(DuctCueReviewControls.edit) {
                model.beginEditSizes()
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(DuctCueTheme.accent)
        }
    }
}
