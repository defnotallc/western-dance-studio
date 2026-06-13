import XCTest
import CoreLocation
@testable import Western_Dance_Studio

@MainActor
final class DanceHallStoreTests: XCTestCase {
    private let store = DanceHallStore.shared
    // Denver, CO — multiple well-known venues are within 50 miles
    private let denver = CLLocationCoordinate2D(latitude: 39.7392, longitude: -104.9903)

    func testAllVenuesLoaded() {
        XCTAssertFalse(store.allVenues.isEmpty, "Venue list should be non-empty")
    }

    func testAllVenueIDsAreUnique() {
        let ids = store.allVenues.map(\.id)
        XCTAssertEqual(ids.count, Set(ids).count, "Every venue ID must be unique")
    }

    func testVenuesByStateIsAlphabeticallySorted() {
        let states = store.venuesByState.map(\.state)
        XCTAssertEqual(states, states.sorted(), "venuesByState must be sorted A→Z by state")
    }

    func testVenuesByStateHasNoEmptyGroups() {
        for group in store.venuesByState {
            XCTAssertFalse(group.venues.isEmpty,
                           "State '\(group.state)' must have at least one venue")
        }
    }

    func testRadiusFilterNearDenver() {
        let within50 = store.venues(within: 50, of: denver)
        XCTAssertFalse(within50.isEmpty, "There should be venues within 50 miles of Denver")
    }

    func testZeroRadiusReturnsNoVenues() {
        let atExactCenter = store.venues(within: 0, of: denver)
        XCTAssertTrue(atExactCenter.isEmpty, "Zero-mile radius must return no venues")
    }

    func testLargerRadiusNeverReturnsFewer() {
        let inner = store.venues(within: 25,  of: denver).count
        let outer = store.venues(within: 100, of: denver).count
        XCTAssertGreaterThanOrEqual(outer, inner,
            "100-mile radius must include everything within 25 miles")
    }

    func testRadiusResultsSortedNearestFirst() {
        let nearby = store.venues(within: 200, of: denver)
        guard nearby.count >= 2 else { return }
        var prev = store.milesFrom(denver, to: nearby[0])
        for hall in nearby.dropFirst() {
            let dist = store.milesFrom(denver, to: hall)
            XCTAssertGreaterThanOrEqual(dist, prev,
                "venues(within:of:) must be sorted nearest-first")
            prev = dist
        }
    }

    func testMilesFromIsPositiveAndReasonable() {
        guard let venue = store.allVenues.first else {
            XCTFail("No venues loaded"); return
        }
        let miles = store.milesFrom(denver, to: venue)
        XCTAssertGreaterThan(miles, 0, "Distance must be positive")
        XCTAssertLessThan(miles, 10_000, "Distance must be < 10,000 miles")
    }

    func testMilesFromGrizzlyRoseNearDenver() {
        guard let grizzly = store.allVenues.first(where: { $0.name == "Grizzly Rose" }) else {
            XCTFail("Grizzly Rose not found in venue data"); return
        }
        let miles = store.milesFrom(denver, to: grizzly)
        XCTAssertLessThan(miles, 10, "Grizzly Rose should be within 10 miles of Denver center")
        XCTAssertGreaterThan(miles, 0, "Distance must be positive")
    }
}
