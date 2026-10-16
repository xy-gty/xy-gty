import SwiftUI

@main
struct BrewCueApp: App {
    @StateObject private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            RootNavigationView()
                .environmentObject(appModel)
                .tint(BrewCueTheme.primary)
        }
    }
}
