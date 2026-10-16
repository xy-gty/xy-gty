import SwiftUI

@main
struct RacknoteApp: App {
    @StateObject private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            RootNavigationView()
                .environmentObject(appModel)
                .tint(RacknoteTheme.accent)
        }
    }
}
