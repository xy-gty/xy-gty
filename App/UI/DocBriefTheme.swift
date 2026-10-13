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

struct DocBriefAIStatusBanner: View {
    @EnvironmentObject private var model: AppModel
    var retry: (() -> Void)?

    var body: some View {
        if let reason = model.aiUnavailableReason {
            VStack(alignment: .leading, spacing: 8) {
                Text(reason)
                    .font(.footnote)
                    .foregroundStyle(DocBriefTheme.ink.opacity(0.85))
                if let retry {
                    Button("Retry", action: retry)
                        .font(.footnote.weight(.semibold))
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(DocBriefTheme.mist)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
    }
}

struct DocBriefErrorRetryBanner: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        if message.localizedCaseInsensitiveContains("failed") {
            VStack(alignment: .leading, spacing: 8) {
                Text(message)
                    .font(.footnote)
                Button("Retry", action: retry)
                    .font(.footnote.weight(.semibold))
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(DocBriefTheme.amber.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
    }
}
