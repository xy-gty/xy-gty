import Foundation
import AppRuntimeCore

/// Caller-owned AtomicCodableStore facades for frozen entities. Ordinary saves never replace corrupt bytes.
public final class KnotCueStorageRoot: @unchecked Sendable {
    public let rootDirectory: URL
    public let practiceSessions: AtomicCodableStore<PracticeSessionCatalog>
    public let knotCaptureDrafts: AtomicCodableStore<KnotCaptureDraftCatalog>
    public let knotStages: AtomicCodableStore<KnotStageCatalog>
    public let coachTurns: AtomicCodableStore<CoachTurnCatalog>
    public let stepOverlays: AtomicCodableStore<StepOverlayCatalog>
    public let handsFreePlans: AtomicCodableStore<HandsFreePlanCatalog>
    public let consentLocal: AtomicCodableStore<AIConsentRecord>

    public init(rootDirectory: URL) {
        self.rootDirectory = rootDirectory
        let domain = rootDirectory.appendingPathComponent("domain", isDirectory: true)
        self.practiceSessions = AtomicCodableStore(url: domain.appendingPathComponent("practice-sessions.json"))
        self.knotCaptureDrafts = AtomicCodableStore(url: domain.appendingPathComponent("knot-capture-drafts.json"))
        self.knotStages = AtomicCodableStore(url: domain.appendingPathComponent("knot-stages.json"))
        self.coachTurns = AtomicCodableStore(url: domain.appendingPathComponent("coach-turns.json"))
        self.stepOverlays = AtomicCodableStore(url: domain.appendingPathComponent("step-overlays.json"))
        self.handsFreePlans = AtomicCodableStore(url: domain.appendingPathComponent("hands-free-plans.json"))
        self.consentLocal = AtomicCodableStore(url: domain.appendingPathComponent("ai-consent.json"))
    }

    public var photosDirectory: URL {
        rootDirectory.appendingPathComponent("photos", isDirectory: true)
    }

    public var overlaysDirectory: URL {
        rootDirectory.appendingPathComponent("overlays", isDirectory: true)
    }

    public func photoFileURL(for draft: KnotCaptureDraft) -> URL {
        photosDirectory.appendingPathComponent(draft.localFileName, isDirectory: false)
    }

    public func photoFileURL(for stage: KnotStage) -> URL {
        photosDirectory.appendingPathComponent(stage.localFileName, isDirectory: false)
    }

    public func overlayFileURL(for overlay: StepOverlay) -> URL {
        overlaysDirectory.appendingPathComponent(overlay.localFileName, isDirectory: false)
    }
}
