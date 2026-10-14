import SwiftUI
import PhotosUI
import ClosetCueDomain

struct ClosetShelfView: View {
    @EnvironmentObject private var appModel: AppModel

    private let gridColumns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    var body: some View {
        Group {
            if appModel.closetItems.isEmpty {
                emptyShelf
            } else {
                filledShelf
            }
        }
        .closetCueScene()
        .navigationTitle(ClosetCueIdentity.appName)
        .navigationBarTitleDisplayMode(.large)
        .onChange(of: appModel.selectedPhotoItem) { _, item in
            guard let item else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    appModel.importPhotoData(data, sourceKind: ClosetCuePhotoImportFacade.librarySourceKind)
                }
                appModel.selectedPhotoItem = nil
            }
        }
    }

    private var emptyShelf: some View {
        VStack(spacing: 28) {
            Spacer()
            ClosetCueTheme.heroTitle(ClosetCueIdentity.appName)
            ClosetCueTheme.mutedText("Your calm closet shelf — add a piece to start.")
            addPieceControls
            Button("Try demo piece") {
                appModel.importDemoPiece()
            }
            .buttonStyle(CCSecondaryButtonStyle())
            .padding(.horizontal, 24)
            Spacer()
        }
    }

    private var filledShelf: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                toolRow
                LazyVGrid(columns: gridColumns, spacing: 10) {
                    ForEach(appModel.closetItems) { item in
                        Button {
                            appModel.selectedItemID = item.id
                            appModel.push(.closetItemDetail)
                        } label: {
                            shelfCell(for: item)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(16)
        }
    }

    private var toolRow: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                Button("Ask stylist") {
                    appModel.selectedTab = .stylist
                    appModel.push(.stylistChat)
                }
                .buttonStyle(CCPrimaryButtonStyle())

                Button("Morning briefing") {
                    appModel.prepareMorningBriefing()
                }
                .buttonStyle(CCSecondaryButtonStyle())
            }
            addPieceControls
        }
    }

    private var addPieceControls: some View {
        VStack(spacing: 10) {
            PhotosPicker(selection: $appModel.selectedPhotoItem, matching: .images) {
                Text("Add a piece")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(ClosetCueTheme.bg)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(ClosetCueTheme.cta)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .padding(.horizontal, 24)

            HStack(spacing: 10) {
                Button("Camera") {
                    if appModel.cameraHardwareAvailable {
                        appModel.showCameraPicker = true
                    } else {
                        appModel.push(.captureImport)
                    }
                }
                .buttonStyle(CCSecondaryButtonStyle())

                Button("Demo piece") {
                    appModel.importDemoPiece()
                }
                .buttonStyle(CCSecondaryButtonStyle())
            }
            .padding(.horizontal, 24)
        }
    }

    @ViewBuilder
    private func shelfCell(for item: ClosetItem) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Group {
                if let image = appModel.image(for: item) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    ClosetCueTheme.surface
                    Image(systemName: "tshirt")
                        .font(.title2)
                        .foregroundStyle(ClosetCueTheme.muted)
                }
            }
            .frame(height: 110)
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            Text(item.category.isEmpty ? "Piece" : item.category)
                .font(.caption.weight(.semibold))
                .foregroundStyle(ClosetCueTheme.ink)
                .lineLimit(1)
        }
        .padding(8)
        .background(ClosetCueTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
