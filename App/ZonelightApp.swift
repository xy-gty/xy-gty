import SwiftUI

@main
struct ZonelightApp: App {
    @StateObject private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            RootNavigationView()
                .environmentObject(appModel)
                .tint(ZonelightTheme.accent)
        }
    }
}
