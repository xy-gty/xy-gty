import SwiftUI
import HeatbarDomain

struct ConsentSheet: View {
    @ObservedObject var appModel: AppModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Share data with \(AIConsentContract.provider)?")
                        .font(.title2.bold())
                        .foregroundStyle(HeatbarTheme.ink)

                    Text(
                        "Heatbar sends the fields below to \(AIConsentContract.provider) for finish-line coaching — lane/athlete ID, heat chat, and spoken lines. "
                            + "Training aid & amateur meet photo timing. "
                            + "Not an official FAT timing device. "
                            + "Not betting or anti-doping. Revoke anytime in Settings."
                    )
                    .font(.body)
                    .foregroundStyle(HeatbarTheme.muted)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Fields sent")
                            .font(.headline)
                            .foregroundStyle(HeatbarTheme.ink)
                        ForEach(AIConsentContract.fields, id: \.self) { field in
                            Label(field.replacingOccurrences(of: "_", with: " "), systemImage: "checkmark.seal.fill")
                                .font(.subheadline)
                                .foregroundStyle(HeatbarTheme.primary)
                        }
                    }

                    Text("Disclosure version: \(AIConsentContract.disclosureVersion)")
                        .font(.caption)
                        .foregroundStyle(HeatbarTheme.muted)

                    Button("Provider policy") {
                        appModel.showConsent = false
                        appModel.openLegal("provider-policy")
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(HeatbarTheme.accent)

                    HStack(spacing: 12) {
                        Button("Not now") {
                            appModel.dismissConsent()
                        }
                        .buttonStyle(.bordered)

                        Button("Allow") {
                            appModel.grantConsentAndContinue()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(HeatbarTheme.accent)
                    }
                    .padding(.top, 8)
                }
                .padding(24)
            }
            .heatbarScreen()
            .navigationTitle("AI data sharing")
            .navigationBarTitleDisplayMode(.inline)
        }
        .accessibilityIdentifier("ConsentSheet")
    }
}
