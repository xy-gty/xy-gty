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
                            Label(field, systemImage: "arrow.up.circle")
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
    var body: some View {
        // Local fallback page when external URL is UNKNOWN gap.
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("DeepSeek provider policy")
                    .font(.title3.weight(.bold))
                Text("External provider policy URL is not configured in this local_only delivery (gap). This in-app page discloses that SnagCue AI uses DeepSeek for optional cloud inference when a key and consent are present.")
                Text("No request is sent before you tap Allow on the consent sheet. Revoking consent in Settings stops outbound sends immediately.")
            }
            .padding()
        }
        .navigationTitle("Provider policy")
    }
}
