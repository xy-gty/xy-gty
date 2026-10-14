import SwiftUI
import BendCoachDomain

struct SettingsPrivacyView: View {
    @EnvironmentObject private var model: AppModel
    @State private var aiSharingToggle = false

    var body: some View {
        List {
            Section("AI data sharing") {
                Toggle("Allow DeepSeek inference", isOn: Binding(
                    get: { aiSharingToggle },
                    set: { enabled in
                        aiSharingToggle = enabled
                        if enabled {
                            if model.consentGranted { return }
                            model.showConsent = true
                        } else {
                            model.revokeConsent()
                        }
                    }
                ))
                if let reason = model.aiUnavailableReason {
                    Text(reason).font(.footnote).foregroundStyle(.secondary)
                }
                Text("Provider: \(BendCoachIdentity.aiProvider)")
                Text("Disclosure: \(BendCoachIdentity.consentDisclosureVersion)")
                ForEach(BendCoachConsentFacade.outboundFieldAllowlist, id: \.self) { field in
                    Text("• \(field)").font(.caption).foregroundStyle(.secondary)
                }
                Button("Revoke AI consent") {
                    model.revokeConsent()
                    aiSharingToggle = false
                }
                .accessibilityIdentifier("revoke_ai_consent")
                .disabled(!model.consentGranted)
            }

            Section("Units") {
                NavigationLink("Units") { UnitsSettingsView() }
            }

            Section("Device permissions") {
                Text("Camera: capture job-site bend / markup photos for recognition review.").font(.footnote)
                Text("Photos: import field photos to recognize bend types before Save.").font(.footnote)
                Text("Microphone + Speech: speak bend-math questions into chat; review before send.").font(.footnote)
                Text("Permissions support on-device capture only; AI outbound still requires separate consent.")
                    .font(.caption).foregroundStyle(.secondary)
            }

            Section("Legal (local)") {
                NavigationLink("Privacy") { LegalPagesView(initial: .privacy) }
                NavigationLink("Terms") { LegalPagesView(initial: .terms) }
                NavigationLink("Support") { LegalPagesView(initial: .support) }
                NavigationLink("Provider policy") { ProviderPolicyView() }
            }

            Section("Compliance") {
                Text(BendCoachIdentity.assistiveDisclaimer).font(.footnote)
            }
        }
        .scrollContentBackground(.hidden)
        .background(BendCoachTheme.bg.ignoresSafeArea())
        .navigationTitle("Settings")
        .onAppear { aiSharingToggle = model.consentGranted }
        .onChange(of: model.consentGranted) { _, _ in aiSharingToggle = model.consentGranted }
        .onChange(of: model.showConsent) { _, showing in
            if !showing && !model.consentGranted { aiSharingToggle = false }
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
        .background(BendCoachTheme.bg.ignoresSafeArea())
    }
}
