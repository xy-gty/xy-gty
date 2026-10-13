import Foundation
import AppRuntimeCore

/// PhotoImportSession wiring: product owns destination bytes under local photos/.
@MainActor
public enum DocBriefPhotoImportFacade {
    public static func makeSession(
        storage: DocBriefStorageRoot,
        fileName: String = UUID().uuidString + ".jpg"
    ) -> (session: PhotoImportSession, destination: URL) {
        let destination = storage.photosDirectory.appendingPathComponent(fileName, isDirectory: false)
        let session = PhotoImportSession(destination: destination)
        return (session, destination)
    }

    public static func recordImportedPhoto(
        storage: DocBriefStorageRoot,
        briefID: UUID,
        destination: URL,
        sourceKind: String = "photo_library"
    ) throws -> DocumentPhoto {
        let photo = DocumentPhoto(
            briefID: briefID,
            localFileName: destination.lastPathComponent,
            sourceKind: sourceKind
        )
        var catalog = try storage.photos.load() ?? DocumentPhotoCatalog()
        catalog.photos.append(photo)
        try storage.photos.save(catalog)
        return photo
    }
}
