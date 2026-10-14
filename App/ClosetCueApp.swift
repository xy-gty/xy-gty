import SwiftUI

@main
struct ClosetCueApp: App {
    @StateObject private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(appModel)
                .tint(ClosetCueTheme.cta)
        }
    }
}
