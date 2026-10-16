import SwiftUI
import WebKit

struct LocalLegalWebView: UIViewRepresentable {
    let resourceName: String

    func makeUIView(context: Context) -> WKWebView {
        let web = WKWebView()
        if let url = Bundle.main.url(forResource: resourceName, withExtension: "html", subdirectory: "Legal")
            ?? Bundle.main.url(forResource: resourceName, withExtension: "html") {
            web.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        } else {
            web.loadHTMLString("<p>Missing local legal page: \(resourceName)</p>", baseURL: nil)
        }
        return web
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
