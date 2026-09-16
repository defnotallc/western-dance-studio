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

    // MARK: - Markdown export

    private func entry(_ id: String, _ iso: String) -> PracticeEntry {
        let fmt = ISO8601DateFormatter()
        return PracticeEntry(danceID: id, date: fmt.date(from: iso)!)
    }

    func testMarkdownExportOfEmptyLogSaysSo() {
        let md = PracticeStore.markdownExport(entries: [], danceNames: [:])
        XCTAssertTrue(md.contains("# Practice Log"))
        XCTAssertTrue(md.contains("No practice sessions logged yet."))
    }

    func testMarkdownExportUsesDanceDisplayNames() {
        let entries = [entry("texas-two-step", "2026-09-10T18:00:00Z")]
        let md = PracticeStore.markdownExport(entries: entries,
                                              danceNames: ["texas-two-step": "Texas Two-Step"])
        XCTAssertTrue(md.contains("Texas Two-Step"), "display name must be used")
        XCTAssertFalse(md.contains("- texas-two-step"), "raw ID must not leak when a name exists")
    }

    func testMarkdownExportFallsBackToIDWhenNameUnknown() {
        let entries = [entry("mystery-dance", "2026-09-10T18:00:00Z")]
        let md = PracticeStore.markdownExport(entries: entries, danceNames: [:])
        XCTAssertTrue(md.contains("mystery-dance"),
                      "an unnamed dance must still appear rather than being dropped")
    }

    func testMarkdownExportUsesSingularFormsForCountsOfOne() {
        let entries = [entry("a", "2026-09-10T18:00:00Z")]
        let md = PracticeStore.markdownExport(entries: entries, danceNames: ["a": "Alpha"])
        XCTAssertTrue(md.contains("1 session across 1 day · 1 dance"),
                      "counts of one must read in the singular")
    }

    func testMarkdownExportGroupsDaysNewestFirst() {
        let entries = [
            entry("a", "2026-09-08T18:00:00Z"),
            entry("b", "2026-09-10T18:00:00Z"),
        ]
        var utc = Calendar(identifier: .gregorian)
        utc.timeZone = TimeZone(identifier: "UTC")!
        let md = PracticeStore.markdownExport(entries: entries,
                                              danceNames: ["a": "Alpha", "b": "Bravo"],
                                              calendar: utc)
        let alpha = md.range(of: "Alpha")!
        let bravo = md.range(of: "Bravo")!
        XCTAssertTrue(bravo.lowerBound < alpha.lowerBound,
                      "the newer day must be rendered before the older one")
    }

    func testMarkdownExportCountsSessionsAndDances() {
        let entries = [
            entry("a", "2026-09-10T18:00:00Z"),
            entry("a", "2026-09-10T19:00:00Z"),
            entry("b", "2026-09-11T18:00:00Z"),
        ]
        var utc = Calendar(identifier: .gregorian)
        utc.timeZone = TimeZone(identifier: "UTC")!
        let md = PracticeStore.markdownExport(entries: entries,
                                              danceNames: ["a": "Alpha", "b": "Bravo"],
                                              calendar: utc)
        XCTAssertTrue(md.contains("3 sessions across 2 days · 2 dances"),
                      "summary line must count sessions, days and unique dances")
    }
}
