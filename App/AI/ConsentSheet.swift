import SwiftUI
import FrameCueDomain

struct ConsentSheet: View {
    @ObservedObject var appModel: AppModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Share data with \(AIConsentContract.provider)?")
                        .font(.title2.bold())
                        .foregroundStyle(FrameCueTheme.ink)

                    Text(
                        "FrameCue sends the fields below to \(AIConsentContract.provider) for director framing coaching on shot size, aspect, lens language, and overlays. "
                            + "This is a coaching aid, not a camera-metering authority. Revoke anytime in Settings."
                    )
                    .font(.body)
                    .foregroundStyle(FrameCueTheme.muted)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Fields sent")
                            .font(.headline)
                            .foregroundStyle(FrameCueTheme.ink)
                        ForEach(AIConsentContract.fields, id: \.self) { field in
                            Label(field.replacingOccurrences(of: "_", with: " "), systemImage: "checkmark.seal.fill")
                                .font(.subheadline)
                                .foregroundStyle(FrameCueTheme.primary)
                        }
                    }

                    Text("Disclosure version: \(AIConsentContract.disclosureVersion)")
                        .font(.caption)
                        .foregroundStyle(FrameCueTheme.muted)

                    HStack(spacing: 12) {
                        Button("Not now") {
                            appModel.dismissConsent()
                        }
                        .buttonStyle(.bordered)

                        Button("Allow") {
                            appModel.grantConsentAndContinue()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(FrameCueTheme.primary)
                    }
                    .padding(.top, 8)
                }
                .padding(24)
            }
            .frameCueScreen()
            .navigationTitle("AI data sharing")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
