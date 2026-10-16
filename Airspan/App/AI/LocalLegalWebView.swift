import SwiftUI
import WebKit

/// Bundled legal pages under `App/Resources/Legal/{page}.html`.
struct LocalLegalWebView: View {
    enum Page: String, CaseIterable, Identifiable {
        case privacy
        case terms
        case support
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

        init?(page: String) {
            self.init(rawValue: page)
        }
    }

    let page: Page
    @Environment(\.dismiss) private var dismiss

    init(page: String) {
        if let resolved = Page(page: page) {
            self.page = resolved
        } else {
            self.page = .privacy
        }
    }

    init(page: Page) {
        self.page = page
    }

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
        webView.backgroundColor = UIColor(red: 0.94, green: 0.98, blue: 1.0, alpha: 1)
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        guard context.coordinator.loadedName != resourceName else { return }
        context.coordinator.loadedName = resourceName
        if let url = Bundle.main.url(forResource: resourceName, withExtension: "html", subdirectory: subdirectory) {
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        } else {
            let html = """
            <!DOCTYPE html><html><body style="font-family:-apple-system;padding:24px">
            <h1>Page unavailable</h1>
            <p>Bundled legal page “\(resourceName).html” was not found in the app bundle.</p>
            </body></html>
            """
            webView.loadHTMLString(html, baseURL: nil)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator {
        var loadedName: String?
    }
}
