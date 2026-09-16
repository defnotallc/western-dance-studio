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

    /// Favorite dance IDs in user-facing order. Newly favorited dances append
    /// to the end; the Favorites screen lets the user reorder them directly.
    /// Order is the persisted and synced representation.
    private(set) var favoriteOrder: [String] = []

    /// Membership view over `favoriteOrder`. Kept as a `Set` because every
    /// caller uses it for `contains`, and it reads through to the stored
    /// array so `@Observable` still tracks changes.
    var favorites: Set<String> { Set(favoriteOrder) }

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
            // Existing installs already persisted an array, so stored data is
            // read back as-is. Dedupe defensively — a Set-era write could not
            // contain duplicates, but a corrupted or hand-edited value could.
            favoriteOrder = Self.deduped(arr)
        }
    }

    /// Removes duplicates while preserving first-seen order.
    static func deduped(_ ids: [String]) -> [String] {
        var seen = Set<String>()
        return ids.filter { seen.insert($0).inserted }
    }

    private var lastModified: Date {
        get { (defaults.object(forKey: Keys.favoritesModified) as? Date) ?? .distantPast }
        set { defaults.set(newValue, forKey: Keys.favoritesModified) }
    }

    private func saveFavorites() {
        defaults.set(favoriteOrder, forKey: Keys.favorites)
        guard !isApplyingRemote else { return }
        let now = Date()
        lastModified = now
        let envelope = SyncEnvelope(timestamp: now, value: favoriteOrder)
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
        favoriteOrder = Self.deduped(envelope.value)
        lastModified = envelope.timestamp
        saveFavorites()
        isApplyingRemote = false
    }

    // MARK: - Public API

    func toggleFavorite(_ dance: Dance) {
        if let index = favoriteOrder.firstIndex(of: dance.id) {
            favoriteOrder.remove(at: index)
        } else {
            favoriteOrder.append(dance.id)
            ReviewManager.shared.recordEngagement()
        }
        saveFavorites()
    }

    func isFavorite(_ dance: Dance) -> Bool {
        favoriteOrder.contains(dance.id)
    }

    // MARK: - Reordering

    /// Applies a reorder produced by SwiftUI's reorder container.
    func applyReorder(sources: [String], before beforeID: String?) {
        let updated = Self.reordering(favoriteOrder, moving: sources, before: beforeID)
        guard updated != favoriteOrder else { return }
        favoriteOrder = updated
        saveFavorites()
    }

    /// Moves `sources` so they sit immediately before `beforeID`, or at the end
    /// when `beforeID` is nil, preserving the moved items' relative order.
    ///
    /// Pure and `static` so the reorder math is unit-testable without SwiftUI.
    /// `SwiftUI.ReorderDifference` carries only `sources` and a destination
    /// position — it has no apply-to-collection helper — so this is where the
    /// move is actually performed.
    static func reordering(_ order: [String], moving sources: [String], before beforeID: String?) -> [String] {
        let movingSet = Set(sources.filter(order.contains))
        guard !movingSet.isEmpty else { return order }
        // A destination anchored to a moved item is not a well-defined move.
        if let beforeID, movingSet.contains(beforeID) { return order }

        let moved = order.filter(movingSet.contains)
        var remainder = order.filter { !movingSet.contains($0) }
        let insertionIndex = beforeID.flatMap(remainder.firstIndex(of:)) ?? remainder.count
        remainder.insert(contentsOf: moved, at: insertionIndex)
        return remainder
    }
}
