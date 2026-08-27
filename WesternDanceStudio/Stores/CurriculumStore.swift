import Foundation

/// Tracks which curriculum modules the user has completed. Mirrors to iCloud
/// via `CloudKeyValueSync` (last-writer-wins by timestamp) so progress
/// follows the user across devices.
@Observable
@MainActor
final class CurriculumStore {
    static let shared = CurriculumStore()

    private(set) var completedModuleIDs: Set<String>

    private enum Keys {
        static let completed = "CurriculumStore.completedModuleIDs"
        static let completedModified = "CurriculumStore.completedModifiedAt"
        static let cloudKey = "sync.CurriculumStore.completedModuleIDs"
    }

    let defaults: UserDefaults
    private let log = AppLog.data
    private var isApplyingRemote = false

    private init() {
        self.defaults = .standard
        let saved = defaults.stringArray(forKey: Keys.completed) ?? []
        completedModuleIDs = Set(saved)
        CloudKeyValueSync.shared.register(key: Keys.cloudKey) { [weak self] data in
            self?.applyRemote(data)
        }
    }

    #if DEBUG
    /// Testing entry point — uses an isolated UserDefaults suite so tests
    /// don't bleed state into the production store or between test runs.
    init(defaults: UserDefaults) {
        self.defaults = defaults
        let saved = defaults.stringArray(forKey: Keys.completed) ?? []
        completedModuleIDs = Set(saved)
        // Skip CloudKeyValueSync registration in test instances.
    }
    #endif

    // MARK: - Mutations

    func toggleComplete(_ module: CurriculumModule) {
        if completedModuleIDs.contains(module.id) {
            completedModuleIDs.remove(module.id)
        } else {
            completedModuleIDs.insert(module.id)
            ReviewManager.shared.recordEngagement()
        }
        persist()
    }

    func markComplete(_ module: CurriculumModule) {
        completedModuleIDs.insert(module.id)
        persist()
    }

    // MARK: - Queries

    func isComplete(_ module: CurriculumModule) -> Bool {
        completedModuleIDs.contains(module.id)
    }

    var completedCount: Int { completedModuleIDs.count }

    var totalCount: Int { CurriculumModule.all.count }

    var completionFraction: Double {
        guard totalCount > 0 else { return 0 }
        return Double(completedCount) / Double(totalCount)
    }

    var nextIncompleteModule: CurriculumModule? {
        CurriculumModule.all.first { !completedModuleIDs.contains($0.id) }
    }

    // MARK: - Persistence

    private var lastModified: Date {
        get { (defaults.object(forKey: Keys.completedModified) as? Date) ?? .distantPast }
        set { defaults.set(newValue, forKey: Keys.completedModified) }
    }

    private func persist() {
        defaults.set(Array(completedModuleIDs), forKey: Keys.completed)
        guard !isApplyingRemote else { return }
        let now = Date()
        lastModified = now
        let envelope = SyncEnvelope(timestamp: now, value: Array(completedModuleIDs))
        guard let payload = try? JSONEncoder().encode(envelope) else {
            log.error("Failed to encode completed-modules envelope for iCloud push")
            return
        }
        CloudKeyValueSync.shared.push(key: Keys.cloudKey, payload: payload)
    }

    private func applyRemote(_ data: Data) {
        guard let envelope = try? JSONDecoder().decode(SyncEnvelope<[String]>.self, from: data) else {
            log.error("Failed to decode remote completed-modules envelope")
            return
        }
        guard CloudKeyValueSync.shouldAdoptRemote(remoteTimestamp: envelope.timestamp, localTimestamp: lastModified) else {
            log.debug("Ignoring remote completed-modules update — local is newer or equal")
            return
        }
        log.info("Adopting remote completed-modules update (\(envelope.value.count, privacy: .public) items)")
        isApplyingRemote = true
        completedModuleIDs = Set(envelope.value)
        lastModified = envelope.timestamp
        persist()
        isApplyingRemote = false
    }
}
