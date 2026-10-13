import SwiftUI
import WebKit

/// Loads bundled Legal/*.html or inline HTML inside the app (local_only delivery).
struct LocalLegalWebView: UIViewRepresentable {
    enum Source: Equatable {
        case bundleHTML(name: String, subdirectory: String = "Legal")
        case inline(String)
    }

    var source: Source

    func makeUIView(context: Context) -> WKWebView {
        let view = WKWebView(frame: .zero)
        view.isOpaque = false
        view.backgroundColor = .clear
        view.scrollView.backgroundColor = .clear
        return view
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        switch source {
        case .bundleHTML(let name, let subdirectory):
            if let url = Bundle.main.url(forResource: name, withExtension: "html", subdirectory: subdirectory) {
                webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
            } else {
                webView.loadHTMLString(fallbackBody(title: name.capitalized), baseURL: nil)
            }
        case .inline(let html):
            webView.loadHTMLString(html, baseURL: nil)
        }
    }

    private func fallbackBody(title: String) -> String {
        """
        <!DOCTYPE html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
        <title>\(title)</title></head><body>
        <h1>\(title)</h1>
        <p>SnagCue AI — local legal page. External URL not configured in this local_only delivery.</p>
        <p>Guidance only — not a building-code or legal certification.</p>
        </body></html>
        """
    }
}
