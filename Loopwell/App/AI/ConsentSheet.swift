import SwiftUI
import LoopwellDomain

struct ConsentSheet: View {
    @ObservedObject var appModel: AppModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Share data with \(AIConsentContract.provider)?")
                        .font(.title2.bold())
                        .foregroundStyle(LoopwellTheme.ink)

                    Text(
                        "Loopwell sends the fields below to \(AIConsentContract.provider) for next-row weave coaching. "
                            + "This is a knitting/crochet aid, not a medical device. Revoke anytime in Settings."
                    )
                    .font(.body)
                    .foregroundStyle(LoopwellTheme.muted)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Fields sent")
                            .font(.headline)
                            .foregroundStyle(LoopwellTheme.ink)
                        ForEach(AIConsentContract.fields, id: \.self) { field in
                            Label(field.replacingOccurrences(of: "_", with: " "), systemImage: "checkmark.circle")
                                .font(.subheadline)
                                .foregroundStyle(LoopwellTheme.fuchsia)
                        }
                    }

                    Text("Disclosure version: \(AIConsentContract.disclosureVersion)")
                        .font(.caption)
                        .foregroundStyle(LoopwellTheme.muted)

                    HStack(spacing: 12) {
                        Button("Not now") {
                            appModel.dismissConsent()
                        }
                        .buttonStyle(.bordered)

                        Button("Allow") {
                            appModel.grantConsentAndContinue()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(LoopwellTheme.fuchsia)
                    }
                    .padding(.top, 8)
                }
                .padding(24)
            }
            .loopwellScreen()
            .navigationTitle("AI data sharing")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
