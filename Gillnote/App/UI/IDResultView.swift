import SwiftUI
import GillnoteDomain

struct IDResultView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                DisclaimerBanner()

                if let banner = appModel.statusMessage {
                    StatusBanner(text: banner, isError: appModel.statusIsError)
                }

                if appModel.identifyBusy {
                    StatusBanner(text: "Reading morphology…", isError: false)
                }

                SpeciesConfidenceStackView(candidates: appModel.sessionCandidates)

                GillPoreCloseupBarView(
                    subject: appModel.activeSession?.subject ?? "gill",
                    callouts: appModel.sessionCallouts,
                    photoPath: appModel.activeSession?.photoLocalURL,
                    onAnnotate: { appModel.openOverlay() }
                )

                CautionChipRailView(chips: appModel.sessionChips)

                HStack(spacing: 10) {
                    Button {
                        appModel.requestIdentify()
                    } label: {
                        Text(appModel.identifyBusy ? "Identifying…" : "Identify")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(RoundedRectangle(cornerRadius: 14).fill(GillnoteTheme.accent))
                            .foregroundStyle(.white)
                    }
                    .disabled(appModel.identifyBusy)

                    Button("Save Find") {
                        appModel.saveFind()
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(GillnoteTheme.primary, lineWidth: 2)
                    )
                    .foregroundStyle(GillnoteTheme.primary)
                }

                HStack(spacing: 10) {
                    Button("Ask coach") { appModel.push(.lookalikeChat) }
                        .foregroundStyle(GillnoteTheme.primary)
                    Spacer()
                    Button("Play brief") { appModel.playFieldBrief() }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(GillnoteTheme.secondary))
                        .overlay(Capsule().stroke(GillnoteTheme.accent, lineWidth: 1))
                        .foregroundStyle(GillnoteTheme.accent)
                    Button("Dismiss") { appModel.dismissID() }
                        .foregroundStyle(GillnoteTheme.muted)
                }
                .font(.subheadline.weight(.semibold))
            }
            .padding(16)
        }
        .sporeScreen()
        .navigationTitle("ID result")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("IDResult")
    }
}
