import Foundation

/// Defines which beats within a rhythmic cycle should sound and which are accented.
/// Lives at the model layer so both MetronomeEngine (Views) and Dance (Models) can use it.
enum RhythmPattern: String, CaseIterable, Identifiable, Codable {
    case steady = "Steady"
    case qqss   = "QQSS"
    case waltz  = "Waltz"
    case swing  = "Swing"

    var id: String { rawValue }

    /// Number of beats in one full rhythmic cycle.
    var length: Int {
        switch self {
        case .steady: return 1
        case .qqss:   return 6
        case .waltz:  return 3
        case .swing:  return 6
        }
    }

    /// Returns true if the given 1-based beat position within the cycle should produce a click.
    /// Silent beats represent "held" beats within a longer figure (e.g. the Slow in QQSS).
    func soundsOnBeat(_ position: Int) -> Bool {
        switch self {
        case .steady: return true
        case .qqss:
            // Q(1) Q(2) S-start(3) S-hold(4) S-start(5) S-hold(6)
            return [1, 2, 3, 5].contains(position)
        case .waltz: return true
        case .swing: return true
        }
    }

    /// Returns true if this beat is the primary accent within the cycle.
    func isAccent(_ position: Int) -> Bool {
        switch self {
        case .steady: return false
        case .qqss:   return position == 1
        case .waltz:  return position == 1
        case .swing:  return position == 1 || position == 5
        }
    }

    var displayName: String {
        switch self {
        case .steady: return "Steady"
        case .qqss:   return "Q-Q-S-S"
        case .waltz:  return "1-2-3"
        case .swing:  return "Triple"
        }
    }

    var subtitle: String {
        switch self {
        case .steady: return "One click per beat"
        case .qqss:   return "Quick · Quick · Slow · Slow — Two-Step"
        case .waltz:  return "One · Two · Three — Waltz"
        case .swing:  return "1-and-2 · 3-and-4 · rock-step — ECS"
        }
    }
}
