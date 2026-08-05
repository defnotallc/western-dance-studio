import XCTest
@testable import Western_Dance_Studio

/// `ReviewManager`'s persistence keys are private, so these tests read/write
/// the same UserDefaults keys directly (duplicated deliberately — there's no
/// public seam) and restore the prior values afterward, matching the
/// before/mutate/restore convention used by `DanceStoreTests`.
@MainActor
final class ReviewManagerTests: XCTestCase {
    private let defaults = UserDefaults.standard
    private let keyCount = "ReviewManager.engagementCount"
    private let keyLastRequest = "ReviewManager.lastRequestDate"
    private let keyNextThreshold = "ReviewManager.nextThreshold"

    private var manager: ReviewManager { ReviewManager.shared }

    private var savedCount: Int!
    private var savedLastRequest: Date?
    private var savedNextThreshold: Int!

    override func setUp() {
        super.setUp()
        savedCount = defaults.integer(forKey: keyCount)
        savedLastRequest = defaults.object(forKey: keyLastRequest) as? Date
        savedNextThreshold = defaults.integer(forKey: keyNextThreshold)
        // shouldPrompt is in-memory state on the shared singleton, not persisted —
        // clear any flag left set by a prior test regardless of run order. The
        // snapshot above is taken before this, so tearDown still restores the
        // true pre-test state of the persisted keys.
        if manager.shouldPrompt {
            manager.didPrompt()
        }
    }

    override func tearDown() {
        defaults.set(savedCount, forKey: keyCount)
        if let savedLastRequest {
            defaults.set(savedLastRequest, forKey: keyLastRequest)
        } else {
            defaults.removeObject(forKey: keyLastRequest)
        }
        defaults.set(savedNextThreshold, forKey: keyNextThreshold)
        super.tearDown()
    }

    func testRecordEngagementBelowThresholdDoesNotPrompt() {
        defaults.set(0, forKey: keyCount)
        defaults.set(3, forKey: keyNextThreshold)
        defaults.removeObject(forKey: keyLastRequest)

        manager.recordEngagement() // count → 1, still below threshold 3
        XCTAssertFalse(manager.shouldPrompt)
    }

    func testRecordEngagementAtThresholdWithNoPriorPromptTriggers() {
        defaults.set(2, forKey: keyCount)
        defaults.set(3, forKey: keyNextThreshold)
        defaults.removeObject(forKey: keyLastRequest)

        manager.recordEngagement() // count → 3, meets threshold, no throttle active
        XCTAssertTrue(manager.shouldPrompt)
        manager.didPrompt() // reset shouldPrompt so it doesn't leak into other tests
    }

    func testRecordEngagementAtThresholdWithinThrottleWindowDoesNotPrompt() {
        defaults.set(9, forKey: keyCount)
        defaults.set(10, forKey: keyNextThreshold)
        defaults.set(Date(), forKey: keyLastRequest) // prompted moments ago

        manager.recordEngagement() // count → 10, meets threshold, but throttle hasn't expired
        XCTAssertFalse(manager.shouldPrompt)
    }

    func testRecordEngagementAfterThrottleExpiresTriggers() {
        defaults.set(9, forKey: keyCount)
        defaults.set(10, forKey: keyNextThreshold)
        defaults.set(Date().addingTimeInterval(-61 * 86400), forKey: keyLastRequest) // 61 days ago

        manager.recordEngagement()
        XCTAssertTrue(manager.shouldPrompt)
        manager.didPrompt()
    }

    func testDidPromptAdvancesToNextThreshold() {
        defaults.set(3, forKey: keyNextThreshold)
        manager.didPrompt()
        XCTAssertEqual(defaults.integer(forKey: keyNextThreshold), 10)
    }

    func testDidPromptAtFinalThresholdStopsFuturePrompts() {
        defaults.set(30, forKey: keyNextThreshold)
        manager.didPrompt()
        XCTAssertEqual(defaults.integer(forKey: keyNextThreshold), 0, "past the last threshold, nextThreshold must be 0 (no more prompts)")
    }

    /// This is the audit-fixed carry-forward behavior: a threshold blocked by
    /// the throttle must not be lost — it should still fire on the next
    /// engagement once the throttle expires, rather than jumping straight to
    /// the following threshold or never firing again.
    func testSkippedThresholdCarriesForwardRatherThanBeingLost() {
        defaults.set(2, forKey: keyCount)
        defaults.set(3, forKey: keyNextThreshold)
        defaults.set(Date(), forKey: keyLastRequest) // throttled — a very recent prompt

        manager.recordEngagement() // count → 3, meets threshold 3, but throttled
        XCTAssertFalse(manager.shouldPrompt)

        // Throttle expires; nextThreshold must still be 3, not advanced or dropped.
        defaults.set(Date().addingTimeInterval(-61 * 86400), forKey: keyLastRequest)
        manager.recordEngagement() // count → 4, still >= threshold 3
        XCTAssertTrue(manager.shouldPrompt, "the threshold-3 prompt must carry forward once the throttle clears")
        manager.didPrompt()
    }

    func testDefaultNextThresholdForFreshInstallIsThree() {
        defaults.removeObject(forKey: keyNextThreshold)
        defaults.set(0, forKey: keyCount)
        defaults.removeObject(forKey: keyLastRequest)

        manager.recordEngagement() // count → 1
        XCTAssertFalse(manager.shouldPrompt) // below the implicit default threshold of 3

        defaults.set(2, forKey: keyCount)
        manager.recordEngagement() // count → 3, should now hit the default-3 threshold
        XCTAssertTrue(manager.shouldPrompt)
        manager.didPrompt()
    }
}
