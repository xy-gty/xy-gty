import SwiftUI
import FormCueDomain

struct ConsentSheet: View {
    @ObservedObject var appModel: AppModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Share data with \(AIConsentContract.provider)?")
                        .font(.title2.bold())
                        .foregroundStyle(FormCueTheme.ink)

                    Text(
                        "FormCue sends the fields below to \(AIConsentContract.provider) for HIIT form coaching. "
                            + "This is a training aid, not a medical device. Revoke anytime in Settings."
                    )
                    .font(.body)
                    .foregroundStyle(FormCueTheme.muted)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Fields sent")
                            .font(.headline)
                            .foregroundStyle(FormCueTheme.ink)
                        ForEach(AIConsentContract.fields, id: \.self) { field in
                            Label(field.replacingOccurrences(of: "_", with: " "), systemImage: "checkmark.circle")
                                .font(.subheadline)
                                .foregroundStyle(FormCueTheme.primary)
                        }
                    }

                    Text("Disclosure version: \(AIConsentContract.disclosureVersion)")
                        .font(.caption)
                        .foregroundStyle(FormCueTheme.muted)

                    HStack(spacing: 12) {
                        Button("Not now") {
                            appModel.dismissConsent()
                        }
                        .buttonStyle(.bordered)

                        Button("Allow") {
                            appModel.grantConsentAndContinue()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(FormCueTheme.primary)
                    }
                    .padding(.top, 8)
                }
                .padding(24)
            }
            .formCueScreen()
            .navigationTitle("AI data sharing")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
