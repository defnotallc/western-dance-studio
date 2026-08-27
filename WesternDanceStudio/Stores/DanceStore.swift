import SwiftUI
import Observation

/// Central in-memory + UserDefaults-backed store for user preferences.
/// Main-actor-isolated because SwiftUI views read from it on the main thread
/// and `@Observable` mutations must originate on the same actor to avoid
/// inconsistent reads during rendering.
///
/// Favorites also mirror to iCloud via `CloudKeyValueSync` (last-writer-wins
/// by timestamp) so they follow the user across devices.
@Observable
@MainActor
final class DanceStore {
    static let shared = DanceStore()

    // MARK: - Observable state

    /// Set of favorite dance IDs. Persisted across launches.
    var favorites: Set<String> = []

    // MARK: - Persistence

    private enum Keys {
        static let favorites = "DanceStore.favorites"
        static let favoritesModified = "DanceStore.favoritesModifiedAt"
        static let cloudKey = "sync.DanceStore.favorites"
    }

    let defaults: UserDefaults
    private let log = AppLog.data

    /// Set while applying a remote update, so the resulting `saveFavorites()`
    /// doesn't immediately push the just-received value back to iCloud.
    private var isApplyingRemote = false

    private init() {
        self.defaults = .standard
        loadFavorites()
        CloudKeyValueSync.shared.register(key: Keys.cloudKey) { [weak self] data in
            self?.applyRemote(data)
        }
    }

    #if DEBUG
    /// Testing entry point — uses an isolated UserDefaults suite so tests
    /// don't bleed state into the production store or between test runs.
    init(defaults: UserDefaults) {
        self.defaults = defaults
        loadFavorites()
        // Skip CloudKeyValueSync registration in test instances;
        // iCloud sync is not available in unit-test processes.
    }
    #endif

    private func loadFavorites() {
        if let arr = defaults.array(forKey: Keys.favorites) as? [String] {
            favorites = Set(arr)
        }
    }

    private var lastModified: Date {
        get { (defaults.object(forKey: Keys.favoritesModified) as? Date) ?? .distantPast }
        set { defaults.set(newValue, forKey: Keys.favoritesModified) }
    }

    private func saveFavorites() {
        defaults.set(Array(favorites), forKey: Keys.favorites)
        guard !isApplyingRemote else { return }
        let now = Date()
        lastModified = now
        let envelope = SyncEnvelope(timestamp: now, value: Array(favorites))
        guard let payload = try? JSONEncoder().encode(envelope) else {
            log.error("Failed to encode favorites envelope for iCloud push")
            return
        }
        CloudKeyValueSync.shared.push(key: Keys.cloudKey, payload: payload)
    }

    /// Applies a remote envelope if it's newer than the last local write.
    /// Last-writer-wins is correct here because favorites are current toggle
    /// state, not an append-only log — a stale device pushing its old set
    /// must not resurrect items the newer device already removed.
    private func applyRemote(_ data: Data) {
        guard let envelope = try? JSONDecoder().decode(SyncEnvelope<[String]>.self, from: data) else {
            log.error("Failed to decode remote favorites envelope")
            return
        }
        guard CloudKeyValueSync.shouldAdoptRemote(remoteTimestamp: envelope.timestamp, localTimestamp: lastModified) else {
            log.debug("Ignoring remote favorites update — local is newer or equal")
            return
        }
        log.info("Adopting remote favorites update (\(envelope.value.count, privacy: .public) items)")
        isApplyingRemote = true
        favorites = Set(envelope.value)
        lastModified = envelope.timestamp
        saveFavorites()
        isApplyingRemote = false
    }

    // MARK: - Public API

    func toggleFavorite(_ dance: Dance) {
        if favorites.contains(dance.id) {
            favorites.remove(dance.id)
        } else {
            favorites.insert(dance.id)
            ReviewManager.shared.recordEngagement()
        }
        saveFavorites()
    }

    func isFavorite(_ dance: Dance) -> Bool {
        favorites.contains(dance.id)
    }
}
