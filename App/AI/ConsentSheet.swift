import SwiftUI
import CuePartnerDomain

struct ConsentSheet: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("AI data sharing")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(CueTheme.ink)
                    Text("CuePartner AI can send rehearsal context to \(AIConsentContract.provider) so the scene partner can reply in character.")
                        .foregroundStyle(.secondary)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Fields that may be sent")
                            .font(.headline)
                        ForEach(AIConsentContract.fields, id: \.self) { field in
                            Label(AIConsentContract.displayLabel(for: field), systemImage: "arrow.up.circle")
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(CueTheme.panel)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                    Text("Disclosure version: \(AIConsentContract.disclosureVersion)")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text("Practice drafts only — not professional acting certification.")
                        .font(.footnote.weight(.semibold))

                    NavigationLink("DeepSeek privacy policy") {
                        ProviderPolicyView()
                    }
                    NavigationLink("CuePartner Privacy") {
                        LegalPagesView(initial: .privacy)
                    }
                }
                .padding()
            }
            .background(CueTheme.background.ignoresSafeArea())
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
    <title>DeepSeek provider policy</title></head><body>
    <h1>DeepSeek provider policy</h1>
    <p>CuePartner AI uses DeepSeek for optional cloud inference when an API key is configured and you allow AI data sharing.</p>
    <p>External provider policy URL is not configured in this local_only delivery. No network request is sent before you tap Allow on the consent sheet.</p>
    <p>Revoking consent in Settings stops outbound sends immediately, including in-flight requests.</p>
    <p>Practice drafts only — not professional acting certification.</p>
    </body></html>
    """

    var body: some View {
        LocalLegalWebView(source: .inline(Self.inlineHTML))
            .navigationTitle("Provider policy")
    }
}
