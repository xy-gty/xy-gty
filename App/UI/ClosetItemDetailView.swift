import SwiftUI
import HemlineDomain

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
                                .fill(HemlineTheme.surface)
                                .frame(height: 280)
                                .overlay {
                                    Image(systemName: "tshirt")
                                        .font(.largeTitle)
                                        .foregroundStyle(HemlineTheme.muted)
                                }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                    HemlineTheme.sectionTitle(item.category.isEmpty ? "Closet piece" : item.category)
                    HemlineTheme.mutedText("\(item.colorTone) · \(item.seasonHint)")

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
                HemlineTheme.mutedText("Item not found.")
                    .padding(20)
            }
        }
        .hemlineScene()
        .navigationTitle("Piece")
        .navigationBarTitleDisplayMode(.inline)
    }
}
