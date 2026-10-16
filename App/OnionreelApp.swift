import SwiftUI

@main
struct OnionreelApp: App {
    @StateObject private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            RootNavigationView()
                .environmentObject(appModel)
                .tint(OnionreelTheme.primary)
        }
    }
}
