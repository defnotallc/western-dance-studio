import XCTest
@testable import Western_Dance_Studio

@MainActor
final class DanceStoreTests: XCTestCase {
    private var store: DanceStore { DanceStore.shared }
    private var firstDance: Dance { Dance.sampleDances[0] }

    func testToggleFavoriteFlipsState() {
        let dance = firstDance
        let before = store.isFavorite(dance)
        store.toggleFavorite(dance)
        XCTAssertNotEqual(store.isFavorite(dance), before, "toggleFavorite must flip the state")
        store.toggleFavorite(dance) // restore
    }

    func testDoubleToggleRestoresState() {
        let dance = firstDance
        let before = store.isFavorite(dance)
        store.toggleFavorite(dance)
        store.toggleFavorite(dance)
        XCTAssertEqual(store.isFavorite(dance), before, "two toggles must return to original state")
    }

    func testFavoritesSetConsistentWithIsFavorite() {
        let dance = firstDance
        XCTAssertEqual(store.favorites.contains(dance.id), store.isFavorite(dance),
                       "favorites set and isFavorite must agree")
    }

    func testFavoritesSetUpdatedAfterToggle() {
        let dance = firstDance
        let wasFav = store.isFavorite(dance)
        store.toggleFavorite(dance)
        XCTAssertEqual(store.favorites.contains(dance.id), !wasFav,
                       "favorites set must reflect toggled state")
        store.toggleFavorite(dance) // restore
    }

    func testMultipleDanceFavoritesAreIndependent() {
        let danceA = Dance.sampleDances[0]
        let danceB = Dance.sampleDances[1]
        let wasAFav = store.isFavorite(danceA)
        let wasBFav = store.isFavorite(danceB)

        if !wasAFav { store.toggleFavorite(danceA) }
        if wasBFav  { store.toggleFavorite(danceB) }

        XCTAssertTrue(store.isFavorite(danceA),  "danceA should be favorited")
        XCTAssertFalse(store.isFavorite(danceB), "danceB should not be favorited")

        // Restore
        if !wasAFav { store.toggleFavorite(danceA) }
        if wasBFav  { store.toggleFavorite(danceB) }
    }
}
