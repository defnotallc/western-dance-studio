import Foundation

// MARK: - Structured Step Model (Phase 1.3 — Content Data Architecture)
//
// DanceStep stores a single count within a dance pattern as structured data,
// enabling role-switching, count-synchronized playback, and automated review.
// Every property is individually queryable — no string parsing required.
//
// The companion DanceStep.Data namespace holds the canonical step charts for
// dances that have been fully verified against the audit. Add new dances there
// as they are verified; the Dance extension below exposes them as computed vars
// so the rest of the app can access them without touching Dance.swift's data section.

struct DanceStep: Identifiable, Hashable, Codable {
    let id: String           // e.g. "texas-two-step-leader-1"
    let count: Int           // ordinal position within the pattern (1, 2, 3 …)
    let beat: String         // beat(s) of music this step occupies, e.g. "1", "3-4", "and"
    let foot: FootSide
    let direction: StepDirection
    let timing: StepTiming
    let weightChange: Bool   // true = full weight transfer; false = touch / brush / accent
    let note: String?        // optional clarification for this count

    // MARK: - Supporting enums

    enum FootSide: String, Codable, Hashable, CaseIterable {
        case left, right
        var display: String { rawValue.capitalized }
    }

    enum StepDirection: String, Codable, Hashable {
        case forward
        case backward
        case sideLeft    = "side-left"
        case sideRight   = "side-right"
        case crossOver   = "cross-over"    // crosses in front of standing foot
        case crossBehind = "cross-behind"  // crosses behind standing foot
        case inPlace     = "in-place"
        case turn                          // turning step; direction is rotational

        var display: String {
            switch self {
            case .forward:      return "Forward"
            case .backward:     return "Backward"
            case .sideLeft:     return "Left"
            case .sideRight:    return "Right"
            case .crossOver:    return "Cross (over)"
            case .crossBehind:  return "Cross (behind)"
            case .inPlace:      return "In place"
            case .turn:         return "Turn"
            }
        }
    }

    enum StepTiming: String, Codable, Hashable {
        case quick          // 1 beat
        case slow           // 2 beats
        case andCount = "and"  // half-beat (syncopated)
        case hold           // no new step; maintain previous position
        case variable       // timing varies by context

        var display: String {
            switch self {
            case .quick:    return "Quick (1 beat)"
            case .slow:     return "Slow (2 beats)"
            case .andCount: return "& (½ beat)"
            case .hold:     return "Hold"
            case .variable: return "Variable"
            }
        }

        var shortDisplay: String {
            switch self {
            case .quick:    return "Q"
            case .slow:     return "S"
            case .andCount: return "&"
            case .hold:     return "—"
            case .variable: return "~"
            }
        }
    }
}

// MARK: - Dance extension: structured step data computed properties

extension Dance {
    /// Structured step-by-step data for the leader role, when available.
    /// Returns nil for dances that have not yet been verified and structured.
    var leaderStepData: [DanceStep]? { DanceStep.Data.leader[id] }

    /// Structured step-by-step data for the follower role, when available.
    var followerStepData: [DanceStep]? { DanceStep.Data.follower[id] }
}

// MARK: - Canonical step data

// All data in this namespace is primary-source verified per the council audit.
// Do NOT add a dance here until its footwork has been reviewed against the
// Dance Content Verification Checklist in the audit report.

extension DanceStep {
    enum Data {

        // MARK: Texas Two-Step
        //
        // Pattern: Quick-Quick-Slow-Slow (QQSS) = 6 beats per cycle
        // Leader starts on left foot, traveling forward.
        // Follower starts on right foot, traveling backward.
        // The Slow is NOT a step-hold. Both beats are occupied by continuous
        // body travel. The new weight arrives on the first beat of each Slow;
        // the body glides through the second beat without a new step.
        //
        // Source: UCWDC rulebook current edition; audit Section 2.1.

        private static let texasTwoStepLeader: [DanceStep] = [
            DanceStep(
                id: "texas-two-step-leader-1",
                count: 1, beat: "1",
                foot: .left, direction: .forward,
                timing: .quick, weightChange: true,
                note: "Heel contacts floor first; roll through the foot"
            ),
            DanceStep(
                id: "texas-two-step-leader-2",
                count: 2, beat: "2",
                foot: .right, direction: .forward,
                timing: .quick, weightChange: true,
                note: "Heel contacts floor first; maintain upper-body level — no bounce"
            ),
            DanceStep(
                id: "texas-two-step-leader-3",
                count: 3, beat: "3-4",
                foot: .left, direction: .forward,
                timing: .slow, weightChange: true,
                note: "Step on beat 3; glide through beat 4 — do not pause or hold"
            ),
            DanceStep(
                id: "texas-two-step-leader-4",
                count: 4, beat: "5-6",
                foot: .right, direction: .forward,
                timing: .slow, weightChange: true,
                note: "Step on beat 5; glide through beat 6. Pattern repeats from count 1."
            ),
        ]

        private static let texasTwoStepFollower: [DanceStep] = [
            DanceStep(
                id: "texas-two-step-follower-1",
                count: 1, beat: "1",
                foot: .right, direction: .backward,
                timing: .quick, weightChange: true,
                note: "Ball of foot contacts floor first on back steps"
            ),
            DanceStep(
                id: "texas-two-step-follower-2",
                count: 2, beat: "2",
                foot: .left, direction: .backward,
                timing: .quick, weightChange: true,
                note: "Maintain frame — do not pull arms backward to initiate the step"
            ),
            DanceStep(
                id: "texas-two-step-follower-3",
                count: 3, beat: "3-4",
                foot: .right, direction: .backward,
                timing: .slow, weightChange: true,
                note: "Step on beat 3; glide through beat 4"
            ),
            DanceStep(
                id: "texas-two-step-follower-4",
                count: 4, beat: "5-6",
                foot: .left, direction: .backward,
                timing: .slow, weightChange: true,
                note: "Step on beat 5; glide through beat 6. Pattern repeats from count 1."
            ),
        ]

        // MARK: Western One-Step
        //
        // Pattern: one step per beat of music (Q Q Q Q …)
        // Full measure shown as four counts for clarity.
        // Leader alternates L-R; follower alternates R-L.
        // All the quality markers of partner dancing apply: frame, connection,
        // upper body level, complete weight transfer. This is NOT a walk.
        //
        // Source: audit Section 2.3.

        private static let oneStepLeader: [DanceStep] = [
            DanceStep(
                id: "one-step-leader-1",
                count: 1, beat: "1",
                foot: .left, direction: .forward,
                timing: .quick, weightChange: true,
                note: "One step per beat — same quality as Two-Step; no bounce or shuffle"
            ),
            DanceStep(
                id: "one-step-leader-2",
                count: 2, beat: "2",
                foot: .right, direction: .forward,
                timing: .quick, weightChange: true,
                note: nil
            ),
            DanceStep(
                id: "one-step-leader-3",
                count: 3, beat: "3",
                foot: .left, direction: .forward,
                timing: .quick, weightChange: true,
                note: nil
            ),
            DanceStep(
                id: "one-step-leader-4",
                count: 4, beat: "4",
                foot: .right, direction: .forward,
                timing: .quick, weightChange: true,
                note: "Pattern repeats: L-R-L-R continuously"
            ),
        ]

        private static let oneStepFollower: [DanceStep] = [
            DanceStep(
                id: "one-step-follower-1",
                count: 1, beat: "1",
                foot: .right, direction: .backward,
                timing: .quick, weightChange: true,
                note: "Maintain frame; do not anticipate steps"
            ),
            DanceStep(
                id: "one-step-follower-2",
                count: 2, beat: "2",
                foot: .left, direction: .backward,
                timing: .quick, weightChange: true,
                note: nil
            ),
            DanceStep(
                id: "one-step-follower-3",
                count: 3, beat: "3",
                foot: .right, direction: .backward,
                timing: .quick, weightChange: true,
                note: nil
            ),
            DanceStep(
                id: "one-step-follower-4",
                count: 4, beat: "4",
                foot: .left, direction: .backward,
                timing: .quick, weightChange: true,
                note: "Pattern repeats: R-L-R-L continuously"
            ),
        ]

        // MARK: Triple Two-Step (basic — first 6 beats, no turn)
        //
        // Pattern: triple-step (1-and-2) + triple-step (3-and-4) + walk-walk (5-6)
        // Also called Fort Worth Shuffle or just "Shuffle."

        private static let tripleTwoStepLeader: [DanceStep] = [
            DanceStep(id: "triple-two-step-leader-1",  count: 1, beat: "1",   foot: .left,  direction: .forward, timing: .quick,    weightChange: true,  note: "First step of left triple"),
            DanceStep(id: "triple-two-step-leader-2",  count: 2, beat: "and", foot: .right, direction: .inPlace, timing: .andCount, weightChange: true,  note: "Close right to left (ball)"),
            DanceStep(id: "triple-two-step-leader-3",  count: 3, beat: "2",   foot: .left,  direction: .forward, timing: .quick,    weightChange: true,  note: "Complete left triple"),
            DanceStep(id: "triple-two-step-leader-4",  count: 4, beat: "3",   foot: .right, direction: .forward, timing: .quick,    weightChange: true,  note: "First step of right triple"),
            DanceStep(id: "triple-two-step-leader-5",  count: 5, beat: "and", foot: .left,  direction: .inPlace, timing: .andCount, weightChange: true,  note: "Close left to right (ball)"),
            DanceStep(id: "triple-two-step-leader-6",  count: 6, beat: "4",   foot: .right, direction: .forward, timing: .quick,    weightChange: true,  note: "Complete right triple"),
            DanceStep(id: "triple-two-step-leader-7",  count: 7, beat: "5",   foot: .left,  direction: .forward, timing: .quick,    weightChange: true,  note: "Walk forward on 5"),
            DanceStep(id: "triple-two-step-leader-8",  count: 8, beat: "6",   foot: .right, direction: .forward, timing: .quick,    weightChange: true,  note: "Walk forward on 6. Pattern repeats."),
        ]

        private static let tripleTwoStepFollower: [DanceStep] = [
            DanceStep(id: "triple-two-step-follower-1", count: 1, beat: "1",   foot: .right, direction: .backward, timing: .quick,    weightChange: true,  note: "First step of right triple"),
            DanceStep(id: "triple-two-step-follower-2", count: 2, beat: "and", foot: .left,  direction: .inPlace,  timing: .andCount, weightChange: true,  note: "Close left to right (ball)"),
            DanceStep(id: "triple-two-step-follower-3", count: 3, beat: "2",   foot: .right, direction: .backward, timing: .quick,    weightChange: true,  note: "Complete right triple"),
            DanceStep(id: "triple-two-step-follower-4", count: 4, beat: "3",   foot: .left,  direction: .backward, timing: .quick,    weightChange: true,  note: "First step of left triple"),
            DanceStep(id: "triple-two-step-follower-5", count: 5, beat: "and", foot: .right, direction: .inPlace,  timing: .andCount, weightChange: true,  note: "Close right to left (ball)"),
            DanceStep(id: "triple-two-step-follower-6", count: 6, beat: "4",   foot: .left,  direction: .backward, timing: .quick,    weightChange: true,  note: "Complete left triple"),
            DanceStep(id: "triple-two-step-follower-7", count: 7, beat: "5",   foot: .right, direction: .backward, timing: .quick,    weightChange: true,  note: "Walk back on 5"),
            DanceStep(id: "triple-two-step-follower-8", count: 8, beat: "6",   foot: .left,  direction: .backward, timing: .quick,    weightChange: true,  note: "Walk back on 6. Pattern repeats."),
        ]

        // MARK: Country Waltz (basic traveling box — 2 measures of 3/4 time)
        //
        // Pattern: forward-side-close, forward-side-close (6 counts, 6 beats).
        // Beat 1 of each measure is accented (the "down" beat).
        // Leader starts on left foot traveling forward along the line of dance.
        // Follower starts on right foot traveling backward.
        //
        // Source: audit Section 3.1; standard country waltz syllabus.

        private static let countryWaltzLeader: [DanceStep] = [
            DanceStep(id: "country-waltz-leader-1", count: 1, beat: "1", foot: .left,  direction: .forward,  timing: .quick, weightChange: true,  note: "Accented down-beat; heel lead, travel along line of dance"),
            DanceStep(id: "country-waltz-leader-2", count: 2, beat: "2", foot: .right, direction: .sideRight, timing: .quick, weightChange: true,  note: nil),
            DanceStep(id: "country-waltz-leader-3", count: 3, beat: "3", foot: .left,  direction: .inPlace,  timing: .quick, weightChange: true,  note: "Close left to right; weight fully on left"),
            DanceStep(id: "country-waltz-leader-4", count: 4, beat: "1", foot: .right, direction: .forward,  timing: .quick, weightChange: true,  note: "Accented down-beat of measure 2; continue traveling"),
            DanceStep(id: "country-waltz-leader-5", count: 5, beat: "2", foot: .left,  direction: .sideLeft, timing: .quick, weightChange: true,  note: nil),
            DanceStep(id: "country-waltz-leader-6", count: 6, beat: "3", foot: .right, direction: .inPlace,  timing: .quick, weightChange: true,  note: "Close right to left. Pattern repeats from count 1."),
        ]

        private static let countryWaltzFollower: [DanceStep] = [
            DanceStep(id: "country-waltz-follower-1", count: 1, beat: "1", foot: .right, direction: .backward,  timing: .quick, weightChange: true,  note: "Ball of foot lands first on back steps"),
            DanceStep(id: "country-waltz-follower-2", count: 2, beat: "2", foot: .left,  direction: .sideLeft,  timing: .quick, weightChange: true,  note: nil),
            DanceStep(id: "country-waltz-follower-3", count: 3, beat: "3", foot: .right, direction: .inPlace,   timing: .quick, weightChange: true,  note: "Close right to left; weight fully on right"),
            DanceStep(id: "country-waltz-follower-4", count: 4, beat: "1", foot: .left,  direction: .backward,  timing: .quick, weightChange: true,  note: "Accented down-beat; continue traveling backward"),
            DanceStep(id: "country-waltz-follower-5", count: 5, beat: "2", foot: .right, direction: .sideRight, timing: .quick, weightChange: true,  note: nil),
            DanceStep(id: "country-waltz-follower-6", count: 6, beat: "3", foot: .left,  direction: .inPlace,   timing: .quick, weightChange: true,  note: "Close left to right. Pattern repeats from count 1."),
        ]

        // MARK: East Coast Swing (basic 6-count — triple-step, triple-step, rock-step)
        //
        // Pattern: triple L (1-and-2), triple R (3-and-4), rock-step (5-6)
        // 6 beats of music; the two triple-steps each span 2 beats with an & count.
        // Leader starts side left; follower starts side right.
        // Typically danced in place / small rotation rather than traveling.
        //
        // Source: audit Section 3.2; UCWDC ECS basic.

        private static let eastCoastSwingLeader: [DanceStep] = [
            DanceStep(id: "ecs-leader-1", count: 1, beat: "1",   foot: .left,  direction: .sideLeft,  timing: .quick,    weightChange: true,  note: "First triple; step a small amount to the left"),
            DanceStep(id: "ecs-leader-2", count: 2, beat: "and", foot: .right, direction: .inPlace,   timing: .andCount, weightChange: true,  note: "Close right beside left (ball of foot)"),
            DanceStep(id: "ecs-leader-3", count: 3, beat: "2",   foot: .left,  direction: .sideLeft,  timing: .quick,    weightChange: true,  note: "Complete left triple; small step"),
            DanceStep(id: "ecs-leader-4", count: 4, beat: "3",   foot: .right, direction: .sideRight, timing: .quick,    weightChange: true,  note: "Second triple; step right"),
            DanceStep(id: "ecs-leader-5", count: 5, beat: "and", foot: .left,  direction: .inPlace,   timing: .andCount, weightChange: true,  note: "Close left beside right (ball of foot)"),
            DanceStep(id: "ecs-leader-6", count: 6, beat: "4",   foot: .right, direction: .sideRight, timing: .quick,    weightChange: true,  note: "Complete right triple; small step"),
            DanceStep(id: "ecs-leader-7", count: 7, beat: "5",   foot: .left,  direction: .backward,  timing: .quick,    weightChange: true,  note: "Rock back — step back on left, transferring weight"),
            DanceStep(id: "ecs-leader-8", count: 8, beat: "6",   foot: .right, direction: .inPlace,   timing: .quick,    weightChange: true,  note: "Replace — step in place on right, recovering weight. Pattern repeats."),
        ]

        private static let eastCoastSwingFollower: [DanceStep] = [
            DanceStep(id: "ecs-follower-1", count: 1, beat: "1",   foot: .right, direction: .sideRight, timing: .quick,    weightChange: true,  note: "First triple; step a small amount to the right"),
            DanceStep(id: "ecs-follower-2", count: 2, beat: "and", foot: .left,  direction: .inPlace,   timing: .andCount, weightChange: true,  note: "Close left beside right (ball of foot)"),
            DanceStep(id: "ecs-follower-3", count: 3, beat: "2",   foot: .right, direction: .sideRight, timing: .quick,    weightChange: true,  note: "Complete right triple; small step"),
            DanceStep(id: "ecs-follower-4", count: 4, beat: "3",   foot: .left,  direction: .sideLeft,  timing: .quick,    weightChange: true,  note: "Second triple; step left"),
            DanceStep(id: "ecs-follower-5", count: 5, beat: "and", foot: .right, direction: .inPlace,   timing: .andCount, weightChange: true,  note: "Close right beside left (ball of foot)"),
            DanceStep(id: "ecs-follower-6", count: 6, beat: "4",   foot: .left,  direction: .sideLeft,  timing: .quick,    weightChange: true,  note: "Complete left triple; small step"),
            DanceStep(id: "ecs-follower-7", count: 7, beat: "5",   foot: .right, direction: .backward,  timing: .quick,    weightChange: true,  note: "Rock back — step back on right, transferring weight"),
            DanceStep(id: "ecs-follower-8", count: 8, beat: "6",   foot: .left,  direction: .inPlace,   timing: .quick,    weightChange: true,  note: "Replace — step in place on left, recovering weight. Pattern repeats."),
        ]

        // MARK: Country Polka (hop-step-close-step, 2/4 time, 4 counts per half-cycle)
        //
        // Pattern: hop (&), step-close-step (1-and-2), hop (&), step-close-step (3-and-4)
        // The preparatory hop shifts weight to the opposite foot before each traveling unit.
        // Leader starts hopping on right (freeing left for the first step forward).
        // Follower mirrors: hops on left, first step on right.
        // Both travel forward along the line of dance.
        //
        // Source: audit Section 3.3; standard Western polka syllabus.

        private static let countryPolkaLeader: [DanceStep] = [
            DanceStep(id: "polka-leader-1", count: 1, beat: "and", foot: .right, direction: .inPlace,  timing: .andCount, weightChange: true,  note: "Preparatory hop on right — left foot lifts, ready to travel"),
            DanceStep(id: "polka-leader-2", count: 2, beat: "1",   foot: .left,  direction: .forward,  timing: .quick,    weightChange: true,  note: "Step forward on left; begin traveling along line of dance"),
            DanceStep(id: "polka-leader-3", count: 3, beat: "and", foot: .right, direction: .inPlace,  timing: .andCount, weightChange: true,  note: "Close right beside left (ball of foot); keep weight light"),
            DanceStep(id: "polka-leader-4", count: 4, beat: "2",   foot: .left,  direction: .forward,  timing: .quick,    weightChange: true,  note: "Step forward on left; complete first traveling unit"),
            DanceStep(id: "polka-leader-5", count: 5, beat: "and", foot: .left,  direction: .inPlace,  timing: .andCount, weightChange: true,  note: "Preparatory hop on left — right foot lifts"),
            DanceStep(id: "polka-leader-6", count: 6, beat: "3",   foot: .right, direction: .forward,  timing: .quick,    weightChange: true,  note: "Step forward on right"),
            DanceStep(id: "polka-leader-7", count: 7, beat: "and", foot: .left,  direction: .inPlace,  timing: .andCount, weightChange: true,  note: "Close left beside right (ball of foot)"),
            DanceStep(id: "polka-leader-8", count: 8, beat: "4",   foot: .right, direction: .forward,  timing: .quick,    weightChange: true,  note: "Step forward on right; complete cycle. Pattern repeats from count 1."),
        ]

        private static let countryPolkaFollower: [DanceStep] = [
            DanceStep(id: "polka-follower-1", count: 1, beat: "and", foot: .left,  direction: .inPlace,  timing: .andCount, weightChange: true,  note: "Preparatory hop on left — right foot lifts, ready to travel"),
            DanceStep(id: "polka-follower-2", count: 2, beat: "1",   foot: .right, direction: .forward,  timing: .quick,    weightChange: true,  note: "Step forward on right; travel with the lead"),
            DanceStep(id: "polka-follower-3", count: 3, beat: "and", foot: .left,  direction: .inPlace,  timing: .andCount, weightChange: true,  note: "Close left beside right (ball of foot)"),
            DanceStep(id: "polka-follower-4", count: 4, beat: "2",   foot: .right, direction: .forward,  timing: .quick,    weightChange: true,  note: "Step forward on right; complete first traveling unit"),
            DanceStep(id: "polka-follower-5", count: 5, beat: "and", foot: .right, direction: .inPlace,  timing: .andCount, weightChange: true,  note: "Preparatory hop on right — left foot lifts"),
            DanceStep(id: "polka-follower-6", count: 6, beat: "3",   foot: .left,  direction: .forward,  timing: .quick,    weightChange: true,  note: "Step forward on left"),
            DanceStep(id: "polka-follower-7", count: 7, beat: "and", foot: .right, direction: .inPlace,  timing: .andCount, weightChange: true,  note: "Close right beside left (ball of foot)"),
            DanceStep(id: "polka-follower-8", count: 8, beat: "4",   foot: .left,  direction: .forward,  timing: .quick,    weightChange: true,  note: "Step forward on left; complete cycle. Pattern repeats from count 1."),
        ]

        // MARK: Lookup tables

        static let leader: [String: [DanceStep]] = [
            "texas-two-step":  texasTwoStepLeader,
            "one-step":        oneStepLeader,
            "triple-two-step": tripleTwoStepLeader,
            "country-waltz":   countryWaltzLeader,
            "east-coast-swing": eastCoastSwingLeader,
            "country-polka":   countryPolkaLeader,
        ]

        static let follower: [String: [DanceStep]] = [
            "texas-two-step":  texasTwoStepFollower,
            "one-step":        oneStepFollower,
            "triple-two-step": tripleTwoStepFollower,
            "country-waltz":   countryWaltzFollower,
            "east-coast-swing": eastCoastSwingFollower,
            "country-polka":   countryPolkaFollower,
        ]
    }
}
