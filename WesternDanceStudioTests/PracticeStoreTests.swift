import XCTest
@testable import Western_Dance_Studio

@MainActor
final class PracticeStoreTests: XCTestCase {
    private var store: PracticeStore { PracticeStore.shared }

    func testLogPracticeIncrementsTotalSessions() {
        let before = store.totalSessions
        store.logPractice(danceID: "two-step")
        XCTAssertEqual(store.totalSessions, before + 1)
    }

    func testLogPracticeIncrementsPerDanceCount() {
        let danceID = "waltz-\(UUID().uuidString)" // unique to isolate from other test runs
        XCTAssertEqual(store.practiceCount(for: danceID), 0)
        store.logPractice(danceID: danceID)
        XCTAssertEqual(store.practiceCount(for: danceID), 1)
        store.logPractice(danceID: danceID)
        XCTAssertEqual(store.practiceCount(for: danceID), 2)
    }

    func testPracticedTodayTrueImmediatelyAfterLogging() {
        let danceID = "line-dance-\(UUID().uuidString)"
        XCTAssertFalse(store.practicedToday(danceID))
        store.logPractice(danceID: danceID)
        XCTAssertTrue(store.practicedToday(danceID))
    }

    func testLastPracticedReturnsMostRecentEntry() {
        let danceID = "swing-\(UUID().uuidString)"
        XCTAssertNil(store.lastPracticed(danceID))
        store.logPractice(danceID: danceID)
        let last = store.lastPracticed(danceID)
        XCTAssertNotNil(last)
        XCTAssertTrue(Calendar.current.isDateInToday(last!))
    }

    func testCurrentStreakIncludesTodayAfterLogging() {
        let danceID = "streak-check-\(UUID().uuidString)"
        store.logPractice(danceID: danceID)
        // Logging today guarantees at least a 1-day streak.
        XCTAssertGreaterThanOrEqual(store.currentStreak, 1)
    }

    func testUniqueDancesPracticedCountsDistinctIDsOnly() {
        let danceID = "repeat-dance-\(UUID().uuidString)"
        let before = store.uniqueDancesPracticed
        store.logPractice(danceID: danceID)
        store.logPractice(danceID: danceID) // same dance again
        XCTAssertEqual(store.uniqueDancesPracticed, before + 1, "repeated logs of the same dance must not inflate the unique count")
    }

    func testActiveDaysInLastNDaysIncludesToday() {
        let danceID = "active-days-\(UUID().uuidString)"
        store.logPractice(danceID: danceID)
        let today = Calendar.current.startOfDay(for: Date())
        XCTAssertTrue(store.activeDays(inLast: 7).contains(today))
    }
}
