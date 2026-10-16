import SwiftUI
import HemlineDomain

struct ConsentSheet: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("AI data sharing")
                        .font(.title2.weight(.bold))
                    Text(
                        "Hemline can send wardrobe context to \(HemlineIdentity.aiProvider) "
                            + "for garment recognition, stylist chat, and morning briefings."
                    )
                    .foregroundStyle(.secondary)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Fields that may be sent").font(.headline)
                        ForEach(HemlineConsentFacade.outboundFieldAllowlist, id: \.self) { field in
                            Label(field, systemImage: "arrow.up.circle")
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(HemlineTheme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                    Text("Disclosure version: \(HemlineIdentity.consentDisclosureVersion)")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(HemlineIdentity.styleSuggestionDisclaimer)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(HemlineTheme.warn)

                    NavigationLink("DeepSeek privacy policy") { ProviderPolicyView() }
                    NavigationLink("Hemline Privacy") { LegalPagesView(initial: .privacy) }
                }
                .padding()
            }
            .background(HemlineTheme.bg.ignoresSafeArea())
            .foregroundStyle(HemlineTheme.ink)
            .navigationTitle("Allow AI")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Not now") { appModel.denyConsent() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Allow") { appModel.grantConsent() }
                        .fontWeight(.semibold)
                }
            }
        }
    }
}

struct ProviderPolicyView: View {
    private static let inlineHTML = """
    <!DOCTYPE html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
    <title>DeepSeek provider policy</title></head><body style="font-family:-apple-system;padding:16px;background:#2A2E34;color:#F5F1EA">
    <h1>DeepSeek provider policy</h1>
    <p>Hemline uses DeepSeek for optional cloud inference when an API key is configured and you allow AI data sharing.</p>
    <p>External provider policy URL is not configured in this local_only delivery. No network request is sent before you tap Allow on the consent sheet.</p>
    <p>Revoking consent in Settings stops outbound sends immediately.</p>
    <p>Style suggestions only — not a brand or retailer endorsement.</p>
    </body></html>
    """

    var body: some View {
        LocalLegalWebView(source: .inline(Self.inlineHTML))
            .navigationTitle("Provider policy")
    }
}
