import SwiftUI
import ClosetCueDomain

struct SettingsPrivacyView: View {
    @EnvironmentObject private var appModel: AppModel
    @State private var aiSharingToggle = false

    var body: some View {
        List {
            Section("AI data sharing") {
                Toggle("Allow DeepSeek inference", isOn: Binding(
                    get: { aiSharingToggle },
                    set: { enabled in
                        aiSharingToggle = enabled
                        if enabled {
                            if appModel.consentGranted { return }
                            appModel.showConsent = true
                        } else {
                            appModel.revokeConsent()
                        }
                    }
                ))
                if let reason = appModel.aiUnavailableReason {
                    Text(reason).font(.footnote).foregroundStyle(.secondary)
                }
                Text("Provider: \(ClosetCueIdentity.aiProvider)")
                Text("Disclosure: \(ClosetCueIdentity.consentDisclosureVersion)")
                ForEach(ClosetCueConsentFacade.outboundFieldAllowlist, id: \.self) { field in
                    Text("• \(field)").font(.caption).foregroundStyle(.secondary)
                }
                Button("Revoke AI consent") {
                    appModel.revokeConsent()
                    aiSharingToggle = false
                }
                .accessibilityIdentifier("revoke_ai_consent")
                .disabled(!appModel.consentGranted)
            }

            Section("Legal (local)") {
                NavigationLink("Privacy") { LegalPagesView(initial: .privacy) }
                NavigationLink("Terms") { LegalPagesView(initial: .terms) }
                NavigationLink("Support") { LegalPagesView(initial: .support) }
                NavigationLink("Provider policy") { ProviderPolicyView() }
            }

            Section("Compliance") {
                Text(ClosetCueIdentity.styleSuggestionDisclaimer).font(.footnote)
            }
        }
        .scrollContentBackground(.hidden)
        .background(ClosetCueTheme.bg.ignoresSafeArea())
        .navigationTitle("Settings")
        .onAppear { aiSharingToggle = appModel.consentGranted }
        .onChange(of: appModel.consentGranted) { _, granted in aiSharingToggle = granted }
        .onChange(of: appModel.showConsent) { _, showing in
            if !showing && !appModel.consentGranted { aiSharingToggle = false }
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
            LocalLegalWebView(source: .bundleHTML(name: page.rawValue))
        }
        .onAppear { page = initial }
        .navigationTitle(page.title)
        .background(ClosetCueTheme.bg.ignoresSafeArea())
    }
}
