import XCTest
@testable import Western_Dance_Studio

@MainActor
final class PracticeStoreTests: XCTestCase {
    private var store: PracticeStore!
    private var defaults: UserDefaults!
    private var suiteName: String!

    override func setUp() async throws {
        try await super.setUp()
        suiteName = "PracticeStoreTests-\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)!
        store = PracticeStore(defaults: defaults)
    }

    override func tearDown() async throws {
        defaults.removePersistentDomain(forName: suiteName)
        store = nil
        defaults = nil
        suiteName = nil
        try await super.tearDown()
    }

    func testLogPracticeIncrementsTotalSessions() {
        XCTAssertEqual(store.totalSessions, 0)
        store.logPractice(danceID: "two-step")
        XCTAssertEqual(store.totalSessions, 1)
    }

    func testLogPracticeIncrementsPerDanceCount() {
        let danceID = "waltz"
        XCTAssertEqual(store.practiceCount(for: danceID), 0)
        store.logPractice(danceID: danceID)
        XCTAssertEqual(store.practiceCount(for: danceID), 1)
        store.logPractice(danceID: danceID)
        XCTAssertEqual(store.practiceCount(for: danceID), 2)
    }

    func testPracticedTodayTrueImmediatelyAfterLogging() {
        let danceID = "line-dance"
        XCTAssertFalse(store.practicedToday(danceID))
        store.logPractice(danceID: danceID)
        XCTAssertTrue(store.practicedToday(danceID))
    }

    func testLastPracticedReturnsMostRecentEntry() {
        let danceID = "swing"
        XCTAssertNil(store.lastPracticed(danceID))
        store.logPractice(danceID: danceID)
        let last = store.lastPracticed(danceID)
        XCTAssertNotNil(last)
        XCTAssertTrue(Calendar.current.isDateInToday(last!))
    }

    func testCurrentStreakIncludesTodayAfterLogging() {
        store.logPractice(danceID: "streak-check")
        XCTAssertGreaterThanOrEqual(store.currentStreak, 1)
    }

    func testUniqueDancesPracticedCountsDistinctIDsOnly() {
        let danceID = "repeat-dance"
        store.logPractice(danceID: danceID)
        store.logPractice(danceID: danceID)
        XCTAssertEqual(store.uniqueDancesPracticed, 1,
                       "repeated logs of the same dance must not inflate the unique count")
    }

    func testActiveDaysInLastNDaysIncludesToday() {
        store.logPractice(danceID: "active-days")
        let today = Calendar.current.startOfDay(for: Date())
        XCTAssertTrue(store.activeDays(inLast: 7).contains(today))
    }

    func testEntriesPersistedToDefaults() {
        store.logPractice(danceID: "two-step")
        let store2 = PracticeStore(defaults: defaults)
        XCTAssertEqual(store2.totalSessions, 1, "entries must survive a store re-init from the same defaults")
    }
}
