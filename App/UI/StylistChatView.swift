import SwiftUI
import AppRuntimeCore
import ClosetCueDomain

struct StylistChatView: View {
    @EnvironmentObject private var appModel: AppModel
    @FocusState private var chatFocused: Bool
    @FocusState private var weatherFocused: Bool
    @FocusState private var occasionFocused: Bool

    var body: some View {
        RuntimeForm(dismissFocus: { dismissAllFocus() }) {
            VStack(alignment: .leading, spacing: 16) {
                contextFields
                chatField
                if let plan = appModel.pendingPlan ?? appModel.outfitPlans.first {
                    planCard(plan)
                }
                if let reason = appModel.aiUnavailableReason {
                    ClosetCueTheme.mutedText(reason)
                }
            }
            .padding(16)
        } actions: {
            VStack(spacing: 10) {
                HStack(spacing: 10) {
                    Button {
                        appModel.startSpeechCapture()
                    } label: {
                        Label("Mic", systemImage: "mic.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(CCSecondaryButtonStyle())

                    Button("Get plan") {
                        dismissAllFocus()
                        appModel.requestStylistPlan()
                    }
                    .buttonStyle(CCPrimaryButtonStyle())
                    .disabled(appModel.chatBusy)
                }

                Button("Make flat-lay") {
                    appModel.makeFlatLay(from: appModel.pendingPlan)
                }
                .buttonStyle(CCSecondaryButtonStyle())
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
        .closetCueScene()
        .navigationTitle("Stylist")
        .navigationBarTitleDisplayMode(.large)
    }

    private var contextFields: some View {
        VStack(alignment: .leading, spacing: 10) {
            ClosetCueTheme.sectionTitle("Weather & occasion")
            TextField("Weather", text: $appModel.weatherText)
                .focused($weatherFocused)
                .padding(12)
                .background(ClosetCueTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .foregroundStyle(ClosetCueTheme.ink)
            TextField("Occasion", text: $appModel.occasionText)
                .focused($occasionFocused)
                .padding(12)
                .background(ClosetCueTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .foregroundStyle(ClosetCueTheme.ink)
        }
    }

    private var chatField: some View {
        VStack(alignment: .leading, spacing: 8) {
            ClosetCueTheme.sectionTitle("Chat")
            TextField("Ask about today's look…", text: $appModel.chatText, axis: .vertical)
                .lineLimit(3...8)
                .focused($chatFocused)
                .padding(12)
                .background(ClosetCueTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .foregroundStyle(ClosetCueTheme.ink)
        }
    }

    private func planCard(_ plan: OutfitPlan) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ClosetCueTheme.sectionTitle("Outfit plan")
            Text(plan.responseText.isEmpty ? "Waiting for stylist…" : plan.responseText)
                .font(.body)
                .foregroundStyle(ClosetCueTheme.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
            if plan.includesStyleDisclaimer {
                ClosetCueTheme.mutedText(ClosetCueIdentity.styleSuggestionDisclaimer)
            }
        }
        .padding(16)
        .background(ClosetCueTheme.surface)
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(ClosetCueTheme.line, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func dismissAllFocus() {
        chatFocused = false
        weatherFocused = false
        occasionFocused = false
    }
}
