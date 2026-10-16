import Foundation

/// Isolated with user confirmation, so revoke and synchronous domain writes cannot interleave.
@MainActor
public final class AIConsentGate {
    public struct State: Codable, Equatable, Sendable {
        public var provider: String
        public var disclosureVersion: String
        public var generation: UInt64
        public var granted: Bool
        public init(provider: String, disclosureVersion: String, generation: UInt64 = 0, granted: Bool = false) {
            self.provider = provider; self.disclosureVersion = disclosureVersion
            self.generation = generation; self.granted = granted
        }
    }
    public struct Permit: Equatable, Sendable {
        fileprivate let instance: UUID
        public let provider: String
        public let disclosureVersion: String
        public let generation: UInt64
    }
    public enum Failure: Error { case notAuthorized, stalePermit, generationExhausted }
    public private(set) var state: State
    public private(set) var persistenceError: Error?
    private let instance = UUID()
    private let persist: (State) throws -> Void
    private var inFlight: [UUID: () -> Void] = [:]

    public init(provider: String, disclosureVersion: String,
                load: () throws -> State?, persist: @escaping (State) throws -> Void) {
        self.persist = persist
        let initial = State(provider: provider, disclosureVersion: disclosureVersion)
        do {
            if let restored = try load(), restored.provider == provider,
               restored.disclosureVersion == disclosureVersion { state = restored }
            else { state = initial }
        } catch { state = initial; persistenceError = error }
    }
    private func next(_ granted: Bool) throws -> State {
        guard state.generation < UInt64.max else { throw Failure.generationExhausted }
        return State(provider: state.provider, disclosureVersion: state.disclosureVersion,
                     generation: state.generation + 1, granted: granted)
    }
    public func grant() throws {
        let proposed = try next(true)
        do { try persist(proposed); state = proposed; persistenceError = nil }
        catch {
            state.granted = false
            cancelPending()
            persistenceError = error
            throw error
        }
    }
    /// Revoke in memory before attempting disk, even when disk is unavailable.
    public func revoke() throws {
        state.granted = false
        cancelPending()
        do {
            state = try next(false)
            try persist(state)
            persistenceError = nil
        } catch { persistenceError = error; throw error }
    }
    private func cancelPending() {
        let cancellations = Array(inFlight.values)
        inFlight.removeAll()
        for cancel in cancellations { cancel() }
    }
    public func permit() throws -> Permit {
        guard state.granted, persistenceError == nil else { throw Failure.notAuthorized }
        return Permit(instance: instance, provider: state.provider,
                      disclosureVersion: state.disclosureVersion, generation: state.generation)
    }
    public func validate(_ permit: Permit) throws {
        guard state.granted, persistenceError == nil else { throw Failure.notAuthorized }
        guard permit.instance == instance, permit.provider == state.provider,
              permit.disclosureVersion == state.disclosureVersion,
              permit.generation == state.generation else { throw Failure.stalePermit }
    }
    public func perform<Result: Sendable>(permit: Permit,
                    operation: @escaping @MainActor @Sendable () async throws -> Result) async throws -> Result {
        try validate(permit)
        let id = UUID()
        let task = Task { @MainActor in
            try self.validate(permit)
            try Task.checkCancellation()
            let result = try await operation()
            try self.validate(permit)
            try Task.checkCancellation()
            return result
        }
        inFlight[id] = { task.cancel() }
        defer { inFlight.removeValue(forKey: id) }
        return try await withTaskCancellationHandler(operation: { try await task.value }, onCancel: { task.cancel() })
    }
    /// No await between authorization check and the product's transactional write.
    public func confirm<Result>(permit: Permit, write: () throws -> Result) throws -> Result {
        try validate(permit)
        return try write()
    }
}
