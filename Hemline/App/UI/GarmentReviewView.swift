import SwiftUI
import HemlineDomain

struct GarmentReviewView: View {
    @EnvironmentObject private var appModel: AppModel
    @State private var isEditingTags = false
    @FocusState private var tagsFocused: Bool

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let draft = appModel.editingDraft {
                    draftImage(draft)
                    tagSection(draft)
                    actionBar
                } else {
                    HemlineTheme.mutedText("No draft to review.")
                    Button("Back to closet") {
                        appModel.popToRoot()
                    }
                    .buttonStyle(CCSecondaryButtonStyle())
                }
            }
            .padding(20)
        }
        .hemlineScene()
        .navigationTitle("Review")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if appModel.tagEditBuffer.isEmpty, let draft = appModel.editingDraft {
                appModel.tagEditBuffer = draft.proposedTags.joined(separator: ", ")
            }
        }
    }

    @ViewBuilder
    private func draftImage(_ draft: GarmentDraft) -> some View {
        Group {
            if let image = appModel.image(for: draft) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(HemlineTheme.surface)
                    .overlay {
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundStyle(HemlineTheme.muted)
                    }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(maxHeight: 360)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    @ViewBuilder
    private func tagSection(_ draft: GarmentDraft) -> some View {
        HemlineTheme.sectionTitle("Suggested tags")
        if isEditingTags {
            TextField("Tags (comma separated)", text: $appModel.tagEditBuffer, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .focused($tagsFocused)
                .foregroundStyle(HemlineTheme.ink)
        } else {
            FlowTagRow(tags: displayTags(for: draft))
        }
        HemlineTheme.mutedText("\(draft.proposedCategory) · \(draft.proposedColorTone) · \(draft.proposedSeasonHint)")
    }

    private func displayTags(for draft: GarmentDraft) -> [String] {
        let edited = appModel.tagEditBuffer
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        return edited.isEmpty ? draft.proposedTags : edited
    }

    private var actionBar: some View {
        VStack(spacing: 10) {
            Button(HemlineReviewControls.confirm) {
                appModel.keepDraft()
            }
            .buttonStyle(CCPrimaryButtonStyle())
            .disabled(appModel.editingDraft == nil)

            Button(HemlineReviewControls.reject) {
                appModel.rejectDraft()
                isEditingTags = false
            }
            .buttonStyle(CCSecondaryButtonStyle())

            Button(HemlineReviewControls.edit) {
                appModel.beginEditTags()
                isEditingTags = true
                tagsFocused = true
            }
            .buttonStyle(CCSecondaryButtonStyle())
        }
        .padding(.top, 8)
    }
}

private struct FlowTagRow: View {
    let tags: [String]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(tags, id: \.self) { tag in
                    CCTagChip(label: tag)
                }
            }
        }
    }
}
