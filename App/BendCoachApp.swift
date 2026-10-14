import SwiftUI

@main
struct BendCoachApp: App {
    @StateObject private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(appModel)
                .tint(BendCoachTheme.cta)
        }
    }
}
