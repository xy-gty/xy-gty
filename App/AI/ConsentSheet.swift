import SwiftUI
import DocBriefDomain

struct ConsentSheet: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("AI data sharing")
                        .font(.title2.weight(.bold))
                    Text("DocBrief AI can send brief content to \(DocBriefIdentity.aiProvider) for recognition, action extract, and summary cards.")
                        .foregroundStyle(.secondary)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Fields that may be sent")
                            .font(.headline)
                        ForEach(DocBriefConsentFacade.outboundFieldAllowlist, id: \.self) { field in
                            Label(field, systemImage: "arrow.up.circle")
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(DocBriefTheme.mist)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                    Text("Disclosure version: \(DocBriefIdentity.consentDisclosureVersion)")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(DocBriefIdentity.nonCertificationDisclaimer)
                        .font(.footnote.weight(.semibold))

                    NavigationLink("DeepSeek privacy policy") {
                        ProviderPolicyView()
                    }
                    NavigationLink("DocBrief Privacy") {
                        LegalPagesView(initial: .privacy)
                    }
                }
                .padding()
            }
            .background(DocBriefTheme.paper.ignoresSafeArea())
            .navigationTitle("Allow AI")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Not now") { model.denyConsent() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Allow") { model.grantConsent() }
                        .fontWeight(.semibold)
                }
            }
        }
    }
}

struct ProviderPolicyView: View {
    private static let inlineHTML = """
    <!DOCTYPE html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
    <title>DeepSeek provider policy</title></head><body style="font-family:-apple-system;padding:16px;background:#F3EDE3;color:#1C2430">
    <h1>DeepSeek provider policy</h1>
    <p>DocBrief AI uses DeepSeek for optional cloud inference when an API key is configured and you allow AI data sharing.</p>
    <p>External provider policy URL is not configured in this local_only delivery. No network request is sent before you tap Allow on the consent sheet.</p>
    <p>Revoking consent in Settings stops outbound sends immediately.</p>
    <p>Recognition and suggestions are organization aids only — not financial, tax, or legal certification.</p>
    </body></html>
    """

    var body: some View {
        LocalLegalWebView(source: .inline(Self.inlineHTML))
            .navigationTitle("Provider policy")
    }
}
