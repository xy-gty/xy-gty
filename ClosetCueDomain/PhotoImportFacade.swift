import Foundation
import AppRuntimeCore

/// PhotoImportSession + CameraCapture wiring: product owns destination bytes under local photos/.
@MainActor
public enum ClosetCuePhotoImportFacade {
    public static let cameraSourceKind = "camera"
    public static let librarySourceKind = "photo_library"

    public static func makeSession(
        storage: ClosetCueStorageRoot,
        fileName: String = UUID().uuidString + ".jpg"
    ) -> (session: PhotoImportSession, destination: URL) {
        let destination = storage.photosDirectory.appendingPathComponent(fileName, isDirectory: false)
        let session = PhotoImportSession(destination: destination)
        return (session, destination)
    }

    public static func recordImportedDraft(
        storage: ClosetCueStorageRoot,
        destination: URL,
        sourceKind: String = "photo_library"
    ) throws -> GarmentDraft {
        let draft = GarmentDraft(
            localFileName: destination.lastPathComponent,
            sourceKind: sourceKind
        )
        var catalog = try storage.garmentDrafts.load() ?? GarmentDraftCatalog()
        catalog.drafts.append(draft)
        try storage.garmentDrafts.save(catalog)
        return draft
    }
}

/// CameraCapture seam: same destination ownership as library import; host AVCapture wiring is Builder's.
@MainActor
public enum CameraCapture {
    public static let sourceKind = ClosetCuePhotoImportFacade.cameraSourceKind

    public static func makeCaptureDestination(
        storage: ClosetCueStorageRoot,
        fileName: String = UUID().uuidString + ".jpg"
    ) -> (session: PhotoImportSession, destination: URL) {
        ClosetCuePhotoImportFacade.makeSession(storage: storage, fileName: fileName)
    }

    public static func recordCapturedDraft(
        storage: ClosetCueStorageRoot,
        destination: URL
    ) throws -> GarmentDraft {
        try ClosetCuePhotoImportFacade.recordImportedDraft(
            storage: storage,
            destination: destination,
            sourceKind: sourceKind
        )
    }
}
