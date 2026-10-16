import SwiftUI
import BloomkettleDomain

struct FunnelTimelineView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                ComplianceBanner()

                Text("Pour-over funnel")
                    .font(.title2.bold())
                    .foregroundStyle(BloomkettleTheme.primary)

                // Vertical funnel timeline (signature — not bottle-rail / bin / spine / slit)
                FunnelTimeline(steps: appModel.funnelSteps)
                    .frame(minHeight: 220)
                    .accessibilityIdentifier("FunnelTimeline")

                // Large next-pour grams/time card
                NextPourCard(
                    grams: $appModel.nextPourGrams,
                    seconds: $appModel.nextPourSeconds,
                    busy: appModel.readBusy,
                    onApply: { appModel.applyNextPourCard() }
                )
                .accessibilityIdentifier("NextPourCard")

                // Grind-size chip rail
                GrindChipRail(
                    chips: appModel.grindChips,
                    selected: appModel.selectedGrind,
                    onSelect: { appModel.selectGrind($0) }
                )
                .accessibilityIdentifier("GrindChipRail")

                if let reason = appModel.aiUnavailableReason {
                    Text(reason)
                        .font(.caption)
                        .foregroundStyle(BloomkettleTheme.muted)
                }

                Button {
                    appModel.coachThisBrew()
                } label: {
                    Label(appModel.readBusy ? "Reading pour…" : "Coach this brew", systemImage: "sparkles")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(BloomkettleTheme.accent)
                .disabled(appModel.readBusy)
                .accessibilityIdentifier("CoachThisBrew")

                HStack {
                    Button("Coach chat") { appModel.push(.coachChat) }
                        .buttonStyle(.bordered)
                    Button("Read aloud") {
                        if appModel.speechService.isListening {
                            appModel.stopSpeechCue()
                        } else {
                            appModel.startSpeechCue()
                        }
                    }
                    .buttonStyle(.bordered)
                    .tint(BloomkettleTheme.primary)
                    .accessibilityIdentifier("SpeakCue")
                }
            }
            .padding(20)
        }
        .bloomkettleScreen()
        .navigationTitle("Funnel")
        .accessibilityIdentifier("FunnelTimelineScreen")
    }
}

struct FunnelTimeline: View {
    let steps: [PourStep]

    var body: some View {
        ZStack(alignment: .top) {
            // Funnel silhouette
            FunnelShape()
                .fill(
                    LinearGradient(
                        colors: [BloomkettleTheme.primary.opacity(0.35), BloomkettleTheme.secondary, BloomkettleTheme.accent.opacity(0.25)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(FunnelShape().stroke(BloomkettleTheme.primary.opacity(0.55), lineWidth: 2))

            VStack(spacing: 10) {
                if steps.isEmpty {
                    Text("Capture a shot to seed bloom → pours → drawdown")
                        .font(.caption)
                        .foregroundStyle(BloomkettleTheme.muted)
                        .padding(.top, 40)
                } else {
                    ForEach(Array(steps.enumerated()), id: \.element.id) { idx, step in
                        HStack {
                            Circle()
                                .fill(BloomkettleTheme.accent)
                                .frame(width: 10, height: 10)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(label(for: step))
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(BloomkettleTheme.ink)
                                Text(detail(for: step))
                                    .font(.caption)
                                    .foregroundStyle(BloomkettleTheme.muted)
                            }
                            Spacer()
                        }
                        .padding(.horizontal, CGFloat(24 + idx * 8))
                        .padding(.vertical, 4)
                    }
                }
            }
            .padding(.vertical, 20)
        }
        .frame(maxWidth: .infinity)
    }

    private func label(for step: PourStep) -> String {
        if step.kind == "pour" { return "Pour \(step.pourIndex)" }
        return step.kind.capitalized
    }

    private func detail(for step: PourStep) -> String {
        let g = step.targetGrams.map { String(format: "%.0f g", $0) } ?? "—"
        let s = step.targetSeconds.map { String(format: "%.0f s", $0) } ?? "—"
        return "\(g) · \(s)"
    }
}

struct FunnelShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let topInset = rect.width * 0.08
        let bottomW = rect.width * 0.28
        p.move(to: CGPoint(x: topInset, y: rect.minY + 8))
        p.addLine(to: CGPoint(x: rect.maxX - topInset, y: rect.minY + 8))
        p.addLine(to: CGPoint(x: rect.midX + bottomW / 2, y: rect.maxY - 8))
        p.addLine(to: CGPoint(x: rect.midX - bottomW / 2, y: rect.maxY - 8))
        p.closeSubpath()
        return p
    }
}

struct NextPourCard: View {
    @Binding var grams: Double
    @Binding var seconds: Double
    var busy: Bool
    var onApply: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Next pour")
                .font(.headline)
                .foregroundStyle(BloomkettleTheme.ink)
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(String(format: "%.0f", grams))
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundStyle(BloomkettleTheme.primary)
                    .accessibilityIdentifier("NextPourGrams")
                Text("g")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(BloomkettleTheme.muted)
                Spacer()
                Text(String(format: "%.0f", seconds))
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(BloomkettleTheme.accent)
                    .accessibilityIdentifier("NextPourSeconds")
                Text("s")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(BloomkettleTheme.muted)
            }
            if busy {
                ProgressView("Reading pour…")
                    .tint(BloomkettleTheme.accent)
            }
            Slider(value: $grams, in: 10...200, step: 5)
                .tint(BloomkettleTheme.primary)
            Slider(value: $seconds, in: 5...120, step: 5)
                .tint(BloomkettleTheme.accent)
            Button("Apply to funnel", action: onApply)
                .buttonStyle(.bordered)
                .tint(BloomkettleTheme.primary)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white.opacity(0.92))
                .shadow(color: BloomkettleTheme.accent.opacity(0.15), radius: 10, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(BloomkettleTheme.primary.opacity(0.35), lineWidth: 1.5)
                )
        )
    }
}

struct GrindChipRail: View {
    let chips: [String]
    let selected: String
    var onSelect: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Grind size")
                .font(.headline)
                .foregroundStyle(BloomkettleTheme.ink)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(chips, id: \.self) { chip in
                        Button {
                            onSelect(chip)
                        } label: {
                            Text(chip.replacingOccurrences(of: "_", with: " "))
                                .font(.caption.weight(.semibold))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(selected == chip ? BloomkettleTheme.accent : BloomkettleTheme.secondary)
                                )
                                .foregroundStyle(selected == chip ? Color.white : BloomkettleTheme.ink)
                                .overlay(
                                    Capsule().stroke(BloomkettleTheme.primary.opacity(0.3), lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("GrindChip-\(chip)")
                    }
                }
            }
        }
    }
}
