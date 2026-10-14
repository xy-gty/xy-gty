import SwiftUI

@main
struct DuctCueApp: App {
    @StateObject private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(appModel)
                .tint(DuctCueTheme.accent)
        }
    }
}
