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

    // MARK: - Ordering

    func testNewFavoritesAppendInOrder() {
        let a = Dance.sampleDances[0], b = Dance.sampleDances[1], c = Dance.sampleDances[2]
        store.toggleFavorite(a)
        store.toggleFavorite(b)
        store.toggleFavorite(c)
        XCTAssertEqual(store.favoriteOrder, [a.id, b.id, c.id],
                       "newly favorited dances must append in the order they were added")
    }

    func testUnfavoritePreservesOrderOfRemaining() {
        let a = Dance.sampleDances[0], b = Dance.sampleDances[1], c = Dance.sampleDances[2]
        [a, b, c].forEach(store.toggleFavorite)
        store.toggleFavorite(b)
        XCTAssertEqual(store.favoriteOrder, [a.id, c.id])
    }

    func testOrderPersistedToDefaults() {
        let a = Dance.sampleDances[0], b = Dance.sampleDances[1]
        store.toggleFavorite(a)
        store.toggleFavorite(b)
        store.applyReorder(sources: [b.id], before: a.id)
        let store2 = DanceStore(defaults: defaults)
        XCTAssertEqual(store2.favoriteOrder, [b.id, a.id],
                       "reordered favorites must survive a store re-init")
    }

    func testFavoritesSetStillMatchesOrder() {
        let a = Dance.sampleDances[0], b = Dance.sampleDances[1]
        store.toggleFavorite(a)
        store.toggleFavorite(b)
        XCTAssertEqual(store.favorites, Set(store.favoriteOrder),
                       "the Set view must stay consistent with the ordered array")
    }

    // MARK: - Reorder math (pure)

    func testReorderMovesItemBeforeAnchor() {
        XCTAssertEqual(DanceStore.reordering(["a", "b", "c"], moving: ["c"], before: "a"),
                       ["c", "a", "b"])
    }

    func testReorderToEndWhenAnchorIsNil() {
        XCTAssertEqual(DanceStore.reordering(["a", "b", "c"], moving: ["a"], before: nil),
                       ["b", "c", "a"])
    }

    func testReorderMultipleSourcesKeepsTheirRelativeOrder() {
        XCTAssertEqual(DanceStore.reordering(["a", "b", "c", "d"], moving: ["a", "c"], before: "d"),
                       ["b", "a", "c", "d"])
    }

    func testReorderIgnoresAnchorInsideMovedSet() {
        let order = ["a", "b", "c"]
        XCTAssertEqual(DanceStore.reordering(order, moving: ["a", "b"], before: "a"), order,
                       "an anchor that is itself being moved is not a well-defined move")
    }

    func testReorderIgnoresUnknownSources() {
        let order = ["a", "b"]
        XCTAssertEqual(DanceStore.reordering(order, moving: ["zzz"], before: "a"), order)
    }

    func testReorderToSamePositionIsIdentity() {
        XCTAssertEqual(DanceStore.reordering(["a", "b", "c"], moving: ["b"], before: "c"),
                       ["a", "b", "c"])
    }

    func testDedupedPreservesFirstSeenOrder() {
        XCTAssertEqual(DanceStore.deduped(["b", "a", "b", "c", "a"]), ["b", "a", "c"])
    }

    func testFavoritesPersistedToDefaults() {
        let dance = firstDance
        store.toggleFavorite(dance)
        // Create a second store backed by the same suite — simulates a relaunch.
        let store2 = DanceStore(defaults: defaults)
        XCTAssertTrue(store2.isFavorite(dance), "favorites must survive a store re-init from the same defaults")
    }
}
