import XCTest
@testable import Western_Dance_Studio

@MainActor
final class DanceStoreTests: XCTestCase {
    private var store: DanceStore!
    private var defaults: UserDefaults!
    private var suiteName: String!

    override func setUp() async throws {
        try await super.setUp()
        suiteName = "DanceStoreTests-\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)!
        store = DanceStore(defaults: defaults)
    }

    override func tearDown() async throws {
        defaults.removePersistentDomain(forName: suiteName)
        store = nil
        defaults = nil
        suiteName = nil
        try await super.tearDown()
    }

    private var firstDance: Dance { Dance.sampleDances[0] }

    func testToggleFavoriteFlipsState() {
        let dance = firstDance
        XCTAssertFalse(store.isFavorite(dance))
        store.toggleFavorite(dance)
        XCTAssertTrue(store.isFavorite(dance), "toggleFavorite must flip the state")
    }

    func testDoubleToggleRestoresState() {
        let dance = firstDance
        store.toggleFavorite(dance)
        store.toggleFavorite(dance)
        XCTAssertFalse(store.isFavorite(dance), "two toggles must return to original state")
    }

    func testFavoritesSetConsistentWithIsFavorite() {
        let dance = firstDance
        XCTAssertEqual(store.favorites.contains(dance.id), store.isFavorite(dance),
                       "favorites set and isFavorite must agree")
    }

    func testFavoritesSetUpdatedAfterToggle() {
        let dance = firstDance
        store.toggleFavorite(dance)
        XCTAssertTrue(store.favorites.contains(dance.id),
                      "favorites set must reflect toggled state")
    }

    func testMultipleDanceFavoritesAreIndependent() {
        let danceA = Dance.sampleDances[0]
        let danceB = Dance.sampleDances[1]
        store.toggleFavorite(danceA)
        XCTAssertTrue(store.isFavorite(danceA),  "danceA should be favorited")
        XCTAssertFalse(store.isFavorite(danceB), "danceB should not be favorited")
    }

    func testFavoritesPersistedToDefaults() {
        let dance = firstDance
        store.toggleFavorite(dance)
        // Create a second store backed by the same suite — simulates a relaunch.
        let store2 = DanceStore(defaults: defaults)
        XCTAssertTrue(store2.isFavorite(dance), "favorites must survive a store re-init from the same defaults")
    }
}
