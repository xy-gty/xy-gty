import SwiftUI
import BroodcheckDomain

struct ConsentSheet: View {
    @ObservedObject var appModel: AppModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Share data with \(AIConsentContract.provider)?")
                        .font(.title2.bold())
                        .foregroundStyle(BroodcheckTheme.ink)

                    Text(
                        "Broodcheck sends the fields below to \(AIConsentContract.provider) for hive-inspection coaching. "
                            + "This is an inspection aid, not a veterinary device. Revoke anytime in Settings."
                    )
                    .font(.body)
                    .foregroundStyle(BroodcheckTheme.muted)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Fields sent")
                            .font(.headline)
                            .foregroundStyle(BroodcheckTheme.ink)
                        ForEach(AIConsentContract.fields, id: \.self) { field in
                            Label(field.replacingOccurrences(of: "_", with: " "), systemImage: "checkmark.seal.fill")
                                .font(.subheadline)
                                .foregroundStyle(BroodcheckTheme.primary)
                        }
                    }

                    Text("Disclosure version: \(AIConsentContract.disclosureVersion)")
                        .font(.caption)
                        .foregroundStyle(BroodcheckTheme.muted)

                    HStack(spacing: 12) {
                        Button("Not now") {
                            appModel.dismissConsent()
                        }
                        .buttonStyle(.bordered)

                        Button("Allow") {
                            appModel.grantConsentAndContinue()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(BroodcheckTheme.primary)
                    }
                    .padding(.top, 8)
                }
                .padding(24)
            }
            .broodcheckScreen()
            .navigationTitle("AI data sharing")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
