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
        case .privacy: return "Privacy Policy"
        case .terms: return "Terms of Use"
        case .support: return "Support"
        case .providerPolicy: return "DeepSeek Provider Policy"
        }
    }

    var bundleFileName: String { rawValue }

    func bundleURL() -> URL? {
        Bundle.main.url(
            forResource: bundleFileName,
            withExtension: "html",
            subdirectory: "Legal"
        ) ?? Bundle.main.url(forResource: bundleFileName, withExtension: "html")
    }
}

struct LocalLegalWebView: View {
    let page: LocalLegalPage

    var body: some View {
        Group {
            if let url = page.bundleURL() {
                LegalHTMLWebView(fileURL: url)
            } else {
                ContentUnavailableView(
                    "Page missing",
                    systemImage: "doc.text",
                    description: Text("Could not load \(page.title) from the app bundle.")
                )
            }
        }
        .navigationTitle(page.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct LegalHTMLWebView: UIViewRepresentable {
    let fileURL: URL

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView(frame: .zero)
        webView.loadFileURL(fileURL, allowingReadAccessTo: fileURL.deletingLastPathComponent())
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
