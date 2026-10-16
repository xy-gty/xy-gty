import SwiftUI
import UIKit
import WebKit
import AirspanDomain

struct RootTabView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        NavigationStack(path: $model.path) {
            TabView(selection: $model.selectedTab) {
                JobsCanvasView()
                    .tabItem { Label("Jobs", systemImage: "wind") }
                    .tag(AppModel.AppTab.jobs)

                CoachChatView()
                    .tabItem { Label("Coach", systemImage: "bubble.left.and.bubble.right") }
                    .tag(AppModel.AppTab.coach)

                DiagramsTabView()
                    .tabItem { Label("Diagrams", systemImage: "square.3.layers.3d") }
                    .tag(AppModel.AppTab.diagrams)

                SettingsTabView()
                    .tabItem { Label("Settings", systemImage: "gearshape") }
                    .tag(AppModel.AppTab.settings)
            }
            .navigationDestination(for: AirspanRoute.self) { route in
                switch route {
                case .jobCapture:
                    JobCaptureView()
                case .ductRunReview:
                    DuctRunReviewView()
                case .ductRunDetail:
                    DuctRunDetailView()
                case .sizeDiagram:
                    SizeDiagramView()
                case .fieldSteps:
                    FieldStepsView()
                case .speechCapture:
                    SpeechCaptureView()
                case .legalPages:
                    LegalPagesHubView()
                default:
                    EmptyView()
                }
            }
        }
        .background(AirspanTheme.secondary.ignoresSafeArea())
        .sheet(isPresented: $model.showConsent) {
            ConsentSheetView()
                .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $model.showCameraPicker) {
            CameraCapturePicker(
                onImageData: { model.handleCameraImageData($0) },
                onCancel: { model.cancelCameraPicker() }
            )
            .ignoresSafeArea()
        }
        .overlay(alignment: .top) {
            if let message = model.statusMessage {
                Text(message)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .padding(.top, 8)
                    .onTapGesture { model.statusMessage = nil }
            }
        }
    }
}

private struct ConsentSheetView: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Allow DeepSeek coaching")
                        .font(.title2.bold())
                        .foregroundStyle(AirspanTheme.ink)
                    Text("If you continue, Airspan may send chat text, airflow numbers, duct photo bytes, duct run tags, job summary, and sizing context to \(AirspanIdentity.aiProvider) for inference.")
                        .foregroundStyle(AirspanTheme.ink.opacity(0.85))
                    Text("Disclosure: \(AirspanIdentity.consentDisclosureVersion)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(AirspanIdentity.sizingFormulaDisclaimer)
                        .font(.footnote)
                        .foregroundStyle(AirspanTheme.primary)
                }
                .padding()
            }
            .background(AirspanTheme.secondary)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Not now") { model.declineConsentFromSheet(); dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Allow") { model.grantConsentFromSheet(); dismiss() }
                        .fontWeight(.semibold)
                }
            }
        }
    }
}

private struct DiagramsTabView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        NavigationStack {
            Group {
                if model.savedDiagrams.isEmpty {
                    ContentUnavailableView(
                        "No saved diagrams",
                        systemImage: "square.3.layers.3d.slash",
                        description: Text("Make a size diagram from Coach after sizing.")
                    )
                } else {
                    List(model.savedDiagrams) { diagram in
                        DiagramRowView(diagram: diagram)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Diagrams")
            .background(AirspanTheme.secondary.ignoresSafeArea())
        }
    }
}

private struct DiagramRowView: View {
    @EnvironmentObject private var model: AppModel
    let diagram: SizeDiagram

    var body: some View {
        HStack(spacing: 12) {
            diagramThumbnail
                .frame(width: 72, height: 54)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            VStack(alignment: .leading, spacing: 4) {
                Text("Size diagram")
                    .font(.headline)
                    .foregroundStyle(AirspanTheme.ink)
                if let saved = diagram.savedAt {
                    Text(saved.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            Button("Field steps") { model.openFieldSteps(for: diagram) }
                .font(.caption.weight(.semibold))
        }
    }

    @ViewBuilder
    private var diagramThumbnail: some View {
        let url = model.storage.diagramFileURL(for: diagram)
        if let ui = UIImage(contentsOfFile: url.path) {
            Image(uiImage: ui).resizable().scaledToFill()
        } else {
            IsometricDuctCanvas(accentChip: model.sizeChips.first)
        }
    }
}

private struct SettingsTabView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        NavigationStack {
            List {
                Section("AI sharing") {
                    HStack {
                        Text("Consent")
                        Spacer()
                        Text(model.consentGranted ? "Allowed" : "Off")
                            .foregroundStyle(.secondary)
                    }
                    if let reason = model.aiUnavailableReason {
                        Text(reason)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    Button("Revoke AI sharing", role: .destructive) {
                        model.revokeConsent()
                    }
                }
                Section("Legal") {
                    NavigationLink(value: AirspanRoute.legalPages) {
                        Text("Privacy, terms & support")
                    }
                }
                Section("About") {
                    LabeledContent("App", value: AirspanIdentity.appName)
                    Text(AirspanIdentity.sizingFormulaDisclaimer)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Settings")
            .navigationDestination(for: AirspanRoute.self) { route in
                if route == .legalPages {
                    LegalPagesHubView()
                } else {
                    EmptyView()
                }
            }
        }
    }
}

private struct LegalPagesHubView: View {
    var body: some View {
        List {
            NavigationLink("Privacy") { LegalWebView(htmlName: "privacy") }
            NavigationLink("Terms") { LegalWebView(htmlName: "terms") }
            NavigationLink("Support") { LegalWebView(htmlName: "support") }
            NavigationLink("DeepSeek privacy") { LegalWebView(htmlName: "deepseek-privacy") }
        }
        .navigationTitle("Legal")
    }
}

private struct LegalWebView: View {
    let htmlName: String

    var body: some View {
        Group {
            if let url = Bundle.main.url(forResource: htmlName, withExtension: "html", subdirectory: "Legal")
                ?? Bundle.main.url(forResource: htmlName, withExtension: "html") {
                LegalHTMLView(url: url)
            } else {
                ContentUnavailableView("Page missing", systemImage: "doc.questionmark")
            }
        }
        .navigationTitle(htmlName.replacingOccurrences(of: "-", with: " ").capitalized)
    }
}

private struct LegalHTMLView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebViewWrapper {
        WKWebViewWrapper()
    }

    func updateUIView(_ uiView: WKWebViewWrapper, context: Context) {
        uiView.load(url: url)
    }
}

private final class WKWebViewWrapper: UIView {
    private let webView = WKWebView(frame: .zero)

    override init(frame: CGRect) {
        super.init(frame: frame)
        webView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(webView)
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: trailingAnchor),
            webView.topAnchor.constraint(equalTo: topAnchor),
            webView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    func load(url: URL) {
        webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
    }
}
