import SwiftUI
import WebKit

enum LocalLegalPage: String, CaseIterable, Identifiable {
    case privacy
    case terms
    case support
    case providerPolicy = "provider-policy"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .privacy: return "Privacy"
        case .terms: return "Terms"
        case .support: return "Support"
        case .providerPolicy: return "DeepSeek provider policy"
        }
    }

    var fileName: String { "\(rawValue).html" }
}

struct LocalLegalWebView: View {
    let page: LocalLegalPage

    var body: some View {
        Group {
            if let url = Bundle.main.url(forResource: page.rawValue, withExtension: "html", subdirectory: "Legal")
                ?? Bundle.main.url(forResource: page.rawValue, withExtension: "html") {
                LegalWKView(url: url)
            } else {
                Text("Missing local page \(page.fileName)")
                    .foregroundStyle(ScoutCueTheme.muted)
                    .padding()
            }
        }
        .navigationTitle(page.title)
        .navigationBarTitleDisplayMode(.inline)
        .scoutCueScreen()
    }
}

private struct LegalWKView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let web = WKWebView()
        web.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        return web
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
