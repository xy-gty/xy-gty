import SwiftUI
import BendCoachDomain

struct ConsentSheet: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("AI data sharing")
                        .font(.title2.weight(.bold))
                    Text("BendCoach AI can send bend-math and field context to \(BendCoachIdentity.aiProvider) for coaching, recognition, diagrams, and step generation.")
                        .foregroundStyle(.secondary)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Fields that may be sent").font(.headline)
                        ForEach(BendCoachConsentFacade.outboundFieldAllowlist, id: \.self) { field in
                            Label(field, systemImage: "arrow.up.circle")
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(BendCoachTheme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                    Text("Disclosure version: \(BendCoachIdentity.consentDisclosureVersion)")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(BendCoachIdentity.assistiveDisclaimer)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(BendCoachTheme.warn)

                    NavigationLink("DeepSeek privacy policy") { ProviderPolicyView() }
                    NavigationLink("BendCoach Privacy") { LegalPagesView(initial: .privacy) }
                }
                .padding()
            }
            .background(BendCoachTheme.bg.ignoresSafeArea())
            .foregroundStyle(BendCoachTheme.ink)
            .navigationTitle("Allow AI")
            .navigationBarTitleDisplayMode(.inline)
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
    <title>DeepSeek provider policy</title></head><body style="font-family:-apple-system;padding:16px;background:#1A2332;color:#F2F4F7">
    <h1>DeepSeek provider policy</h1>
    <p>BendCoach AI uses DeepSeek for optional cloud inference when an API key is configured and you allow AI data sharing.</p>
    <p>External provider policy URL is not configured in this local_only delivery. No network request is sent before you tap Allow on the consent sheet.</p>
    <p>Revoking consent in Settings stops outbound sends immediately.</p>
    <p>Assistive guidance only — not a substitute for code or engineer judgment.</p>
    </body></html>
    """

    var body: some View {
        LocalLegalWebView(source: .inline(Self.inlineHTML))
            .navigationTitle("Provider policy")
    }
}
