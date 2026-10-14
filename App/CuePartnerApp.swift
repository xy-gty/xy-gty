import SwiftUI

@main
struct CuePartnerApp: App {
    @StateObject private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(appModel)
                .tint(CueTheme.amber)
        }
    }
}
