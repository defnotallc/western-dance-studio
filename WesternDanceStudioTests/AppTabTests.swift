import XCTest
@testable import Western_Dance_Studio

/// `AppTab.rawValue` is used directly as the `TabView` selection tag, so these
/// pin the mapping that App Intents and deep links rely on.
final class AppTabTests: XCTestCase {

    func testTabTagsMatchTabViewOrder() {
        XCTAssertEqual(AppTab.startHere.rawValue, 0)
        XCTAssertEqual(AppTab.dances.rawValue,    1)
        XCTAssertEqual(AppTab.favorites.rawValue, 2)
        XCTAssertEqual(AppTab.venues.rawValue,    3)
        XCTAssertEqual(AppTab.glossary.rawValue,  4)
    }

    func testTagsAreContiguousAndUnique() {
        let tags = AppTab.allCases.map(\.rawValue)
        XCTAssertEqual(tags, Array(0..<AppTab.allCases.count),
                       "tags must stay contiguous from zero to match the TabView tags")
        XCTAssertEqual(Set(tags).count, tags.count, "tab tags must be unique")
    }
}
