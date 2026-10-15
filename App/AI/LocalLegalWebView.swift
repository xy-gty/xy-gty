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
            web.loadHTMLString("<p>Local \(resourceName) page missing.</p>", baseURL: nil)
        }
        return web
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

struct LegalPagesView: View {
    var body: some View {
        List {
            NavigationLink("Privacy") {
                LocalLegalWebView(resourceName: "privacy")
                    .navigationTitle("Privacy")
            }
            NavigationLink("Terms") {
                LocalLegalWebView(resourceName: "terms")
                    .navigationTitle("Terms")
            }
            NavigationLink("Support") {
                LocalLegalWebView(resourceName: "support")
                    .navigationTitle("Support")
            }
            NavigationLink("Provider policy") {
                LocalLegalWebView(resourceName: "provider-policy")
                    .navigationTitle("Provider policy")
            }
        }
        .navigationTitle("Legal")
    }
}
