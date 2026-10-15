import SwiftUI
import WebKit

struct LocalLegalWebView: UIViewRepresentable {
    let fileName: String

    func makeUIView(context: Context) -> WKWebView {
        let web = WKWebView()
        if let url = Bundle.main.url(forResource: fileName, withExtension: "html", subdirectory: "Legal")
            ?? Bundle.main.url(forResource: fileName, withExtension: "html") {
            web.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        } else {
            web.loadHTMLString("<p>Missing local legal page: \(fileName)</p>", baseURL: nil)
        }
        return web
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

struct LegalPageView: View {
    let title: String
    let fileName: String

    var body: some View {
        LocalLegalWebView(fileName: fileName)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
    }
}
