import Foundation
import AppRuntimeCore

/// PhotoImportSession + CameraCapture wiring: product owns destination bytes under local photos/.
@MainActor
public enum BendCoachPhotoImportFacade {
    public static let cameraSourceKind = "camera"
    public static let librarySourceKind = "photo_library"

    public static func makeSession(
        storage: BendCoachStorageRoot,
        fileName: String = UUID().uuidString + ".jpg"
    ) -> (session: PhotoImportSession, destination: URL) {
        let destination = storage.photosDirectory.appendingPathComponent(fileName, isDirectory: false)
        let session = PhotoImportSession(destination: destination)
        return (session, destination)
    }

    public static func recordImportedPhoto(
        storage: BendCoachStorageRoot,
        jobSessionID: UUID,
        destination: URL,
        sourceKind: String = "photo_library"
    ) throws -> FieldPhoto {
        let photo = FieldPhoto(
            jobSessionID: jobSessionID,
            localFileName: destination.lastPathComponent,
            sourceKind: sourceKind
        )
        var catalog = try storage.photos.load() ?? FieldPhotoCatalog()
        catalog.photos.append(photo)
        try storage.photos.save(catalog)
        return photo
    }
}
