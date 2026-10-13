import SwiftUI
import WebKit

struct LocalLegalWebView: UIViewRepresentable {
    enum Source {
        case bundleHTML(name: String)
        case inline(String)
    }

    let source: Source

    func makeUIView(context: Context) -> WKWebView {
        let view = WKWebView()
        view.isOpaque = false
        view.backgroundColor = .clear
        return view
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        switch source {
        case .bundleHTML(let name):
            if let url = Bundle.main.url(forResource: name, withExtension: "html", subdirectory: "Legal")
                ?? Bundle.main.url(forResource: name, withExtension: "html") {
                webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
            } else {
                webView.loadHTMLString("<p>Missing \(name).html</p>", baseURL: nil)
            }
        case .inline(let html):
            webView.loadHTMLString(html, baseURL: nil)
        }
    }
}
