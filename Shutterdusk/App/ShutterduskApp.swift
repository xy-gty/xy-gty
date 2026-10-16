import SwiftUI

@main
struct ShutterduskApp: App {
    @StateObject private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            RootNavigationView()
                .environmentObject(appModel)
                .tint(ShutterduskTheme.primary)
        }
    }
}
