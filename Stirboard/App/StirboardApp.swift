import SwiftUI

@main
struct StirboardApp: App {
    @StateObject private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            RootNavigationView()
                .environmentObject(appModel)
                .tint(StirboardTheme.primary)
        }
    }
}
