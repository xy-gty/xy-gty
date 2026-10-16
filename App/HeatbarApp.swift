import SwiftUI

@main
struct HeatbarApp: App {
    @StateObject private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            RootNavigationView()
                .environmentObject(appModel)
                .tint(HeatbarTheme.primary)
        }
    }
}
