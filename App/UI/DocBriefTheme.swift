import SwiftUI

enum DocBriefTheme {
    static let paper = Color(red: 243 / 255, green: 237 / 255, blue: 227 / 255)
    static let ink = Color(red: 28 / 255, green: 36 / 255, blue: 48 / 255)
    static let teal = Color(red: 31 / 255, green: 111 / 255, blue: 107 / 255)
    static let amber = Color(red: 217 / 255, green: 119 / 255, blue: 6 / 255)
    static let mist = Color(red: 232 / 255, green: 226 / 255, blue: 216 / 255)

    static var panel: some View {
        mist.opacity(0.9)
    }
}
