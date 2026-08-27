import XCTest
@testable import Western_Dance_Studio

@MainActor
final class ReviewManagerTests: XCTestCase {
    private var defaults: UserDefaults!
    private var manager: ReviewManager!
    private var suiteName: String!

    override func setUp() async throws {
        try await super.setUp()
        suiteName = "ReviewManagerTests-\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)!
        manager = ReviewManager(defaults: defaults)
    }

    override func tearDown() async throws {
        defaults.removePersistentDomain(forName: suiteName)
        manager = nil
        defaults = nil
        suiteName = nil
        try await super.tearDown()
    }

    // Use ReviewManager.Keys (exposed under #if DEBUG) for compile-time safety —
    // key renames in ReviewManager are caught here rather than silently testing the wrong slot.

    func testRecordEngagementBelowThresholdDoesNotPrompt() {
        defaults.set(0, forKey: ReviewManager.Keys.engagementCount)
        defaults.set(3, forKey: ReviewManager.Keys.nextThreshold)
        defaults.removeObject(forKey: ReviewManager.Keys.lastRequestDate)

        manager.recordEngagement() // count → 1, still below threshold 3
        XCTAssertFalse(manager.shouldPrompt)
    }

    func testRecordEngagementAtThresholdWithNoPriorPromptTriggers() {
        defaults.set(2, forKey: ReviewManager.Keys.engagementCount)
        defaults.set(3, forKey: ReviewManager.Keys.nextThreshold)
        defaults.removeObject(forKey: ReviewManager.Keys.lastRequestDate)

        manager.recordEngagement() // count → 3, meets threshold, no throttle active
        XCTAssertTrue(manager.shouldPrompt)
    }

    func testRecordEngagementAtThresholdWithinThrottleWindowDoesNotPrompt() {
        defaults.set(9, forKey: ReviewManager.Keys.engagementCount)
        defaults.set(10, forKey: ReviewManager.Keys.nextThreshold)
        defaults.set(Date(), forKey: ReviewManager.Keys.lastRequestDate)

        manager.recordEngagement() // count → 10, meets threshold, but throttle hasn't expired
        XCTAssertFalse(manager.shouldPrompt)
    }

    func testRecordEngagementAfterThrottleExpiresTriggers() {
        defaults.set(9, forKey: ReviewManager.Keys.engagementCount)
        defaults.set(10, forKey: ReviewManager.Keys.nextThreshold)
        defaults.set(Date().addingTimeInterval(-61 * 86400), forKey: ReviewManager.Keys.lastRequestDate)

        manager.recordEngagement()
        XCTAssertTrue(manager.shouldPrompt)
    }

    func testDidPromptAdvancesToNextThreshold() {
        defaults.set(3, forKey: ReviewManager.Keys.nextThreshold)
        manager.didPrompt()
        XCTAssertEqual(defaults.integer(forKey: ReviewManager.Keys.nextThreshold), 10)
    }

    func testDidPromptAtFinalThresholdStopsFuturePrompts() {
        defaults.set(30, forKey: ReviewManager.Keys.nextThreshold)
        manager.didPrompt()
        XCTAssertEqual(defaults.integer(forKey: ReviewManager.Keys.nextThreshold), 0,
                       "past the last threshold, nextThreshold must be 0 (no more prompts)")
    }

    func testSkippedThresholdCarriesForwardRatherThanBeingLost() {
        defaults.set(2, forKey: ReviewManager.Keys.engagementCount)
        defaults.set(3, forKey: ReviewManager.Keys.nextThreshold)
        defaults.set(Date(), forKey: ReviewManager.Keys.lastRequestDate)

        manager.recordEngagement() // count → 3, meets threshold 3, but throttled
        XCTAssertFalse(manager.shouldPrompt)

        // Throttle expires; nextThreshold must still be 3, not advanced or dropped.
        defaults.set(Date().addingTimeInterval(-61 * 86400), forKey: ReviewManager.Keys.lastRequestDate)
        manager.recordEngagement() // count → 4, still >= threshold 3
        XCTAssertTrue(manager.shouldPrompt,
                      "the threshold-3 prompt must carry forward once the throttle clears")
    }

    func testDefaultNextThresholdForFreshInstallIsThree() {
        defaults.removeObject(forKey: ReviewManager.Keys.nextThreshold)
        defaults.set(0, forKey: ReviewManager.Keys.engagementCount)
        defaults.removeObject(forKey: ReviewManager.Keys.lastRequestDate)

        manager.recordEngagement() // count → 1
        XCTAssertFalse(manager.shouldPrompt)

        defaults.set(2, forKey: ReviewManager.Keys.engagementCount)
        manager.recordEngagement() // count → 3, should hit the default-3 threshold
        XCTAssertTrue(manager.shouldPrompt)
    }
}
