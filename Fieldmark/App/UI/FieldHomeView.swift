import PhotosUI
import SwiftUI
import UIKit
import FieldmarkDomain

struct FieldHomeView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Fieldmark")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(FieldmarkTheme.primary)
                Spacer()
                Button {
                    appModel.push(.settings)
                } label: {
                    Image(systemName: "gearshape.fill")
                        .foregroundStyle(FieldmarkTheme.primary)
                }
                .accessibilityLabel("Settings")
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if let banner = appModel.statusMessage {
                        StatusBanner(text: banner, isError: appModel.statusIsError)
                    }
                    if let reason = appModel.aiUnavailableReason {
                        StatusBanner(text: reason, isError: false)
                    }

                    FieldCardStack(candidates: appModel.sessionCandidates, emptyHint: true)
                        .padding(.top, 8)

                    OversizedFieldMarkChips(marks: appModel.sessionMarks)

                    SilhouetteCompareBar(
                        leftKey: appModel.sessionLookalike.map { _ in
                            appModel.sessionCandidates.first?.silhouetteKey ?? "passerine"
                        } ?? "—",
                        rightKey: appModel.sessionCandidates.dropFirst().first?.silhouetteKey ?? "—",
                        contrastNotes: appModel.sessionLookalike?.contrastNotes
                            ?? "Silhouette bar waits for lookalike pair after Identify."
                    )

                    if !appModel.state.sessions.isEmpty {
                        Text("Recent sightings")
                            .font(.headline)
                            .foregroundStyle(FieldmarkTheme.ink)
                        ForEach(appModel.state.sessions.prefix(6), id: \.id) { session in
                            Button {
                                appModel.activeSessionId = session.id
                                appModel.push(.idResult(sessionId: session.id))
                            } label: {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(session.source == "camera" ? "Camera still" : "Album still")
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(FieldmarkTheme.ink)
                                        Text(session.status)
                                            .font(.caption)
                                            .foregroundStyle(FieldmarkTheme.muted)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(FieldmarkTheme.primary)
                                }
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(FieldmarkTheme.cardFace)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(FieldmarkTheme.primary.opacity(0.25), lineWidth: 1)
                                )
                            }
                        }
                    }
                }
                .padding(20)
            }

            coachBar
        }
        .fieldmarkScreen()
        .navigationBarHidden(true)
        .accessibilityIdentifier("FieldHomeView")
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
                }
                .buttonStyle(.borderedProminent)
                .tint(FieldmarkTheme.accent)

                PhotosPicker(selection: $appModel.selectedPhotoItem, matching: .images) {
                    Label("Import", systemImage: "photo.on.rectangle")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.bordered)
                .tint(FieldmarkTheme.primary)
            }

            HStack(spacing: 8) {
                RuntimeFormTextField(
                    title: "Ask coach",
                    text: $appModel.coachQuestion,
                    axis: .horizontal
                )
                Button {
                    appModel.startVoiceNote()
                } label: {
                    Image(systemName: "mic.circle.fill")
                        .font(.title2)
                        .foregroundStyle(FieldmarkTheme.primary)
                }
                .accessibilityLabel("Voice note")

                Button {
                    if appModel.activeSessionId != nil {
                        appModel.push(.lookalikeChat(sessionId: appModel.activeSessionId!))
                    } else {
                        appModel.setBanner("Capture a bird still first.")
                    }
                } label: {
                    Image(systemName: "bubble.left.and.text.bubble.right.fill")
                        .font(.title2)
                        .foregroundStyle(FieldmarkTheme.primary)
                }
                .accessibilityLabel("Lookalike chat")
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(FieldmarkTheme.cardFace.shadow(color: FieldmarkTheme.primary.opacity(0.12), radius: 8, y: -2))
    }
}

/// Thin wrapper so RuntimeForm keyboard Done toolbar is available on the home coach field.
struct RuntimeFormTextField: View {
    let title: String
    @Binding var text: String
    var axis: Axis = .horizontal

    var body: some View {
        TextField(title, text: $text, axis: axis == .horizontal ? .horizontal : .vertical)
            .textFieldStyle(.roundedBorder)
            .runtimeFormKeyboardDone()
    }
}

private extension View {
    func runtimeFormKeyboardDone() -> some View {
        self.modifier(RuntimeFormDoneModifier())
    }
}

private struct RuntimeFormDoneModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.resignFirstResponder),
                        to: nil, from: nil, for: nil
                    )
                }
            }
        }
    }
}
