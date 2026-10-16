import SunbriefDomain
import SwiftUI

struct ConsentSheet: View {
    @ObservedObject var appModel: AppModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Share data with \(AIConsentContract.provider)?")
                        .font(.title2.bold())
                        .foregroundStyle(SunbriefTheme.ink)

                    Text(
                        "Sunbrief sends the fields below to \(AIConsentContract.provider) for sun/moon timing coaching. "
                            + "Advice is a scouting aid, not an observatory or light meter. Revoke anytime in Settings."
                    )
                    .font(.body)
                    .foregroundStyle(SunbriefTheme.muted)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Fields sent")
                            .font(.headline)
                            .foregroundStyle(SunbriefTheme.ink)
                        ForEach(AIConsentContract.fields, id: \.self) { field in
                            Label(field.replacingOccurrences(of: "_", with: " "), systemImage: "checkmark.circle")
                                .font(.subheadline)
                                .foregroundStyle(SunbriefTheme.indigo)
                        }
                    }

                    Text("Disclosure version: \(AIConsentContract.disclosureVersion)")
                        .font(.caption)
                        .foregroundStyle(SunbriefTheme.muted)

                    HStack(spacing: 12) {
                        Button("Not now") {
                            appModel.dismissConsent()
                        }
                        .buttonStyle(.bordered)
                        .tint(SunbriefTheme.muted)

                        Button("Allow") {
                            appModel.grantConsentAndContinue()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(SunbriefTheme.indigo)
                    }
                    .padding(.top, 8)
                }
                .padding(24)
            }
            .sunbriefScreen()
            .navigationTitle("AI data sharing")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
