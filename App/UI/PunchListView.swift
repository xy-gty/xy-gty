import SwiftUI

struct PunchListView: View {
    @EnvironmentObject private var model: AppModel
    @Binding var path: NavigationPath

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let audit = model.activeAudit {
                    Text(audit.title).font(.title2.weight(.bold))
                    Text(audit.siteLabel.isEmpty ? "Active audit" : audit.siteLabel)
                        .foregroundStyle(.secondary)
                } else {
                    Text("No active audit")
                        .font(.title3)
                    PrimaryCTA(title: "Start audit", systemImage: "plus.circle.fill") {
                        path.append(SnagRoute.newAudit)
                    }
                }

                if let msg = model.statusMessage {
                    StatusBanner(message: msg)
                }

                if model.activeAudit != nil {
                    HStack(spacing: 10) {
                        navButton("Add photos", icon: "camera.fill", route: .capture)
                        navButton("Review snags", icon: "eye", route: .review)
                    }
                    HStack(spacing: 10) {
                        navButton("Chat fill", icon: "text.bubble", route: .chat)
                        navButton("Annotate", icon: "pencil.and.outline", route: .report)
                    }
                    PrimaryCTA(title: "Read aloud", systemImage: "speaker.wave.2.fill") {
                        path.append(SnagRoute.tts)
                    }
                }

                if model.activePunchItems.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Punch list empty")
                            .font(.headline)
                        Text("Detect snags or add a snag, then Save to grow this list.")
                            .foregroundStyle(.secondary)
                        Button("Add snag") {
                            model.addManualSnag()
                            path.append(SnagRoute.review)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(SnagTheme.panel)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    ForEach(model.activePunchItems) { item in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(item.title).font(.headline)
                            Text("\(item.location.isEmpty ? "Location TBD" : item.location) · \(item.severity)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            if !item.assignee.isEmpty {
                                Text("Assignee: \(item.assignee)").font(.caption)
                            }
                            if !item.notes.isEmpty {
                                Text(item.notes).font(.footnote)
                            }
                            HStack(spacing: 10) {
                                Button {
                                    path.append(SnagRoute.chatForPunch(item.id))
                                } label: {
                                    Label("Ask AI", systemImage: "text.bubble")
                                        .font(.subheadline.weight(.semibold))
                                }
                                .buttonStyle(.bordered)
                                voiceNoteControl(for: item.id)
                            }
                            if VoiceNoteRecorder.isSimulatorLimited {
                                Text("Microphone voice note: 真机待测")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(SnagTheme.panel)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }
            }
            .padding()
        }
        .background(SnagTheme.background.ignoresSafeArea())
        .navigationTitle("Active punch")
    }

    @ViewBuilder
    private func voiceNoteControl(for punchItemId: String) -> some View {
        let recordingThis = model.voiceNoteBusy && model.activeVoiceNotePunchItemId == punchItemId
        if recordingThis {
            Button {
                model.stopVoiceNote()
            } label: {
                Label("Stop", systemImage: "stop.circle.fill")
                    .font(.subheadline.weight(.semibold))
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
        } else {
            Button {
                model.startVoiceNote(punchItemId: punchItemId)
            } label: {
                Label("Voice note", systemImage: "mic.fill")
                    .font(.subheadline.weight(.semibold))
            }
            .buttonStyle(.bordered)
            .disabled(model.voiceNoteBusy)
        }
    }

    private func navButton(_ title: String, icon: String, route: SnagRoute) -> some View {
        Button {
            path.append(route)
        } label: {
            Label(title, systemImage: icon)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        }
        .buttonStyle(.bordered)
    }
}
