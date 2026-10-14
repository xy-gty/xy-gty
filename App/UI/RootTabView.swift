import SwiftUI
import ClosetCueDomain

struct RootTabView: View {
    @EnvironmentObject private var appModel: AppModel

    private var pathBinding: Binding<[ClosetCueRoute]> {
        Binding(
            get: { appModel.path },
            set: { newValue in
                appModel.path = newValue
                appModel.persistPath()
            }
        )
    }

    var body: some View {
        TabView(selection: $appModel.selectedTab) {
            closetTab
                .tabItem { Label("Closet", systemImage: "hanger") }
                .tag(AppModel.AppTab.closet)

            stylistTab
                .tabItem { Label("Stylist", systemImage: "sparkles") }
                .tag(AppModel.AppTab.stylist)

            looksTab
                .tabItem { Label("Looks", systemImage: "square.grid.2x2") }
                .tag(AppModel.AppTab.looks)

            settingsTab
                .tabItem { Label("Settings", systemImage: "gearshape") }
                .tag(AppModel.AppTab.settings)
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $appModel.showConsent) {
            ConsentSheet()
                .environmentObject(appModel)
        }
        .fullScreenCover(isPresented: $appModel.showCameraPicker) {
            CameraCapturePicker(
                onImageData: { data in
                    appModel.showCameraPicker = false
                    appModel.importPhotoData(data, sourceKind: ClosetCuePhotoImportFacade.cameraSourceKind)
                },
                onCancel: { appModel.showCameraPicker = false }
            )
            .ignoresSafeArea()
        }
        .overlay(alignment: .bottom) {
            if let status = appModel.statusMessage, !status.isEmpty {
                CCStatusBanner(message: status)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            } else if appModel.recognitionBusy || appModel.chatBusy {
                CCStatusBanner(
                    message: appModel.recognitionBusy ? "Reading your piece…" : "Planning a look…"
                )
            }
        }
        .animation(.easeInOut(duration: 0.2), value: appModel.statusMessage)
        .animation(.easeInOut(duration: 0.2), value: appModel.recognitionBusy)
        .animation(.easeInOut(duration: 0.2), value: appModel.chatBusy)
    }

    private var closetTab: some View {
        NavigationStack(path: pathBinding) {
            ClosetShelfView()
                .navigationDestination(for: ClosetCueRoute.self, destination: routeDestination)
        }
    }

    private var stylistTab: some View {
        NavigationStack(path: pathBinding) {
            StylistChatView()
                .navigationDestination(for: ClosetCueRoute.self, destination: routeDestination)
        }
    }

    private var looksTab: some View {
        NavigationStack(path: pathBinding) {
            SavedLooksView()
                .navigationDestination(for: ClosetCueRoute.self, destination: routeDestination)
        }
    }

    private var settingsTab: some View {
        NavigationStack(path: pathBinding) {
            SettingsPrivacyView()
                .navigationDestination(for: ClosetCueRoute.self, destination: routeDestination)
        }
    }

    @ViewBuilder
    private func routeDestination(_ route: ClosetCueRoute) -> some View {
        switch route {
        case .captureImport:
            CaptureImportView()
        case .garmentReview:
            GarmentReviewView()
        case .closetItemDetail:
            ClosetItemDetailView()
        case .stylistChat:
            StylistChatView()
        case .flatLayBoard:
            FlatLayBoardView()
        case .morningBriefing:
            MorningBriefingView()
        case .speechCapture:
            SpeechCaptureView()
        case .legalPages:
            LegalPagesView(initial: .privacy)
        case .homeTab, .closetShelf, .settings, .consentSheet:
            EmptyView()
        }
    }
}

// MARK: - Looks tab

private struct SavedLooksView: View {
    @EnvironmentObject private var appModel: AppModel

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        Group {
            if appModel.savedLooks.isEmpty {
                VStack(spacing: 16) {
                    ClosetCueTheme.heroTitle("Looks")
                    ClosetCueTheme.mutedText("Saved flat-lays appear here after you Save look from the stylist.")
                    Button("Ask stylist") {
                        appModel.selectedTab = .stylist
                        appModel.push(.stylistChat)
                    }
                    .buttonStyle(CCPrimaryButtonStyle())
                    .padding(.horizontal, 24)
                }
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(appModel.savedLooks) { board in
                            if let image = appModel.image(for: board) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 180)
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            }
                        }
                    }
                    .padding(16)
                }
            }
        }
        .closetCueScene()
        .navigationTitle("Looks")
        .navigationBarTitleDisplayMode(.large)
    }
}
