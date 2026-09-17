import XCTest
@testable import Western_Dance_Studio

final class DeepLinkTests: XCTestCase {

    private func link(_ string: String) -> DeepLink? {
        guard let url = URL(string: string) else { return nil }
        return DeepLink(url: url)
    }

    func testParsesPracticeLink() {
        XCTAssertEqual(link("westerndance://practice?dance=texas-two-step"),
                       .practice(danceID: "texas-two-step"))
    }

    func testSchemeIsCaseInsensitive() {
        XCTAssertEqual(link("WesternDance://practice?dance=one-step"),
                       .practice(danceID: "one-step"))
    }

    func testRejectsForeignScheme() {
        XCTAssertNil(link("https://practice?dance=texas-two-step"),
                     "a link from another scheme must never route the app")
    }

    func testRejectsUnknownHost() {
        XCTAssertNil(link("westerndance://delete-everything?dance=texas-two-step"))
    }

    func testRejectsMissingDanceParameter() {
        XCTAssertNil(link("westerndance://practice"))
    }

    func testRejectsEmptyDanceParameter() {
        XCTAssertNil(link("westerndance://practice?dance="))
    }

    func testIgnoresUnrelatedQueryItems() {
        XCTAssertEqual(link("westerndance://practice?foo=bar&dance=country-waltz"),
                       .practice(danceID: "country-waltz"))
    }

    /// The widget builds its URL from a dance ID; every shipped ID must survive
    /// a round trip through URL parsing.
    @MainActor
    func testEveryCatalogueIDRoundTrips() {
        for dance in Dance.sampleDances {
            let url = "westerndance://practice?dance=\(dance.id)"
            XCTAssertEqual(link(url), .practice(danceID: dance.id),
                           "\(dance.id) did not round-trip through the deep link")
        }
    }
}
