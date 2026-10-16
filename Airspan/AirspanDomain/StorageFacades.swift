import Foundation
import AppRuntimeCore

/// Caller-owned AtomicCodableStore facades for frozen entities. Ordinary saves never replace corrupt bytes.
public final class AirspanStorageRoot: @unchecked Sendable {
    public let rootDirectory: URL
    public let jobSites: AtomicCodableStore<JobSiteCatalog>
    public let ductRunDrafts: AtomicCodableStore<DuctRunDraftCatalog>
    public let ductRuns: AtomicCodableStore<DuctRunCatalog>
    public let sizingSessions: AtomicCodableStore<SizingSessionCatalog>
    public let sizeDiagrams: AtomicCodableStore<SizeDiagramCatalog>
    public let fieldStepPlans: AtomicCodableStore<FieldStepPlanCatalog>
    public let consentLocal: AtomicCodableStore<AIConsentRecord>

    public init(rootDirectory: URL) {
        self.rootDirectory = rootDirectory
        let domain = rootDirectory.appendingPathComponent("domain", isDirectory: true)
        self.jobSites = AtomicCodableStore(url: domain.appendingPathComponent("job-sites.json"))
        self.ductRunDrafts = AtomicCodableStore(url: domain.appendingPathComponent("duct-run-drafts.json"))
        self.ductRuns = AtomicCodableStore(url: domain.appendingPathComponent("duct-runs.json"))
        self.sizingSessions = AtomicCodableStore(url: domain.appendingPathComponent("sizing-sessions.json"))
        self.sizeDiagrams = AtomicCodableStore(url: domain.appendingPathComponent("size-diagrams.json"))
        self.fieldStepPlans = AtomicCodableStore(url: domain.appendingPathComponent("field-step-plans.json"))
        self.consentLocal = AtomicCodableStore(url: domain.appendingPathComponent("ai-consent.json"))
    }

    public var photosDirectory: URL {
        rootDirectory.appendingPathComponent("photos", isDirectory: true)
    }

    public var diagramsDirectory: URL {
        rootDirectory.appendingPathComponent("diagrams", isDirectory: true)
    }

    public func photoFileURL(for draft: DuctRunDraft) -> URL {
        photosDirectory.appendingPathComponent(draft.localFileName, isDirectory: false)
    }

    public func photoFileURL(for run: DuctRun) -> URL {
        photosDirectory.appendingPathComponent(run.localFileName, isDirectory: false)
    }

    public func diagramFileURL(for diagram: SizeDiagram) -> URL {
        diagramsDirectory.appendingPathComponent(diagram.localFileName, isDirectory: false)
    }
}
