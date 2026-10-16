import SwiftUI
import SpinewellDomain

struct ConsentSheet: View {
    @ObservedObject var appModel: AppModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Share data with \(AIConsentContract.provider)?")
                        .font(.title2.bold())
                        .foregroundStyle(SpinewellTheme.ink)

                    Text(
                        "Spinewell sends the fields below to \(AIConsentContract.provider) for personal bookshelf coaching — cover/spine ID, TBR/reading chat, and find notes. "
                            + "个人藏书教练 / personal bookshelf coach. "
                            + "非书店目录爬取 / not bookstore catalog scraping. "
                            + "非全文盗版阅读器 / not a full-text piracy reader. "
                            + "非课业批改 / not homework grading. Revoke anytime in Settings."
                    )
                    .font(.body)
                    .foregroundStyle(SpinewellTheme.muted)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Fields sent")
                            .font(.headline)
                            .foregroundStyle(SpinewellTheme.ink)
                        ForEach(AIConsentContract.fields, id: \.self) { field in
                            Label(field.replacingOccurrences(of: "_", with: " "), systemImage: "checkmark.seal.fill")
                                .font(.subheadline)
                                .foregroundStyle(SpinewellTheme.primary)
                        }
                    }

                    Text("Disclosure version: \(AIConsentContract.disclosureVersion)")
                        .font(.caption)
                        .foregroundStyle(SpinewellTheme.muted)

                    HStack(spacing: 12) {
                        Button("Not now") {
                            appModel.dismissConsent()
                        }
                        .buttonStyle(.bordered)

                        Button("Allow") {
                            appModel.grantConsentAndContinue()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(SpinewellTheme.accent)
                    }
                    .padding(.top, 8)
                }
                .padding(24)
            }
            .spinewellScreen()
            .navigationTitle("AI data sharing")
            .navigationBarTitleDisplayMode(.inline)
        }
        .accessibilityIdentifier("ConsentSheet")
    }
}
