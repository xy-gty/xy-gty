import SwiftUI
import SnagCueDomain

struct ConsentSheet: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("AI data sharing")
                        .font(.title2.weight(.bold))
                    Text("SnagCue AI can send inspection content to \(AIConsentContract.provider) for snag recognition, field fill, and report captions.")
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
                    .background(SnagTheme.panel)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                    Text("Disclosure version: \(AIConsentContract.disclosureVersion)")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text("Guidance only — not a building-code or legal certification.")
                        .font(.footnote.weight(.semibold))

                    NavigationLink("DeepSeek privacy policy") {
                        ProviderPolicyView()
                    }
                    NavigationLink("SnagCue Privacy") {
                        LegalPagesView(initial: .privacy)
                    }
                }
                .padding()
            }
            .background(SnagTheme.background.ignoresSafeArea())
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
    <p>SnagCue AI uses DeepSeek for optional cloud inference when an API key is configured and you allow AI data sharing.</p>
    <p>External provider policy URL is not configured in this local_only delivery. No network request is sent before you tap Allow on the consent sheet.</p>
    <p>Revoking consent in Settings stops outbound sends immediately, including in-flight requests.</p>
    <p>Guidance only — not a building-code or legal certification.</p>
    </body></html>
    """

    var body: some View {
        LocalLegalWebView(source: .inline(Self.inlineHTML))
            .navigationTitle("Provider policy")
    }
}
