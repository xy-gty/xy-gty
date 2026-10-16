import SwiftUI

@main
struct SunbriefApp: App {
    @StateObject private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            RootNavigationView()
                .environmentObject(appModel)
                .tint(SunbriefTheme.indigo)
        }
    }
}
