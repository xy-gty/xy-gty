import SwiftUI
import DocBriefDomain

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
                Text("Provider: \(DocBriefIdentity.aiProvider)")
                Text("Disclosure: \(DocBriefIdentity.consentDisclosureVersion)")
                ForEach(DocBriefConsentFacade.outboundFieldAllowlist, id: \.self) { field in
                    Text("• \(field)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Section("Legal (local)") {
                NavigationLink("Privacy") { LegalPagesView(initial: .privacy) }
                NavigationLink("Terms") { LegalPagesView(initial: .terms) }
                NavigationLink("Support") { LegalPagesView(initial: .support) }
                NavigationLink("Provider policy") { ProviderPolicyView() }
            }

            Section("Compliance") {
                Text(DocBriefIdentity.nonCertificationDisclaimer)
                    .font(.footnote)
            }
        }
        .scrollContentBackground(.hidden)
        .background(DocBriefTheme.paper.ignoresSafeArea())
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
        var resource: String { rawValue }
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
            LocalLegalWebView(source: .bundleHTML(name: page.resource))
        }
        .onAppear { page = initial }
        .navigationTitle(page.title)
        .background(DocBriefTheme.paper.ignoresSafeArea())
    }
}
