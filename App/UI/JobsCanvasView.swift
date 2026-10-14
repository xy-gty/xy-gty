import SwiftUI
import DuctCueDomain

struct JobsCanvasView: View {
    @EnvironmentObject private var model: AppModel
    @State private var highlightedChip: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                IsometricDuctCanvas(accentChip: highlightedChip ?? model.sizeChips.first)
                cfmSection
                sizeChipsRow
                if model.ductRuns.isEmpty {
                    emptyActions
                } else {
                    runsList
                }
                fieldStepsShortcut
            }
            .padding()
        }
        .background(DuctCueTheme.secondary.ignoresSafeArea())
        .navigationTitle("Jobs")
        .navigationBarTitleDisplayMode(.large)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(DuctCueIdentity.appName)
                .font(.largeTitle.bold())
                .foregroundStyle(DuctCueTheme.primary)
            Text("Isometric duct canvas · CFM knob · size chips")
                .font(.subheadline)
                .foregroundStyle(DuctCueTheme.ink.opacity(0.75))
        }
    }

    private var cfmSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("CFM knob")
                    .font(.headline)
                    .foregroundStyle(DuctCueTheme.ink)
                Spacer()
                Text("\(Int(model.cfmKnob)) CFM")
                    .font(.title3.monospacedDigit().weight(.semibold))
                    .foregroundStyle(DuctCueTheme.accent)
            }
            Slider(value: $model.cfmKnob, in: 100...2000, step: 10)
                .tint(DuctCueTheme.primary)
        }
        .padding()
        .background(DuctCueTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var sizeChipsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(model.sizeChips, id: \.self) { chip in
                    Button(chip) { highlightedChip = chip }
                        .buttonStyle(DuctCueTheme.AccentChipStyle(selected: highlightedChip == chip))
                }
            }
        }
    }

    private var emptyActions: some View {
        VStack(spacing: 12) {
            Button("Add job photo") {
                model.push(.jobCapture)
            }
            .buttonStyle(DuctCueTheme.PrimaryButtonStyle())
            .accessibilityIdentifier("add_job_photo")

            Button("Ask coach") {
                model.selectedTab = .coach
            }
            .buttonStyle(DuctCueTheme.SecondaryButtonStyle())
        }
    }

    private var runsList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Confirmed duct runs")
                .font(.headline)
                .foregroundStyle(DuctCueTheme.ink)
            ForEach(model.ductRuns) { run in
                Button {
                    model.selectedRunID = run.id
                    model.push(.ductRunDetail)
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(run.sizeTags.joined(separator: ", "))
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(DuctCueTheme.ink)
                            if let feet = run.lengthFeet {
                                Text("\(feet, specifier: "%.0f") ft · \(run.sourceKind.replacingOccurrences(of: "_", with: " "))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(DuctCueTheme.primary)
                    }
                    .padding()
                    .background(DuctCueTheme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)
            }

            Button("Add job photo") {
                model.push(.jobCapture)
            }
            .buttonStyle(DuctCueTheme.PrimaryButtonStyle())
            .accessibilityIdentifier("add_job_photo")
        }
    }

    private var fieldStepsShortcut: some View {
        Button("Field steps") {
            model.openFieldSteps(run: model.selectedRun)
        }
        .buttonStyle(DuctCueTheme.SecondaryButtonStyle())
    }
}
