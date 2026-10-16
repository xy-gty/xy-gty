import SwiftUI

@main
struct AirspanApp: App {
    @StateObject private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(appModel)
                .tint(AirspanTheme.accent)
        }
    }
}
