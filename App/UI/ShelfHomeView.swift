import PhotosUI
import SwiftUI
import FolioCueDomain

struct ShelfHomeView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("FolioCue")
                    .font(.system(size: 24, weight: .bold, design: .serif))
                    .foregroundStyle(FolioCueTheme.primary)
                Spacer()
                Button {
                    appModel.push(.settings)
                } label: {
                    Image(systemName: "gearshape.fill")
                        .foregroundStyle(FolioCueTheme.primary)
                }
                .accessibilityLabel("Settings")
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    ComplianceRibbon()

                    if let banner = appModel.statusMessage {
                        StatusBanner(text: banner, isError: appModel.statusIsError)
                    }
                    if let reason = appModel.aiUnavailableReason {
                        StatusBanner(text: reason, isError: false)
                    }

                    SpineRailView(items: appModel.state.spineRail) { item in
                        appModel.selectSpineItem(item)
                    }

                    CoverOCRCardView(
                        title: appModel.activeBookID?.title ?? "",
                        author: appModel.activeBookID?.author ?? "",
                        rationale: appModel.activeBookID?.rationale ?? "",
                        confidence: appModel.activeBookID?.confidence,
                        pending: appModel.activeBookID == nil,
                        onIdentify: appModel.activeSession == nil ? nil : { appModel.requestIdentify() }
                    )

                    ReadingProgressBarView(progress: appModel.activeProgress)

                    if !appModel.state.sessions.isEmpty {
                        Text("Recent shelf sessions")
                            .font(.headline)
                            .foregroundStyle(FolioCueTheme.ink)
                        ForEach(appModel.state.sessions.prefix(6), id: \.id) { session in
                            let kind = appModel.state.captures.first(where: { $0.sessionId == session.id })?.captureKind ?? "cover"
                            Button {
                                appModel.activeSessionId = session.id
                                appModel.push(.bookIdResult)
                            } label: {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("\(session.source) · \(kind)")
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(FolioCueTheme.ink)
                                        Text(session.status)
                                            .font(.caption)
                                            .foregroundStyle(FolioCueTheme.muted)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(FolioCueTheme.primary)
                                }
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(FolioCueTheme.cardFace)
                                )
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("SessionRow-\(session.id)")
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 120)
            }

            coachBar
        }
        .folioCueScreen()
        .navigationBarHidden(true)
        .accessibilityIdentifier("ShelfHome")
    }

    private var coachBar: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                Button {
                    appModel.showCamera = true
                } label: {
                    Label("Snap", systemImage: "camera.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(FolioCueTheme.primary)
                .accessibilityIdentifier("SnapButton")

                PhotosPicker(selection: $appModel.selectedPhotoItem, matching: .images) {
                    Label("Import", systemImage: "photo.on.rectangle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(FolioCueTheme.accent)
                .accessibilityIdentifier("ImportButton")
            }

            HStack(spacing: 10) {
                Button {
                    appModel.showVoiceNote = true
                } label: {
                    Label("Mic note", systemImage: "mic.fill")
                }
                .buttonStyle(.bordered)

                Button {
                    if appModel.activeSession != nil {
                        appModel.push(.coachChat)
                    } else {
                        appModel.setBanner("Capture a cover first.", error: true)
                    }
                } label: {
                    Label("Coach", systemImage: "bubble.left.and.bubble.right.fill")
                }
                .buttonStyle(.borderedProminent)
                .tint(FolioCueTheme.accent)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }
}
