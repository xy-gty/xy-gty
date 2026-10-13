import SwiftUI

enum SnagTheme {
    static let background = Color(red: 0.90, green: 0.90, blue: 0.88) // concrete
    static let panel = Color(red: 0.96, green: 0.96, blue: 0.94)
    static let ink = Color(red: 0.12, green: 0.12, blue: 0.12)
    static let steel = Color(red: 0.25, green: 0.40, blue: 0.55)
    static let safety = Color(red: 0.95, green: 0.75, blue: 0.10)
    static let danger = Color(red: 0.75, green: 0.20, blue: 0.15)
}

struct StatusBanner: View {
    let message: String
    var body: some View {
        Text(message)
            .font(.footnote)
            .foregroundStyle(SnagTheme.ink)
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(SnagTheme.safety.opacity(0.35))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

struct PrimaryCTA: View {
    let title: String
    var systemImage: String = "arrow.right.circle.fill"
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
        }
        .buttonStyle(.borderedProminent)
        .tint(SnagTheme.steel)
    }
}
