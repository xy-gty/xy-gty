import SwiftUI

@main
struct ScoutCueApp: App {
    @StateObject private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            RootNavigationView()
                .environmentObject(appModel)
                .tint(ScoutCueTheme.indigo)
        }
    }
}
