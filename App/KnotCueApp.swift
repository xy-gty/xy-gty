import SwiftUI

@main
struct KnotCueApp: App {
    @StateObject private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(appModel)
                .tint(KnotCueTheme.accent)
        }
    }
}
