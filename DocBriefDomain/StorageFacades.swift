import Foundation
import AppRuntimeCore

/// Caller-owned AtomicCodableStore facades for frozen entities. Ordinary saves never replace corrupt bytes.
public final class DocBriefStorageRoot: @unchecked Sendable {
    public let rootDirectory: URL
    public let briefs: AtomicCodableStore<BriefCatalog>
    public let photos: AtomicCodableStore<DocumentPhotoCatalog>
    public let fields: AtomicCodableStore<ExtractedFieldCatalog>
    public let recognitionDrafts: AtomicCodableStore<RecognitionDraftCatalog>
    public let actionItems: AtomicCodableStore<ActionItemCatalog>
    public let summaryCards: AtomicCodableStore<SummaryCardDraftCatalog>
    public let consentLocal: AtomicCodableStore<AIConsentRecord>

    public init(rootDirectory: URL) {
        self.rootDirectory = rootDirectory
        let domain = rootDirectory.appendingPathComponent("domain", isDirectory: true)
        self.briefs = AtomicCodableStore(url: domain.appendingPathComponent("briefs.json"))
        self.photos = AtomicCodableStore(url: domain.appendingPathComponent("document-photos.json"))
        self.fields = AtomicCodableStore(url: domain.appendingPathComponent("extracted-fields.json"))
        self.recognitionDrafts = AtomicCodableStore(url: domain.appendingPathComponent("recognition-drafts.json"))
        self.actionItems = AtomicCodableStore(url: domain.appendingPathComponent("action-items.json"))
        self.summaryCards = AtomicCodableStore(url: domain.appendingPathComponent("summary-card-drafts.json"))
        self.consentLocal = AtomicCodableStore(url: domain.appendingPathComponent("ai-consent.json"))
    }

    public var photosDirectory: URL {
        rootDirectory.appendingPathComponent("photos", isDirectory: true)
    }

    public func photoFileURL(for photo: DocumentPhoto) -> URL {
        photosDirectory.appendingPathComponent(photo.localFileName, isDirectory: false)
    }
}
