import SwiftUI
import Observation

/// Central in-memory + UserDefaults-backed store for user preferences.
/// Main-actor-isolated because SwiftUI views read from it on the main thread
/// and `@Observable` mutations must originate on the same actor to avoid
/// inconsistent reads during rendering.
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
    }

    private let defaults = UserDefaults.standard

    private init() {
        loadFavorites()
    }

    private func loadFavorites() {
        if let arr = defaults.array(forKey: Keys.favorites) as? [String] {
            favorites = Set(arr)
        }
    }

    private func saveFavorites() {
        defaults.set(Array(favorites), forKey: Keys.favorites)
    }

    // MARK: - Public API

    func toggleFavorite(_ dance: Dance) {
        if favorites.contains(dance.id) {
            favorites.remove(dance.id)
        } else {
            favorites.insert(dance.id)
        }
        saveFavorites()
    }

    func isFavorite(_ dance: Dance) -> Bool {
        favorites.contains(dance.id)
    }
}
