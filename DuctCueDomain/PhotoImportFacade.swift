import Foundation
import AppRuntimeCore

/// PhotoImportSession + CameraCapture wiring: product owns destination bytes under local photos/.
@MainActor
public enum DuctCuePhotoImportFacade {
    public static let cameraSourceKind = "camera"
    public static let librarySourceKind = "photo_library"

    public static func makeSession(
        storage: DuctCueStorageRoot,
        fileName: String = UUID().uuidString + ".jpg"
    ) -> (session: PhotoImportSession, destination: URL) {
        let destination = storage.photosDirectory.appendingPathComponent(fileName, isDirectory: false)
        let session = PhotoImportSession(destination: destination)
        return (session, destination)
    }

    public static func recordImportedDraft(
        storage: DuctCueStorageRoot,
        destination: URL,
        jobSiteID: UUID? = nil,
        sourceKind: String = "photo_library"
    ) throws -> DuctRunDraft {
        let draft = DuctRunDraft(
            jobSiteID: jobSiteID,
            localFileName: destination.lastPathComponent,
            sourceKind: sourceKind
        )
        var catalog = try storage.ductRunDrafts.load() ?? DuctRunDraftCatalog()
        catalog.drafts.append(draft)
        try storage.ductRunDrafts.save(catalog)
        return draft
    }

    public static func confirmDraft(
        storage: DuctCueStorageRoot,
        draft: DuctRunDraft,
        sizeTags: [String]? = nil,
        diameterInches: Double? = nil,
        lengthFeet: Double? = nil
    ) throws -> DuctRun {
        let run = DuctRun(
            id: draft.id,
            jobSiteID: draft.jobSiteID,
            localFileName: draft.localFileName,
            sizeTags: sizeTags ?? draft.proposedSizeTags,
            diameterInches: diameterInches ?? draft.proposedDiameterInches,
            lengthFeet: lengthFeet ?? draft.proposedLengthFeet,
            sourceKind: draft.sourceKind,
            confirmedAt: Date()
        )
        var runs = try storage.ductRuns.load() ?? DuctRunCatalog()
        runs.runs.append(run)
        try storage.ductRuns.save(runs)

        var drafts = try storage.ductRunDrafts.load() ?? DuctRunDraftCatalog()
        drafts.drafts.removeAll { $0.id == draft.id }
        try storage.ductRunDrafts.save(drafts)
        return run
    }
}

/// CameraCapture seam: same destination ownership as library import; host AVCapture wiring is Builder's.
@MainActor
public enum CameraCapture {
    public static let sourceKind = DuctCuePhotoImportFacade.cameraSourceKind

    public static func makeCaptureDestination(
        storage: DuctCueStorageRoot,
        fileName: String = UUID().uuidString + ".jpg"
    ) -> (session: PhotoImportSession, destination: URL) {
        DuctCuePhotoImportFacade.makeSession(storage: storage, fileName: fileName)
    }

    public static func recordCapturedDraft(
        storage: DuctCueStorageRoot,
        destination: URL,
        jobSiteID: UUID? = nil
    ) throws -> DuctRunDraft {
        try DuctCuePhotoImportFacade.recordImportedDraft(
            storage: storage,
            destination: destination,
            jobSiteID: jobSiteID,
            sourceKind: sourceKind
        )
    }
}
