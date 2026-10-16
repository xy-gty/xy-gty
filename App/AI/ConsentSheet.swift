import SwiftUI
import RacknoteDomain

struct ConsentSheet: View {
    @ObservedObject var appModel: AppModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ComplianceBanner()

                    Text("Share data with \(AIConsentContract.provider)?")
                        .font(.title2.bold())
                        .foregroundStyle(RacknoteTheme.ink)

                    Text(
                        "Racknote sends the fields below to \(AIConsentContract.provider) for label OCR, drinking-window coaching, and pull briefs. "
                            + "\(RacknoteCompliance.sommelierCertificationDisclaimer). "
                            + "\(RacknoteCompliance.investmentAdviceDisclaimer). Revoke anytime in Settings."
                    )
                    .font(.body)
                    .foregroundStyle(RacknoteTheme.muted)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Fields sent")
                            .font(.headline)
                            .foregroundStyle(RacknoteTheme.ink)
                        ForEach(AIConsentContract.fields, id: \.self) { field in
                            Label(field.replacingOccurrences(of: "_", with: " "), systemImage: "checkmark.seal.fill")
                                .font(.subheadline)
                                .foregroundStyle(RacknoteTheme.primary)
                        }
                    }

                    Text("Disclosure version: \(AIConsentContract.disclosureVersion)")
                        .font(.caption)
                        .foregroundStyle(RacknoteTheme.muted)

                    HStack(spacing: 12) {
                        Button("Not now") {
                            appModel.dismissConsent()
                        }
                        .buttonStyle(.bordered)

                        Button("Allow") {
                            appModel.grantConsentAndContinue()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(RacknoteTheme.accent)
                    }
                    .padding(.top, 8)
                }
                .padding(24)
            }
            .cellarScreen()
            .navigationTitle("AI data sharing")
            .navigationBarTitleDisplayMode(.inline)
        }
        .accessibilityIdentifier("ConsentSheet")
    }
}
