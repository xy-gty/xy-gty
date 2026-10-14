import Foundation
import AppRuntimeCore

/// PhotoImportSession + CameraCapture wiring: product owns destination bytes under local photos/.
@MainActor
public enum KnotCuePhotoImportFacade {
    public static let cameraSourceKind = "camera"
    public static let librarySourceKind = "photo_library"

    public static func makeSession(
        storage: KnotCueStorageRoot,
        fileName: String = UUID().uuidString + ".jpg"
    ) -> (session: PhotoImportSession, destination: URL) {
        let destination = storage.photosDirectory.appendingPathComponent(fileName, isDirectory: false)
        let session = PhotoImportSession(destination: destination)
        return (session, destination)
    }

    public static func recordImportedDraft(
        storage: KnotCueStorageRoot,
        destination: URL,
        practiceSessionID: UUID? = nil,
        sourceKind: String = "photo_library"
    ) throws -> KnotCaptureDraft {
        let draft = KnotCaptureDraft(
            practiceSessionID: practiceSessionID,
            localFileName: destination.lastPathComponent,
            sourceKind: sourceKind
        )
        var catalog = try storage.knotCaptureDrafts.load() ?? KnotCaptureDraftCatalog()
        catalog.drafts.append(draft)
        try storage.knotCaptureDrafts.save(catalog)
        return draft
    }

    public static func confirmDraft(
        storage: KnotCueStorageRoot,
        draft: KnotCaptureDraft,
        stageTags: [String]? = nil,
        wrongHauls: [String]? = nil,
        ropeDiameterMM: Double? = nil
    ) throws -> KnotStage {
        let stage = KnotStage(
            id: draft.id,
            practiceSessionID: draft.practiceSessionID,
            localFileName: draft.localFileName,
            stageTags: stageTags ?? draft.proposedStageTags,
            wrongHauls: wrongHauls ?? draft.proposedWrongHauls,
            ropeDiameterMM: ropeDiameterMM ?? draft.proposedRopeDiameterMM,
            sourceKind: draft.sourceKind,
            includesCoachingDisclaimer: true,
            confirmedAt: Date()
        )
        var stages = try storage.knotStages.load() ?? KnotStageCatalog()
        stages.stages.append(stage)
        try storage.knotStages.save(stages)

        var drafts = try storage.knotCaptureDrafts.load() ?? KnotCaptureDraftCatalog()
        drafts.drafts.removeAll { $0.id == draft.id }
        try storage.knotCaptureDrafts.save(drafts)
        return stage
    }

    public static func saveOverlay(
        storage: KnotCueStorageRoot,
        overlay: StepOverlay,
        localFileName: String? = nil,
        annotationNotes: [String]? = nil
    ) throws -> StepOverlay {
        var saved = overlay
        if let localFileName { saved.localFileName = localFileName }
        if let annotationNotes { saved.annotationNotes = annotationNotes }
        saved.status = "saved"
        saved.savedAt = Date()

        var catalog = try storage.stepOverlays.load() ?? StepOverlayCatalog()
        if let idx = catalog.overlays.firstIndex(where: { $0.id == saved.id }) {
            catalog.overlays[idx] = saved
        } else {
            catalog.overlays.append(saved)
        }
        try storage.stepOverlays.save(catalog)
        return saved
    }

    public static func discardOverlay(
        storage: KnotCueStorageRoot,
        overlayID: UUID
    ) throws {
        var catalog = try storage.stepOverlays.load() ?? StepOverlayCatalog()
        catalog.overlays.removeAll { $0.id == overlayID }
        try storage.stepOverlays.save(catalog)
    }
}

/// CameraCapture seam: same destination ownership as library import; host AVCapture wiring is Builder's.
@MainActor
public enum CameraCapture {
    public static let sourceKind = KnotCuePhotoImportFacade.cameraSourceKind

    public static func makeCaptureDestination(
        storage: KnotCueStorageRoot,
        fileName: String = UUID().uuidString + ".jpg"
    ) -> (session: PhotoImportSession, destination: URL) {
        KnotCuePhotoImportFacade.makeSession(storage: storage, fileName: fileName)
    }

    public static func recordCapturedDraft(
        storage: KnotCueStorageRoot,
        destination: URL,
        practiceSessionID: UUID? = nil
    ) throws -> KnotCaptureDraft {
        try KnotCuePhotoImportFacade.recordImportedDraft(
            storage: storage,
            destination: destination,
            practiceSessionID: practiceSessionID,
            sourceKind: sourceKind
        )
    }
}
