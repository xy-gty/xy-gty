import SwiftUI

@main
struct BightstepApp: App {
    @StateObject private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(appModel)
                .tint(BightstepTheme.accent)
        }
    }
}
