import AppIntents
import Foundation
import SwiftUI

// MARK: - Entity

/// Exposes the dance catalogue to Siri and Shortcuts so a user can say a dance
/// by name. Backed by the same static catalogue the app renders, so there is no
/// separate source of truth to keep in sync.
struct DanceEntity: AppEntity {
    let id: String
    let name: String
    let category: String
    let bpm: Int

    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Dance"
    static let defaultQuery = DanceEntityQuery()

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)", subtitle: "\(category) · \(bpm) BPM")
    }

    init(_ dance: Dance) {
        self.id = dance.id
        self.name = dance.name
        self.category = dance.category.rawValue
        self.bpm = dance.bpm
    }

    /// Resolves back to the model type, or nil if the catalogue no longer has it.
    /// Main-actor isolated because the catalogue itself is.
    @MainActor
    var dance: Dance? {
        Dance.sampleDances.first { $0.id == id }
    }
}

/// The catalogue is main-actor isolated, so every lookup hops to the main
/// actor. These are all cheap in-memory filters over a static array.
struct DanceEntityQuery: EntityStringQuery {
    @MainActor
    func entities(for identifiers: [String]) async throws -> [DanceEntity] {
        let wanted = Set(identifiers)
        return Dance.sampleDances.filter { wanted.contains($0.id) }.map(DanceEntity.init)
    }

    /// Matches what the user actually said against dance names and categories.
    @MainActor
    func entities(matching string: String) async throws -> [DanceEntity] {
        Dance.sampleDances
            .filter {
                $0.name.localizedCaseInsensitiveContains(string) ||
                $0.category.rawValue.localizedCaseInsensitiveContains(string)
            }
            .map(DanceEntity.init)
    }

    @MainActor
    func suggestedEntities() async throws -> [DanceEntity] {
        // Favorites first — these are the dances this user actually works on.
        let favorites = DanceStore.shared.favoriteOrder
        let byID = Dictionary(Dance.sampleDances.map { ($0.id, $0) },
                              uniquingKeysWith: { first, _ in first })
        let favorited = favorites.compactMap { byID[$0] }
        let remainder = Dance.sampleDances.filter { !favorites.contains($0.id) }
        return (favorited + remainder).prefix(12).map(DanceEntity.init)
    }
}

// MARK: - Metronome

/// "Start the metronome at 120 BPM."
///
/// Routes through `PracticeRequest`, the mechanism the app already uses to
/// drive the metronome from outside the metronome view, rather than reaching
/// into the view-owned `MetronomeEngine`.
struct StartMetronomeIntent: AppIntent {
    static let title: LocalizedStringResource = "Start Metronome"
    static let description = IntentDescription("Starts the practice metronome at a chosen tempo.")
    /// The metronome lives on the Start Here tab, so the app must be frontmost.
    static let openAppWhenRun = true

    @Parameter(title: "Tempo (BPM)", default: 140,
               inclusiveRange: (40, 300))
    var bpm: Int

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        PracticeRequest.shared.pendingBPM = Double(bpm)
        PracticeRequest.shared.pendingTransport = true
        NotificationCenter.default.post(name: .openStartHereTab, object: nil)
        return .result(dialog: "Starting the metronome at \(bpm) beats per minute.")
    }
}

/// "Stop the metronome."
struct StopMetronomeIntent: AppIntent {
    static let title: LocalizedStringResource = "Stop Metronome"
    static let description = IntentDescription("Stops the practice metronome.")
    static let openAppWhenRun = true

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        PracticeRequest.shared.pendingTransport = false
        NotificationCenter.default.post(name: .openStartHereTab, object: nil)
        return .result(dialog: "Metronome stopped.")
    }
}

/// "Practice the Texas Two-Step" — sets the metronome to that dance's tempo
/// and rhythm, which is exactly what the in-app "practice this" button does.
struct PracticeDanceIntent: AppIntent {
    static let title: LocalizedStringResource = "Practice a Dance"
    static let description = IntentDescription("Sets the metronome to a dance's tempo and rhythm, then starts it.")
    static let openAppWhenRun = true

    @Parameter(title: "Dance")
    var dance: DanceEntity

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard let model = dance.dance else {
            return .result(dialog: "I couldn't find that dance any more.")
        }
        PracticeRequest.shared.pendingBPM = Double(model.bpm)
        PracticeRequest.shared.pendingPattern = model.suggestedPattern
        PracticeRequest.shared.pendingTransport = true
        NotificationCenter.default.post(name: .openStartHereTab, object: nil)
        return .result(dialog: "Practising \(model.name) at \(model.bpm) beats per minute.")
    }
}

// MARK: - Practice log

/// "Log a practice session for the Two-Step." Completes entirely in the
/// background — no reason to pull the user into the app for a log entry.
struct LogPracticeIntent: AppIntent {
    static let title: LocalizedStringResource = "Log Practice"
    static let description = IntentDescription("Records a practice session for a dance.")
    static let openAppWhenRun = false

    @Parameter(title: "Dance")
    var dance: DanceEntity

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard let model = dance.dance else {
            return .result(dialog: "I couldn't find that dance any more.")
        }
        let store = PracticeStore.shared
        store.logPractice(danceID: model.id)
        let streak = store.currentStreak
        return .result(dialog: streak > 1
                       ? "Logged \(model.name). That's a \(streak) day streak."
                       : "Logged \(model.name).")
    }
}

/// "What's my practice streak?"
struct PracticeStreakIntent: AppIntent {
    static let title: LocalizedStringResource = "Check Practice Streak"
    static let description = IntentDescription("Reports your current practice streak.")
    static let openAppWhenRun = false

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let store = PracticeStore.shared
        let streak = store.currentStreak
        guard streak > 0 else {
            return .result(dialog: "No streak yet — log a practice session to start one.")
        }
        return .result(dialog: "You're on a \(streak) day practice streak, with \(store.totalSessions) sessions logged.")
    }
}

// MARK: - Navigation

/// "Show my favorite dances."
struct ShowFavoritesIntent: AppIntent {
    static let title: LocalizedStringResource = "Show Favorites"
    static let description = IntentDescription("Opens your saved dances.")
    static let openAppWhenRun = true

    @MainActor
    func perform() async throws -> some IntentResult {
        NotificationCenter.default.post(name: .openFavoritesTab, object: nil)
        return .result()
    }
}

// MARK: - Shortcuts

struct WesternDanceShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: StartMetronomeIntent(),
            phrases: [
                "Start the metronome in \(.applicationName)",
                "Start \(.applicationName) metronome"
            ],
            shortTitle: "Start Metronome",
            systemImageName: "metronome"
        )
        AppShortcut(
            intent: StopMetronomeIntent(),
            phrases: [
                "Stop the metronome in \(.applicationName)",
                "Stop \(.applicationName) metronome"
            ],
            shortTitle: "Stop Metronome",
            systemImageName: "stop.circle"
        )
        AppShortcut(
            intent: PracticeDanceIntent(),
            phrases: [
                "Practice a dance in \(.applicationName)",
                "Practice with \(.applicationName)"
            ],
            shortTitle: "Practice a Dance",
            systemImageName: "figure.dance"
        )
        AppShortcut(
            intent: LogPracticeIntent(),
            phrases: [
                "Log a practice in \(.applicationName)",
                "Log practice with \(.applicationName)"
            ],
            shortTitle: "Log Practice",
            systemImageName: "checkmark.circle"
        )
        AppShortcut(
            intent: PracticeStreakIntent(),
            phrases: [
                "What's my streak in \(.applicationName)",
                "Check my \(.applicationName) streak"
            ],
            shortTitle: "Practice Streak",
            systemImageName: "flame"
        )
        AppShortcut(
            intent: ShowFavoritesIntent(),
            phrases: [
                "Show my favorites in \(.applicationName)",
                "Open \(.applicationName) favorites"
            ],
            shortTitle: "Show Favorites",
            systemImageName: "star"
        )
    }
}
