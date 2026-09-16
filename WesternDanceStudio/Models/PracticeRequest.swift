import Foundation
import Observation

extension Notification.Name {
    /// Posted by any view that wants to switch focus to the Start Here tab's metronome section.
    static let openStartHereTab = Notification.Name("com.wds.openStartHereTab")
    /// Posted when the Favorites tab should come to the front.
    static let openFavoritesTab = Notification.Name("com.wds.openFavoritesTab")
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

    /// Transport request from outside the metronome view — currently App
    /// Intents / Siri. `true` starts the metronome, `false` stops it. The
    /// metronome view consumes the value and resets it to nil, matching how
    /// `pendingBPM` and `pendingPattern` already work.
    var pendingTransport: Bool? = nil
}
