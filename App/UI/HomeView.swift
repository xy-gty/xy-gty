import SwiftUI
import BendCoachDomain

struct HomeView: View {
    @EnvironmentObject private var model: AppModel
    @State private var draftAsk = ""

    var body: some View {
        ZStack {
            BendCoachTheme.bg.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 16) {
                Text("BendCoach AI")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(BendCoachTheme.ink)
                    .accessibilityAddTraits(.isHeader)

                HStack {
                    Text(model.unitBadge)
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(BendCoachTheme.surface)
                        .foregroundStyle(BendCoachTheme.cta)
                        .clipShape(Capsule())
                    Spacer()
                    Text(BendCoachIdentity.assistiveDisclaimer)
                        .font(.caption2)
                        .foregroundStyle(BendCoachTheme.warn)
                        .lineLimit(2)
                }

                if model.jobs.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Start a bend job")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(BendCoachTheme.ink)
                        Text("Next: capture a field bend or ask bend math in plain English.")
                            .foregroundStyle(BendCoachTheme.muted)
                        Button { model.startBendJob() } label: {
                            BendCoachTheme.primaryButton("Open coach")
                        }
                        .accessibilityIdentifier("open_coach")
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(BendCoachTheme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                } else {
                    List {
                        ForEach(model.jobs) { job in
                            Button { model.selectJob(job.id) } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(job.title.isEmpty ? "Field bend job" : job.title)
                                        .font(.headline)
                                        .foregroundStyle(BendCoachTheme.ink)
                                    Text(job.updatedAt.formatted(date: .abbreviated, time: .shortened))
                                        .font(.caption)
                                        .foregroundStyle(BendCoachTheme.muted)
                                }
                            }
                            .listRowBackground(BendCoachTheme.surface)
                        }
                    }
                    .scrollContentBackground(.hidden)
                }

                Spacer(minLength: 0)
            }
            .padding()
        }
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 8) {
                if let message = model.statusMessage {
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(BendCoachTheme.ink)
                        .padding(8)
                        .frame(maxWidth: .infinity)
                        .background(BendCoachTheme.surface)
                }
                HStack(spacing: 8) {
                    TextField("Ask bend math…", text: $draftAsk)
                        .textFieldStyle(.plain)
                        .padding(12)
                        .background(BendCoachTheme.surface)
                        .foregroundStyle(BendCoachTheme.ink)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .accessibilityIdentifier("home_ask_field")
                    Button {
                        model.chatText = draftAsk
                        draftAsk = ""
                        model.selectedTab = .job
                        model.sendChat()
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                            .foregroundStyle(BendCoachTheme.cta)
                    }
                    .disabled(draftAsk.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    Button {
                        model.selectedTab = .job
                        model.beginTakePhoto()
                    } label: {
                        Image(systemName: "camera.fill")
                            .foregroundStyle(BendCoachTheme.diagram)
                    }
                    .accessibilityIdentifier("home_capture")
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
            .background(BendCoachTheme.bg.opacity(0.95))
        }
        .navigationDestination(for: CoachRoute.self) { route in
            switch route {
            case .bendMathChat: BendMathChatView()
            case .captureImport: CaptureImportView()
            case .bendReview: BendReviewView()
            case .diagramOverlay: DiagramOverlayView()
            case .ttsCoaching: TTSCoachingView()
            case .units: UnitsSettingsView()
            }
        }
    }
}

struct UnitsIntroSheet: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("How units work in BendCoach")
                    .font(.title2.weight(.bold))
                Text(UnitSystemControl.firstExplanation(for: model.unitPreference.unitSystem))
                    .foregroundStyle(.secondary)
                Picker("Units", selection: Binding(
                    get: { model.unitPreference.unitSystem },
                    set: { model.setUnitSystem($0) }
                )) {
                    Text(UnitSystemControl.imperialBadge).tag(UnitSystem.imperial)
                    Text(UnitSystemControl.metricBadge).tag(UnitSystem.metric)
                }
                .pickerStyle(.segmented)
                Spacer()
                Button { model.dismissUnitsIntro() } label: {
                    BendCoachTheme.primaryButton("Continue")
                }
            }
            .padding()
            .background(BendCoachTheme.bg.ignoresSafeArea())
            .foregroundStyle(BendCoachTheme.ink)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Skip") { model.dismissUnitsIntro() }
                }
            }
        }
    }
}
