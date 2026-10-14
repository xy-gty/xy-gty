import SwiftUI

enum BendCoachTheme {
    static let bg = Color(red: 0x1A/255, green: 0x23/255, blue: 0x32/255)
    static let surface = Color(red: 0x24/255, green: 0x30/255, blue: 0x44/255)
    static let ink = Color(red: 0xF2/255, green: 0xF4/255, blue: 0xF7/255)
    static let muted = Color(red: 0x9A/255, green: 0xA6/255, blue: 0xB2/255)
    static let cta = Color(red: 0xE8/255, green: 0xA3/255, blue: 0x17/255)
    static let diagram = Color(red: 0x5B/255, green: 0x8D/255, blue: 0xEF/255)
    static let ok = Color(red: 0x3D/255, green: 0x9B/255, blue: 0x6E/255)
    static let warn = Color(red: 0xD9/255, green: 0x77/255, blue: 0x06/255)

    static func primaryButton(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .foregroundStyle(Color.black.opacity(0.85))
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(cta)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
