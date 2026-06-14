import Foundation
import Observation

/// Tracks meaningful user engagement and signals when to request an App Store review.
/// Fires at 3, 10, and 30 lifetime events; throttled to once per 60 days.
@Observable
@MainActor
final class ReviewManager {
    static let shared = ReviewManager()

    /// Set to true when the review dialog should be shown. Observe this in a View
    /// via `.onChange` then call `requestReview()` from the SwiftUI environment.
    private(set) var shouldPrompt: Bool = false

    private enum Keys {
        static let engagementCount = "ReviewManager.engagementCount"
        static let lastRequestDate = "ReviewManager.lastRequestDate"
    }

    private var engagementCount: Int {
        get { UserDefaults.standard.integer(forKey: Keys.engagementCount) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.engagementCount) }
    }

    private var lastRequestDate: Date? {
        get { UserDefaults.standard.object(forKey: Keys.lastRequestDate) as? Date }
        set { UserDefaults.standard.set(newValue, forKey: Keys.lastRequestDate) }
    }

    private init() {}

    /// Call after a meaningful positive action — favorite added, module marked complete.
    /// Idempotent: repeated calls below the next threshold are no-ops.
    func recordEngagement() {
        engagementCount += 1
        guard [3, 10, 30].contains(engagementCount) else { return }
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
    }
}
