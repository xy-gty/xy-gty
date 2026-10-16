import SwiftUI
import AirspanDomain

struct SettingsPrivacyView: View {
    @EnvironmentObject private var model: AppModel
    @State private var legalPage: LocalLegalWebView.Page?

    var body: some View {
        List {
            Section {
                Toggle(isOn: aiSharingBinding) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Share data with \(AirspanIdentity.aiProvider)")
                        Text("Off stops all outbound AI requests immediately.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                if let reason = model.aiUnavailableReason, !model.consentGranted || model.apiKey() == nil {
                    Text(reason)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("AI sharing")
            } footer: {
                Text("Disclosure \(AirspanIdentity.consentDisclosureVersion). Fields: \(AirspanConsentFacade.outboundFieldAllowlist.joined(separator: ", ")).")
            }

            Section("Legal & support") {
                legalRow("Privacy Policy", page: .privacy)
                legalRow("Terms of Use", page: .terms)
                legalRow("Support", page: .support)
                legalRow("\(AirspanIdentity.aiProvider) provider policy", page: .deepseekPrivacy)
            }

            Section("External links (not configured)") {
                gapRow("Privacy URL", gap: AirspanOutboundAIBoundary.privacyURLGap)
                gapRow("Terms URL", gap: AirspanOutboundAIBoundary.termsURLGap)
                gapRow("Support URL", gap: AirspanOutboundAIBoundary.supportURLGap)
            }
        }
        .navigationTitle("Privacy & AI")
        .sheet(item: $legalPage) { page in
            LocalLegalWebView(page: page)
        }
    }

    private var aiSharingBinding: Binding<Bool> {
        Binding(
            get: { model.consentGranted },
            set: { enabled in
                if enabled {
                    guard !model.consentGranted else { return }
                    model.requireConsentThen { }
                } else {
                    model.revokeConsent()
                }
            }
        )
    }

    private func legalRow(_ title: String, page: LocalLegalWebView.Page) -> some View {
        Button {
            legalPage = page
        } label: {
            HStack {
                Text(title)
                    .foregroundStyle(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
        }
    }

    private func gapRow(_ label: String, gap: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(gap)
                .foregroundStyle(.secondary)
                .font(.caption.monospaced())
        }
    }
}
