import SwiftUI

@main
struct HemlineApp: App {
    @StateObject private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(appModel)
                .tint(HemlineTheme.cta)
        }
    }
}
