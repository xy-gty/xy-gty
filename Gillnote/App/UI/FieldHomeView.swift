import PhotosUI
import SwiftUI
import GillnoteDomain

struct FieldHomeView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Gillnote")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(GillnoteTheme.primary)
                Spacer()
                Button {
                    appModel.push(.settings)
                } label: {
                    Image(systemName: "gearshape.fill")
                        .foregroundStyle(GillnoteTheme.primary)
                }
                .accessibilityLabel("Settings")
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    DisclaimerBanner()

                    if let banner = appModel.statusMessage {
                        StatusBanner(text: banner, isError: appModel.statusIsError)
                    }
                    if let reason = appModel.aiUnavailableReason {
                        StatusBanner(text: reason, isError: false)
                    }

                    subjectPicker

                    SpeciesConfidenceStackView(
                        candidates: appModel.sessionCandidates,
                        emptyHint: true
                    )

                    GillPoreCloseupBarView(
                        subject: appModel.activeSession?.subject ?? appModel.captureSubject,
                        callouts: appModel.sessionCallouts,
                        photoPath: appModel.activeSession?.photoLocalURL,
                        onAnnotate: appModel.activeSession == nil ? nil : { appModel.openOverlay() }
                    )

                    CautionChipRailView(chips: appModel.sessionChips)

                    if !appModel.state.sessions.isEmpty {
                        Text("Recent finds")
                            .font(.headline)
                            .foregroundStyle(GillnoteTheme.ink)
                        ForEach(appModel.state.sessions.prefix(6), id: \.id) { session in
                            Button {
                                appModel.activeSessionId = session.id
                                appModel.push(.idResult)
                            } label: {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(session.subject.capitalized + " · " + session.source)
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(GillnoteTheme.ink)
                                        Text(session.status)
                                            .font(.caption)
                                            .foregroundStyle(GillnoteTheme.muted)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(GillnoteTheme.accent)
                                }
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(GillnoteTheme.stackSlot)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 130)
            }

            coachBar
        }
        .sporeScreen()
        .navigationBarHidden(true)
        .accessibilityIdentifier("FieldHome")
    }

    private var subjectPicker: some View {
        HStack(spacing: 8) {
            ForEach(["cap", "gill", "pore"], id: \.self) { subject in
                Button {
                    appModel.captureSubject = subject
                } label: {
                    Text(subject.capitalized)
                        .font(.subheadline.weight(.semibold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            Capsule().fill(
                                appModel.captureSubject == subject
                                    ? GillnoteTheme.accent
                                    : GillnoteTheme.barFace
                            )
                        )
                        .foregroundStyle(
                            appModel.captureSubject == subject
                                ? Color.white
                                : GillnoteTheme.primary
                        )
                }
                .buttonStyle(.plain)
            }
            Spacer()
        }
        .accessibilityIdentifier("SubjectPicker")
    }

    private var coachBar: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                Button {
                    appModel.showCamera = true
                } label: {
                    Label("Shoot", systemImage: "camera.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(RoundedRectangle(cornerRadius: 16).fill(GillnoteTheme.accent))
                        .foregroundStyle(.white)
                }
                .accessibilityIdentifier("ShootButton")

                PhotosPicker(selection: $appModel.selectedPhotoItem, matching: .images) {
                    Label("Import", systemImage: "photo.on.rectangle")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(GillnoteTheme.primary, lineWidth: 2)
                        )
                        .foregroundStyle(GillnoteTheme.primary)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel("Import")
                .accessibilityIdentifier("ImportButton")
            }

            HStack(spacing: 8) {
                TextField("Ask habitat / lookalike…", text: $appModel.coachQuestion)
                    .textFieldStyle(.roundedBorder)
                    .submitLabel(.send)
                    .onSubmit { appModel.sendCoachQuestion() }

                Button {
                    if appModel.speechService.isListening {
                        appModel.finishSpeechQuestion()
                    } else {
                        appModel.startSpeechQuestion()
                    }
                } label: {
                    Image(systemName: appModel.speechService.isListening ? "stop.circle.fill" : "mic.circle.fill")
                        .font(.title2)
                        .foregroundStyle(GillnoteTheme.accent)
                }
                .accessibilityLabel("Speech question")

                Button {
                    appModel.showVoiceNote = true
                } label: {
                    Image(systemName: "waveform.circle.fill")
                        .font(.title2)
                        .foregroundStyle(GillnoteTheme.primary)
                }
                .accessibilityLabel("Voice note")
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(GillnoteTheme.barFace.ignoresSafeArea(edges: .bottom))
    }
}
