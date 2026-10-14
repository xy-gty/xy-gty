import SwiftUI
import WebKit

struct LocalLegalWebView: View {
    enum Page: String, CaseIterable, Identifiable {
        case privacy, terms, support
        case deepseekPrivacy = "deepseek-privacy"
        var id: String { rawValue }
        var title: String {
            switch self {
            case .privacy: return "Privacy Policy"
            case .terms: return "Terms of Use"
            case .support: return "Support"
            case .deepseekPrivacy: return "DeepSeek Privacy"
            }
        }
        var resourceName: String { rawValue }
        init?(page: String) { self.init(rawValue: page) }
    }

    let page: Page
    @Environment(\.dismiss) private var dismiss

    init(page: String) { self.page = Page(page: page) ?? .privacy }
    init(page: Page) { self.page = page }

    var body: some View {
        NavigationStack {
            LegalWebViewRepresentable(resourceName: page.resourceName, subdirectory: "Legal")
                .ignoresSafeArea(edges: .bottom)
                .navigationTitle(page.title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") { dismiss() }
                    }
                }
        }
    }
}

private struct LegalWebViewRepresentable: UIViewRepresentable {
    let resourceName: String
    let subdirectory: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView(frame: .zero)
        webView.isOpaque = false
        webView.backgroundColor = UIColor(red: 1, green: 0.984, blue: 0.922, alpha: 1)
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        guard context.coordinator.loadedName != resourceName else { return }
        context.coordinator.loadedName = resourceName
        if let url = Bundle.main.url(forResource: resourceName, withExtension: "html", subdirectory: subdirectory) {
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        } else {
            webView.loadHTMLString("<html><body><h1>Page unavailable</h1></body></html>", baseURL: nil)
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator() }
    final class Coordinator { var loadedName: String? }
}
