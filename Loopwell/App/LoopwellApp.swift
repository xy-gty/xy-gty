import SwiftUI

@main
struct LoopwellApp: App {
    @StateObject private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            RootNavigationView()
                .environmentObject(appModel)
                .tint(LoopwellTheme.fuchsia)
        }
    }
}
