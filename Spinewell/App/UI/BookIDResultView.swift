import SwiftUI
import SpinewellDomain

struct BookIDResultView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ComplianceRibbon()

                CoverOCRCardView(
                    title: appModel.activeBookID?.title ?? "Pending ID",
                    author: appModel.activeBookID?.author ?? "",
                    rationale: appModel.activeBookID?.rationale ?? "Tap Identify Book to run AI or local draft.",
                    confidence: appModel.activeBookID?.confidence,
                    pending: appModel.activeBookID == nil,
                    onIdentify: appModel.identifyBusy ? nil : { appModel.requestIdentify() }
                )

                ReadingProgressBarView(progress: appModel.activeProgress)

                if appModel.activeBookID != nil {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Edit before save")
                            .font(.headline)
                            .foregroundStyle(SpinewellTheme.ink)
                        TextField("Title", text: $appModel.editTitleDraft)
                            .textFieldStyle(.roundedBorder)
                        HStack {
                            Text("Progress %")
                            Slider(
                                value: Binding(
                                    get: { Double(appModel.editProgressDraft) },
                                    set: { appModel.editProgressDraft = Int($0) }
                                ),
                                in: 0 ... 100,
                                step: 1
                            )
                            Text("\(appModel.editProgressDraft)")
                                .monospacedDigit()
                        }
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(SpinewellTheme.cardFace)
                    )

                    HStack {
                        Button("Save to Shelf") { appModel.saveToShelf() }
                            .buttonStyle(.borderedProminent)
                            .tint(SpinewellTheme.primary)
                        Button("Dismiss") { appModel.dismissID() }
                            .buttonStyle(.bordered)
                    }

                    HStack {
                        Button("Coach") { appModel.push(.coachChat) }
                        Button("Shelf Card") { appModel.buildShelfCard() }
                        Button("Speak Find") { appModel.speakFindCallout() }
                    }
                    .buttonStyle(.bordered)
                }

                if appModel.identifyBusy {
                    ProgressView("Identifying…")
                }
            }
            .padding(16)
        }
        .spinewellScreen()
        .navigationTitle("Book ID")
        .accessibilityIdentifier("BookIDResult")
    }
}
