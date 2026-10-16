import Foundation
import AppRuntimeCore

/// Caller-owned AtomicCodableStore facades for frozen entities. Ordinary saves never replace corrupt bytes.
public final class HemlineStorageRoot: @unchecked Sendable {
    public let rootDirectory: URL
    public let closetItems: AtomicCodableStore<ClosetItemCatalog>
    public let garmentDrafts: AtomicCodableStore<GarmentDraftCatalog>
    public let outfitPlans: AtomicCodableStore<OutfitPlanCatalog>
    public let flatLayBoards: AtomicCodableStore<FlatLayBoardCatalog>
    public let morningBriefings: AtomicCodableStore<MorningBriefingCatalog>
    public let weatherOccasions: AtomicCodableStore<WeatherOccasionCatalog>
    public let consentLocal: AtomicCodableStore<AIConsentRecord>

    public init(rootDirectory: URL) {
        self.rootDirectory = rootDirectory
        let domain = rootDirectory.appendingPathComponent("domain", isDirectory: true)
        self.closetItems = AtomicCodableStore(url: domain.appendingPathComponent("closet-items.json"))
        self.garmentDrafts = AtomicCodableStore(url: domain.appendingPathComponent("garment-drafts.json"))
        self.outfitPlans = AtomicCodableStore(url: domain.appendingPathComponent("outfit-plans.json"))
        self.flatLayBoards = AtomicCodableStore(url: domain.appendingPathComponent("flat-lay-boards.json"))
        self.morningBriefings = AtomicCodableStore(url: domain.appendingPathComponent("morning-briefings.json"))
        self.weatherOccasions = AtomicCodableStore(url: domain.appendingPathComponent("weather-occasions.json"))
        self.consentLocal = AtomicCodableStore(url: domain.appendingPathComponent("ai-consent.json"))
    }

    public var photosDirectory: URL {
        rootDirectory.appendingPathComponent("photos", isDirectory: true)
    }

    public var boardsDirectory: URL {
        rootDirectory.appendingPathComponent("boards", isDirectory: true)
    }

    public func photoFileURL(for item: ClosetItem) -> URL {
        photosDirectory.appendingPathComponent(item.localFileName, isDirectory: false)
    }

    public func photoFileURL(for draft: GarmentDraft) -> URL {
        photosDirectory.appendingPathComponent(draft.localFileName, isDirectory: false)
    }

    public func boardFileURL(for board: FlatLayBoard) -> URL {
        boardsDirectory.appendingPathComponent(board.localFileName, isDirectory: false)
    }
}
