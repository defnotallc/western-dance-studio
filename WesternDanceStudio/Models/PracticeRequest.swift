import Foundation
import Observation

extension Notification.Name {
    /// Posted by any view that wants to switch focus to the Start Here tab's metronome section.
    static let openStartHereTab = Notification.Name("com.wds.openStartHereTab")
}

/// Carries a BPM + rhythm pattern from any dance detail view to the metronome in Start Here.
/// Observable so BeginnerBootcampView auto-reacts when the request arrives.
@Observable
@MainActor
final class PracticeRequest {
    static let shared = PracticeRequest()
    private init() {}

    var pendingBPM: Double? = nil
    var pendingPattern: RhythmPattern? = nil
}
