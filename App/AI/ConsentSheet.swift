import SwiftUI
import FinishCueDomain

struct ConsentSheet: View {
    @ObservedObject var appModel: AppModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Share data with \(AIConsentContract.provider)?")
                        .font(.title2.bold())
                        .foregroundStyle(FinishCueTheme.ink)

                    Text(
                        "FinishCue sends the fields below to \(AIConsentContract.provider) for finish-line coaching — lane/athlete ID, heat chat, and spoken cues. "
                            + "Training aid & amateur meet photo timing. "
                            + "Not an official FAT timing device. "
                            + "Not betting or anti-doping. Revoke anytime in Settings."
                    )
                    .font(.body)
                    .foregroundStyle(FinishCueTheme.muted)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Fields sent")
                            .font(.headline)
                            .foregroundStyle(FinishCueTheme.ink)
                        ForEach(AIConsentContract.fields, id: \.self) { field in
                            Label(field.replacingOccurrences(of: "_", with: " "), systemImage: "checkmark.seal.fill")
                                .font(.subheadline)
                                .foregroundStyle(FinishCueTheme.primary)
                        }
                    }

                    Text("Disclosure version: \(AIConsentContract.disclosureVersion)")
                        .font(.caption)
                        .foregroundStyle(FinishCueTheme.muted)

                    Button("Provider policy") {
                        appModel.showConsent = false
                        appModel.openLegal("provider-policy")
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(FinishCueTheme.accent)

                    HStack(spacing: 12) {
                        Button("Not now") {
                            appModel.dismissConsent()
                        }
                        .buttonStyle(.bordered)

                        Button("Allow") {
                            appModel.grantConsentAndContinue()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(FinishCueTheme.accent)
                    }
                    .padding(.top, 8)
                }
                .padding(24)
            }
            .finishCueScreen()
            .navigationTitle("AI data sharing")
            .navigationBarTitleDisplayMode(.inline)
        }
        .accessibilityIdentifier("ConsentSheet")
    }
}
