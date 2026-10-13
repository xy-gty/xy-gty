import SwiftUI
import SnagCueDomain

struct SettingsPrivacyView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        List {
            Section("AI data sharing") {
                Toggle("Allow DeepSeek inference", isOn: Binding(
                    get: { model.consentGranted },
                    set: { enabled in
                        if enabled {
                            if !model.consentGranted {
                                model.showConsent = true
                            }
                        } else {
                            model.revokeConsent()
                        }
                    }
                ))
                if let reason = model.aiUnavailableReason {
                    Text(reason)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Text("Provider: \(AIConsentContract.provider)")
                Text("Disclosure: \(AIConsentContract.disclosureVersion)")
            }

            Section("Legal (local)") {
                NavigationLink("Privacy") { LegalPagesView(initial: .privacy) }
                NavigationLink("Terms") { LegalPagesView(initial: .terms) }
                NavigationLink("Support") { LegalPagesView(initial: .support) }
                NavigationLink("Provider policy") { ProviderPolicyView() }
            }

            Section("Compliance") {
                Text("SnagCue AI provides inspection guidance only. It is not a building-code, legal, or certification authority.")
                    .font(.footnote)
            }
        }
        .navigationTitle("Settings")
        .sheet(isPresented: $model.showConsent) {
            ConsentSheet()
                .environmentObject(model)
        }
    }
}

struct LegalPagesView: View {
    enum Page: String, CaseIterable, Identifiable {
        case privacy, terms, support
        var id: String { rawValue }
        var title: String {
            switch self {
            case .privacy: return "Privacy"
            case .terms: return "Terms"
            case .support: return "Support"
            }
        }
        var resource: String {
            switch self {
            case .privacy: return "privacy"
            case .terms: return "terms"
            case .support: return "support"
            }
        }
    }

    var initial: Page = .privacy
    @State private var page: Page = .privacy

    var body: some View {
        VStack(spacing: 0) {
            Picker("Page", selection: $page) {
                ForEach(Page.allCases) { Text($0.title).tag($0) }
            }
            .pickerStyle(.segmented)
            .padding()
            ScrollView {
                Text(loadHTMLText(page.resource))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
        }
        .onAppear { page = initial }
        .navigationTitle(page.title)
    }

    private func loadHTMLText(_ name: String) -> String {
        if let url = Bundle.main.url(forResource: name, withExtension: "html", subdirectory: "Legal"),
           let data = try? Data(contentsOf: url),
           let html = String(data: data, encoding: .utf8) {
            return stripTags(html)
        }
        return """
        \(name.capitalized) — SnagCue AI

        This local page ships with the app. External legal URLs are UNKNOWN gaps for this local_only delivery.

        SnagCue AI stores audits, photos, and punch items on device. Optional AI features send listed fields to DeepSeek only after consent. Guidance only — not certification.
        """
    }

    private func stripTags(_ html: String) -> String {
        html
            .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
