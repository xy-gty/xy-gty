import SwiftUI
import AppRuntimeCore
import HemlineDomain

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
                    HemlineTheme.mutedText(reason)
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
        .hemlineScene()
        .navigationTitle("Stylist")
        .navigationBarTitleDisplayMode(.large)
    }

    private var contextFields: some View {
        VStack(alignment: .leading, spacing: 10) {
            HemlineTheme.sectionTitle("Weather & occasion")
            TextField("Weather", text: $appModel.weatherText)
                .focused($weatherFocused)
                .padding(12)
                .background(HemlineTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .foregroundStyle(HemlineTheme.ink)
            TextField("Occasion", text: $appModel.occasionText)
                .focused($occasionFocused)
                .padding(12)
                .background(HemlineTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .foregroundStyle(HemlineTheme.ink)
        }
    }

    private var chatField: some View {
        VStack(alignment: .leading, spacing: 8) {
            HemlineTheme.sectionTitle("Chat")
            TextField("Ask about today's look…", text: $appModel.chatText, axis: .vertical)
                .lineLimit(3...8)
                .focused($chatFocused)
                .padding(12)
                .background(HemlineTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .foregroundStyle(HemlineTheme.ink)
        }
    }

    private func planCard(_ plan: OutfitPlan) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HemlineTheme.sectionTitle("Outfit plan")
            Text(plan.responseText.isEmpty ? "Waiting for stylist…" : plan.responseText)
                .font(.body)
                .foregroundStyle(HemlineTheme.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
            if plan.includesStyleDisclaimer {
                HemlineTheme.mutedText(HemlineIdentity.styleSuggestionDisclaimer)
            }
        }
        .padding(16)
        .background(HemlineTheme.surface)
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(HemlineTheme.line, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func dismissAllFocus() {
        chatFocused = false
        weatherFocused = false
        occasionFocused = false
    }
}
