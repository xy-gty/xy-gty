import SwiftUI

@main
struct WorkrestApp: App {
    @StateObject private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            RootNavigationView()
                .environmentObject(appModel)
                .tint(WorkrestTheme.primary)
        }
    }
}
