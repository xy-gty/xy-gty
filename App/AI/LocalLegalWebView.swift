import SwiftUI
import WebKit

struct LocalLegalWebView: UIViewRepresentable {
    enum Source: Equatable {
        case bundleHTML(name: String)
        case inline(String)
    }

    let source: Source

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> WKWebView {
        let view = WKWebView()
        view.isOpaque = false
        view.backgroundColor = .clear
        return view
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        guard context.coordinator.loadedSource != source else { return }
        context.coordinator.loadedSource = source
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

    final class Coordinator {
        var loadedSource: Source?
    }
}
