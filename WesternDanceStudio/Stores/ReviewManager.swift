import Foundation
import Observation

/// Tracks meaningful user engagement and signals when to request an App Store review.
/// Fires at 3, 10, and 30 lifetime events; throttled to once per 60 days.
/// If a threshold is blocked by the throttle, it carries forward — the next engagement
/// after the throttle expires will trigger the prompt rather than losing it forever.
@Observable
@MainActor
final class ReviewManager {
    static let shared = ReviewManager()

    /// Set to true when the review dialog should be shown. Observe this in a View
    /// via `.onChange` then call `requestReview()` from the SwiftUI environment.
    private(set) var shouldPrompt: Bool = false

    #if DEBUG
    /// Exposed for tests so key-name changes in this file are caught at
    /// compile time rather than silently testing the wrong UserDefaults slot.
    enum Keys {
        static let engagementCount = "ReviewManager.engagementCount"
        static let lastRequestDate = "ReviewManager.lastRequestDate"
        static let nextThreshold   = "ReviewManager.nextThreshold"
    }
    #else
    private enum Keys {
        static let engagementCount = "ReviewManager.engagementCount"
        static let lastRequestDate = "ReviewManager.lastRequestDate"
        static let nextThreshold   = "ReviewManager.nextThreshold"
    }
    #endif

    private static let thresholds = [3, 10, 30]

    let defaults: UserDefaults

    private init() {
        self.defaults = .standard
    }

    #if DEBUG
    /// Testing entry point — uses an isolated UserDefaults suite so tests
    /// don't bleed state into the production store or between test runs.
    init(defaults: UserDefaults) {
        self.defaults = defaults
    }
    #endif

    private var engagementCount: Int {
        get { defaults.integer(forKey: Keys.engagementCount) }
        set { defaults.set(newValue, forKey: Keys.engagementCount) }
    }

    private var lastRequestDate: Date? {
        get { defaults.object(forKey: Keys.lastRequestDate) as? Date }
        set { defaults.set(newValue, forKey: Keys.lastRequestDate) }
    }

    /// The lowest threshold the user hasn't been prompted for yet. 0 = no more prompts.
    /// Distinguish "never set" (nil in UserDefaults) from "exhausted" (stored as 0)
    /// so re-reading 0 after all prompts fire doesn't silently reset back to 3.
    private var nextThreshold: Int {
        get {
            guard defaults.object(forKey: Keys.nextThreshold) != nil else {
                return Self.thresholds[0]
            }
            return defaults.integer(forKey: Keys.nextThreshold)
        }
        set { defaults.set(newValue, forKey: Keys.nextThreshold) }
    }

    /// Call after a meaningful positive action — favorite added, module marked complete.
    /// Checks whether the engagement count has reached or passed the next threshold;
    /// if the 60-day throttle has also expired, sets shouldPrompt = true.
    func recordEngagement() {
        engagementCount += 1
        let threshold = nextThreshold
        guard threshold > 0, engagementCount >= threshold else { return }
        if let last = lastRequestDate {
            let days = Calendar.current.dateComponents([.day], from: last, to: Date()).day ?? 0
            guard days >= 60 else { return }
        }
        shouldPrompt = true
    }

    /// Call immediately after the review dialog fires so the throttle timestamp is stamped.
    func didPrompt() {
        shouldPrompt = false
        lastRequestDate = Date()
        let current = nextThreshold
        nextThreshold = Self.thresholds.first { $0 > current } ?? 0
    }
}
