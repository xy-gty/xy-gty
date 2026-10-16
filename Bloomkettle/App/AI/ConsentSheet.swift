import SwiftUI
import BloomkettleDomain

struct ConsentSheet: View {
    @ObservedObject var appModel: AppModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Share data with \(AIConsentContract.provider)?")
                        .font(.title2.bold())
                        .foregroundStyle(BloomkettleTheme.ink)

                    Text(
                        "Bloomkettle sends the fields below to \(AIConsentContract.provider) for home pour-over coaching. "
                            + "Home brew coach only — not barista certification, not nutrition/medical, not equipment warranty, no alcohol-service claims. "
                            + "Revoke anytime in Settings."
                    )
                    .font(.body)
                    .foregroundStyle(BloomkettleTheme.muted)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Fields sent")
                            .font(.headline)
                            .foregroundStyle(BloomkettleTheme.ink)
                        ForEach(AIConsentContract.fields, id: \.self) { field in
                            Label(field.replacingOccurrences(of: "_", with: " "), systemImage: "checkmark.seal.fill")
                                .font(.subheadline)
                                .foregroundStyle(BloomkettleTheme.primary)
                        }
                    }

                    Text("Disclosure version: \(AIConsentContract.disclosureVersion)")
                        .font(.caption)
                        .foregroundStyle(BloomkettleTheme.muted)

                    Button("Provider policy") {
                        appModel.showConsent = false
                        appModel.openLegal("provider-policy")
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(BloomkettleTheme.accent)

                    HStack(spacing: 12) {
                        Button("Not now") { appModel.dismissConsent() }
                            .buttonStyle(.bordered)
                        Button("Allow") { appModel.grantConsentAndContinue() }
                            .buttonStyle(.borderedProminent)
                            .tint(BloomkettleTheme.accent)
                    }
                    .padding(.top, 8)
                }
                .padding(24)
            }
            .bloomkettleScreen()
            .navigationTitle("AI data sharing")
            .navigationBarTitleDisplayMode(.inline)
        }
        .accessibilityIdentifier("ConsentSheet")
    }
}
