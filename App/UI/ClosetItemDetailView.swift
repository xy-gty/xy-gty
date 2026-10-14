import SwiftUI
import ClosetCueDomain

struct ClosetItemDetailView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            if let item = appModel.selectedItem {
                VStack(alignment: .leading, spacing: 20) {
                    Group {
                        if let image = appModel.image(for: item) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                        } else {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(ClosetCueTheme.surface)
                                .frame(height: 280)
                                .overlay {
                                    Image(systemName: "tshirt")
                                        .font(.largeTitle)
                                        .foregroundStyle(ClosetCueTheme.muted)
                                }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                    ClosetCueTheme.sectionTitle(item.category.isEmpty ? "Closet piece" : item.category)
                    ClosetCueTheme.mutedText("\(item.colorTone) · \(item.seasonHint)")

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(item.tags, id: \.self) { tag in
                                CCTagChip(label: tag)
                            }
                        }
                    }

                    Button("Ask stylist with this piece") {
                        appModel.chatText = "Style me with my \(item.category) (\(item.colorTone))."
                        appModel.selectedTab = .stylist
                        appModel.push(.stylistChat)
                    }
                    .buttonStyle(CCPrimaryButtonStyle())
                }
                .padding(20)
            } else {
                ClosetCueTheme.mutedText("Item not found.")
                    .padding(20)
            }
        }
        .closetCueScene()
        .navigationTitle("Piece")
        .navigationBarTitleDisplayMode(.inline)
    }
}
