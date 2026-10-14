import SwiftUI
import CuePartnerDomain

struct ScenesHomeView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        ZStack {
            CueTheme.background.ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("CuePartner AI")
                            .font(.largeTitle.weight(.bold))
                            .foregroundStyle(CueTheme.ink)
                        Text("Your scenes shelf")
                            .foregroundStyle(CueTheme.curtain)
                    }
                    Spacer()
                }
                .padding()
                .background(CueTheme.wood.opacity(0.35))

                if model.scenes.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Text("No scenes yet")
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(CueTheme.ink)
                        Text("Start with a scene, then import your own script photo for OCR.")
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 32)
                        Button {
                            model.path = [.newScene]
                            model.persistNavigation()
                        } label: {
                            Text("New scene")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(CueTheme.amber)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        .padding(.horizontal, 40)
                        .accessibilityIdentifier("cta-new-scene")
                    }
                    Spacer()
                } else {
                    List {
                        ForEach(model.scenes, id: \.id) { scene in
                            Button {
                                model.selectScene(scene.id)
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(scene.title)
                                        .font(.headline)
                                        .foregroundStyle(CueTheme.ink)
                                    Text("\(scene.roles.joined(separator: " · ")) · \(AmbienceCatalog.displayName(for: scene.ambienceId))")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("New scene") {
                    model.path = [.newScene]
                    model.persistNavigation()
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            if let msg = model.statusMessage {
                Text(msg)
                    .font(.footnote)
                    .padding(10)
                    .frame(maxWidth: .infinity)
                    .background(CueTheme.curtain.opacity(0.9))
                    .foregroundStyle(.white)
            }
        }
    }
}
