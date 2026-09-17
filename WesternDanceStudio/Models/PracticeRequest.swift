import Foundation
import Observation

/// The app's top-level tabs. Named rather than raw integers so routing from
/// App Intents, deep links and in-app buttons can't drift out of sync with the
/// `TabView` tags.
enum AppTab: Int, CaseIterable, Sendable {
    case startHere = 0
    case dances    = 1
    case favorites = 2
    case venues    = 3
    case glossary  = 4
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

    /// Transport request from outside the metronome view — App Intents, Siri,
    /// or the widget deep link. `true` starts the metronome, `false` stops it.
    /// The metronome view consumes the value and resets it to nil, matching how
    /// `pendingBPM` and `pendingPattern` already work.
    var pendingTransport: Bool? = nil

    /// Tab the app should bring to the front.
    ///
    /// Stored state rather than a `NotificationCenter` post: a request can be
    /// made while the app is not running yet (an App Intent with
    /// `openAppWhenRun`, or a widget tap). A notification posted at that moment
    /// has no subscriber and is lost, whereas this value survives until the
    /// root view exists to consume it.
    var pendingTab: AppTab? = nil

    /// Routes to the metronome with a dance's tempo and rhythm preloaded —
    /// the single entry point shared by the in-app button, App Intents and the
    /// widget deep link.
    func requestPractice(bpm: Int, pattern: RhythmPattern, autoStart: Bool) {
        pendingBPM = Double(bpm)
        pendingPattern = pattern
        pendingTransport = autoStart
        pendingTab = .startHere
    }
}
