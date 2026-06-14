import Foundation

struct CommonError: Identifiable {
    let id: String
    let category: ErrorCategory
    let title: String
    let symptom: String
    let cause: String
    let fix: String
    let danceIDs: [String]
    let moduleIDs: [String]

    enum ErrorCategory: String, CaseIterable, Identifiable {
        case timing     = "Timing & Rhythm"
        case footwork   = "Footwork"
        case partner    = "Partner Dancing"
        case lineDance  = "Line Dancing"
        case floorcraft = "Floor Navigation"
        var id: String { rawValue }
        var icon: String {
            switch self {
            case .timing:     return "timer"
            case .footwork:   return "figure.walk"
            case .partner:    return "person.2.fill"
            case .lineDance:  return "music.note.list"
            case .floorcraft: return "arrow.triangle.turn.up.right.circle.fill"
            }
        }
    }
}

extension CommonError {
    static let all: [CommonError] = timingErrors + footworkErrors + partnerErrors + lineDanceErrors + florcraftErrors

    // MARK: - Timing & Rhythm

    private static let timingErrors: [CommonError] = [
        CommonError(
            id: "pausing-on-the-slow",
            category: .timing,
            title: "Pausing on the Slow Beat",
            symptom: "Dancer freezes or taps in place on counts 3–4 of Two-Step instead of continuing forward.",
            cause: "\"Slow\" sounds like a pause, but in Texas Two-Step it means one step that travels through two beats — never a step-hold.",
            fix: "Step on count 3 and continue gliding forward through beat 4 without stopping. Think of it as one long stride, not a step followed by a freeze.",
            danceIDs: ["texas-two-step", "triple-two-step", "double-two-step", "nightclub-two-step", "rhythm-two-step"],
            moduleIDs: ["module-3", "module-5"]
        ),
        CommonError(
            id: "rushing-the-quicks",
            category: .timing,
            title: "Rushing the Quick-Quick",
            symptom: "The two Quick steps run together and land slightly before the beat, making the pattern feel scrambled.",
            cause: "Anticipating the next Slow makes dancers hurry. Each Quick is one full beat — not a half-beat.",
            fix: "Say \"Quick — Quick\" with an even gap between them. Slow down to 90 BPM with a metronome until the spacing is automatic before increasing speed.",
            danceIDs: ["texas-two-step", "triple-two-step"],
            moduleIDs: ["module-3"]
        ),
        CommonError(
            id: "counting-lyrics",
            category: .timing,
            title: "Counting Syllables Instead of Beats",
            symptom: "Dancer stays on pattern during verses but drifts during long-held vocal notes or instrumental breaks.",
            cause: "Beginners follow the melody or lyrics, which have no steady pulse. The beat lives in the drums and bass, not the words.",
            fix: "Lock onto the kick drum and bass guitar — not the singer. Count music in 4-beat phrases. Everything else is decoration.",
            danceIDs: [],
            moduleIDs: ["module-1"]
        ),
        CommonError(
            id: "missing-downbeat",
            category: .timing,
            title: "Starting on the Wrong Beat",
            symptom: "Dancer launches on beat 2 or 3 and spends the song half a count off from their partner.",
            cause: "Nerves or impatience. Finding beat 1 in an unfamiliar song takes deliberate practice.",
            fix: "Listen for one full 8-beat phrase before stepping. Nod to the beat, find the phrase start (usually after an 8-count), then step on \"1\".",
            danceIDs: [],
            moduleIDs: ["module-1", "module-2", "module-3"]
        ),
        CommonError(
            id: "losing-beat-in-turn",
            category: .timing,
            title: "Losing the Beat During a Turn",
            symptom: "Dancer stumbles or adds an extra step coming out of a free spin or underarm turn.",
            cause: "Focusing on the turn mechanics rather than the music. The beat doesn't stop while you spin.",
            fix: "Keep counting internally through every turn. Commit to finishing the spin by beat 4 so the next Quick lands exactly on beat 1.",
            danceIDs: ["texas-two-step", "one-step", "east-coast-swing"],
            moduleIDs: ["module-5", "module-7"]
        ),
    ]

    // MARK: - Footwork

    private static let footworkErrors: [CommonError] = [
        CommonError(
            id: "bouncing",
            category: .footwork,
            title: "Bobbing Up and Down",
            symptom: "Head visibly rises on each step, creating a roller-coaster look instead of smooth travel across the floor.",
            cause: "Locking the knees on weight transfer pushes the body upward, then releases it down on the next step.",
            fix: "Keep a slight bend in the knees at all times. Step by lowering onto the foot and rolling heel to ball so the body stays level throughout each stride.",
            danceIDs: ["texas-two-step", "one-step", "triple-two-step", "country-waltz"],
            moduleIDs: ["module-2", "module-3", "module-7"]
        ),
        CommonError(
            id: "steps-too-small",
            category: .footwork,
            title: "Taking Tiny Steps",
            symptom: "Couple barely moves across the floor; other couples overtake them or nearly collide from behind.",
            cause: "Uncertainty. Beginners shuffle cautiously because they're unsure of the pattern or afraid of bumping into others.",
            fix: "On the Slow counts, reach forward with the heel and push off the back foot — commit to the stride. Smaller steps are safer during crowded moments, not all the time.",
            danceIDs: ["texas-two-step", "one-step"],
            moduleIDs: ["module-2", "module-3"]
        ),
        CommonError(
            id: "not-rolling",
            category: .footwork,
            title: "Stomping Instead of Rolling Through",
            symptom: "Each step is a flat-footed slap rather than a smooth heel-to-ball roll, generating unnecessary sound and impact.",
            cause: "Habit from everyday walking without thinking about foot mechanics.",
            fix: "Contact the floor with the heel first, then roll through to the ball as weight transfers. On Quick steps the roll is compressed but still present.",
            danceIDs: ["texas-two-step", "one-step", "triple-two-step", "country-waltz"],
            moduleIDs: ["module-2", "module-3", "module-7"]
        ),
        CommonError(
            id: "locking-knees",
            category: .footwork,
            title: "Locking Your Knees on Weight",
            symptom: "Dancer looks stiff and jerky; hip movement is mechanical rather than natural.",
            cause: "Standing fully upright feels stable, but rigid knees block the natural absorption of each weight transfer.",
            fix: "Imagine you're an athlete ready to react — stay in a slight crouch with soft, responsive knees throughout every step.",
            danceIDs: [],
            moduleIDs: ["module-2", "module-3"]
        ),
        CommonError(
            id: "heel-toe-confusion",
            category: .footwork,
            title: "Heel-Toe Confusion in Line Dances",
            symptom: "Dancer plants the wrong part of the foot on a heel-dig or toe-touch, throwing off the rhythm of the following step.",
            cause: "Cue words like \"heel\" and \"toe\" are heard but not visualized — beginners plant both parts equally.",
            fix: "Heel dig: lift all toes and strike with the heel only — weight stays on the standing foot. Toe touch: only the toe tip contacts the floor; no weight shifts.",
            danceIDs: ["electric-slide", "boot-scootin-boogie", "cupid-shuffle", "copperhead-road"],
            moduleIDs: ["module-4", "module-6"]
        ),
    ]

    // MARK: - Partner Dancing

    private static let partnerErrors: [CommonError] = [
        CommonError(
            id: "back-leading",
            category: .partner,
            title: "Back-Leading (Follower Anticipating)",
            symptom: "Follower initiates or steers the move before feeling a lead, or resists the leader's direction.",
            cause: "Knowing the pattern in advance — once a follower memorizes the sequence, they move ahead of the communication instead of responding to it.",
            fix: "Followers: treat every dance as an improvisation you've never seen. Stay receptive, step only when you feel weight shift or frame pressure, and let each figure surprise you.",
            danceIDs: ["texas-two-step", "one-step", "country-waltz", "east-coast-swing", "west-coast-swing"],
            moduleIDs: ["module-2", "module-3", "module-5", "module-7"]
        ),
        CommonError(
            id: "leading-with-arms",
            category: .partner,
            title: "Leading with Arms Instead of Body",
            symptom: "Leader yanks, pulls, or pushes the follower's arm to initiate turns rather than guiding through the shared frame.",
            cause: "Arm movement is visible and feels intuitive — but leading is whole-body communication through the frame, not arm mechanics.",
            fix: "Lead every move by first changing your own direction with your core, then use frame — not arm strength — to convey that change. The arm's job is connection, not locomotion.",
            danceIDs: ["texas-two-step", "one-step", "country-waltz", "east-coast-swing"],
            moduleIDs: ["module-2", "module-3", "module-5"]
        ),
        CommonError(
            id: "death-grip",
            category: .partner,
            title: "Gripping Too Tightly",
            symptom: "Follower can't release to turn or style; wrist redness after a few songs.",
            cause: "Holding tighter feels like better control, but it telegraphs tension and restricts movement for both partners.",
            fix: "Hold like you're cradling a small bird — firm enough that it can't escape, gentle enough that it isn't harmed. Fingers close lightly; thumb does not lock.",
            danceIDs: ["texas-two-step", "one-step", "country-waltz", "nightclub-two-step", "east-coast-swing", "west-coast-swing"],
            moduleIDs: ["module-2", "module-3", "module-5", "module-7"]
        ),
        CommonError(
            id: "leaning-on-partner",
            category: .partner,
            title: "Using Your Partner as a Crutch",
            symptom: "If the couple's connection were suddenly removed, one or both would lose balance. The partnership feels heavy.",
            cause: "Instinctive weight-sharing, especially during turns or on a slippery floor.",
            fix: "Each partner maintains their own axis. Connection creates a shared frame — not mutual support beams. You should be able to stand independently if your partner stepped away.",
            danceIDs: ["texas-two-step", "one-step", "nightclub-two-step", "country-waltz"],
            moduleIDs: ["module-2", "module-3", "module-7"]
        ),
        CommonError(
            id: "breaking-frame",
            category: .partner,
            title: "Breaking Frame After Figures",
            symptom: "Leader drops follower's hand or collapses the frame at the end of an underarm turn, leaving no clear return to closed position.",
            cause: "Concentrating on the figure itself and forgetting that connection is continuous — before, during, and after every move.",
            fix: "Think of the frame as a channel that stays open. After any figure, immediately re-establish contact with the same arm energy you started with.",
            danceIDs: ["texas-two-step", "one-step", "east-coast-swing"],
            moduleIDs: ["module-5", "module-7"]
        ),
    ]

    // MARK: - Line Dancing

    private static let lineDanceErrors: [CommonError] = [
        CommonError(
            id: "losing-wall-count",
            category: .lineDance,
            title: "Losing Track of Which Wall You're On",
            symptom: "Dancer finishes the sequence facing the wrong direction and scrambles to catch up with the room.",
            cause: "Not actively counting walls — watching others to stay aligned, which breaks down on a crowded or dark floor.",
            fix: "Count walls out loud at first: \"1... 2... 3... 4...\" as you complete each rotation. A 4-wall dance always returns to the start wall after four repeats.",
            danceIDs: ["electric-slide", "boot-scootin-boogie", "copperhead-road", "watermelon-crawl", "tush-push", "cupid-shuffle"],
            moduleIDs: ["module-4", "module-6"]
        ),
        CommonError(
            id: "missing-restart",
            category: .lineDance,
            title: "Blowing Through a Restart",
            symptom: "Dancer keeps going at the restart point while the rest of the room starts over from count 1, ending up 8 counts ahead.",
            cause: "Restarts are written in the step sheet but not obvious in the music — they require active memory, not passive listening.",
            fix: "Know exactly after which count the restart occurs and mark it mentally: \"When I finish count 24, I start over.\" Say it three times when learning.",
            danceIDs: ["tush-push", "boot-scootin-boogie"],
            moduleIDs: ["module-6"]
        ),
        CommonError(
            id: "incomplete-weight-transfer",
            category: .lineDance,
            title: "Not Completing Weight Transfers in a Vine",
            symptom: "The Grapevine looks like shuffling side-steps rather than four distinct steps with clear weight on each foot.",
            cause: "Moving fast without commitment — the foot crosses or steps but weight never fully lands, leaving the next step unstable.",
            fix: "Pause on each beat if necessary. Right-cross-left-touch: feel your full weight on each foot before the next one moves. Speed up only when the weight transfer is automatic.",
            danceIDs: ["electric-slide", "boot-scootin-boogie", "watermelon-crawl", "copperhead-road"],
            moduleIDs: ["module-4", "module-6"]
        ),
        CommonError(
            id: "rushing-quarter-turn",
            category: .lineDance,
            title: "Rushing Through the Quarter-Turn",
            symptom: "Dancer over-rotates or finishes the turn a beat early, ending up slightly off-axis from the rest of the room.",
            cause: "The turn feels like a single movement so it gets compressed, but it distributes across two or more counts.",
            fix: "Spread the quarter-turn evenly across its designated beats. Start rotating on the first beat, finish by the last — no sooner.",
            danceIDs: ["electric-slide", "copperhead-road", "boot-scootin-boogie"],
            moduleIDs: ["module-4", "module-6"]
        ),
        CommonError(
            id: "looking-at-feet",
            category: .lineDance,
            title: "Looking Down at Your Feet",
            symptom: "Head drops throughout the dance; dancer can't self-correct, can't see the room, and looks closed off.",
            cause: "Visual feedback from watching feet feels helpful while learning, but it prevents developing feel for the movement.",
            fix: "Trust your feet. Pick a spot on the opposite wall and keep your chin level. Feet will find their way once the pattern is in muscle memory.",
            danceIDs: ["electric-slide", "cupid-shuffle", "boot-scootin-boogie", "copperhead-road", "watermelon-crawl", "tush-push"],
            moduleIDs: ["module-4", "module-6"]
        ),
    ]

    // MARK: - Floor Navigation

    private static let florcraftErrors: [CommonError] = [
        CommonError(
            id: "stopping-on-floor",
            category: .floorcraft,
            title: "Stopping in the Middle of the Floor",
            symptom: "Couple pauses mid-song to talk or regroup while couples behind close the gap and nearly collide.",
            cause: "It feels natural to pause and discuss what went wrong. On a moving floor it creates a pile-up.",
            fix: "Exit toward the center of the floor or the edge before stopping. The progressive lanes — especially the outer rail — are always moving.",
            danceIDs: ["texas-two-step", "one-step", "country-waltz"],
            moduleIDs: ["module-0", "module-2"]
        ),
        CommonError(
            id: "wrong-direction",
            category: .floorcraft,
            title: "Traveling Against the Line of Dance",
            symptom: "Couple heads clockwise (into oncoming traffic) instead of counterclockwise with everyone else.",
            cause: "Couple turned 180° at a corner and forgot to re-orient, or never learned the floor's travel direction.",
            fix: "Line of Dance is always counterclockwise — imagine driving on the left side of a circular road. Memorize this before stepping onto any floor.",
            danceIDs: ["texas-two-step", "one-step", "country-waltz"],
            moduleIDs: ["module-0", "module-2"]
        ),
        CommonError(
            id: "spot-dance-wrong-lane",
            category: .floorcraft,
            title: "Spot Dancing in the Progressive Lane",
            symptom: "Non-traveling dance is performed along the outer rail, blocking Two-Step and Waltz couples.",
            cause: "Finding an open spot on the floor without thinking about which lane that spot belongs to.",
            fix: "Non-traveling dances (Swing, line dances) belong in the center. Progressive dances (Two-Step, Waltz, Polka) use the outer lane. Check your lane before you start.",
            danceIDs: ["east-coast-swing", "west-coast-swing", "electric-slide", "cupid-shuffle"],
            moduleIDs: ["module-0", "module-7"]
        ),
        CommonError(
            id: "not-looking-ahead",
            category: .floorcraft,
            title: "Not Looking Where You're Going",
            symptom: "Leader stares at partner or at feet, failing to see the couple ahead slowing down — leading to a rear collision.",
            cause: "New dancers fixate on their pattern. Floorcraft requires splitting attention between pattern, partner, and traffic.",
            fix: "Leaders: look over your partner's shoulder at the floor ahead. Anticipate gaps and closures. If a couple is slowing, step smaller or add a rotation to create distance.",
            danceIDs: ["texas-two-step", "one-step", "country-waltz"],
            moduleIDs: ["module-0", "module-2", "module-3"]
        ),
        CommonError(
            id: "large-moves-crowded",
            category: .floorcraft,
            title: "Wide Styling on a Crowded Floor",
            symptom: "Full-arm raises or wide side steps clip nearby dancers in tight floor conditions.",
            cause: "Styling learned in an empty studio doesn't scale to a packed floor on a Saturday night.",
            fix: "Reduce your footprint as the floor fills. Keep arms inside the frame, steps smaller, and rotate in place rather than traveling during busy moments.",
            danceIDs: ["texas-two-step", "one-step", "east-coast-swing"],
            moduleIDs: ["module-0", "module-5", "module-7"]
        ),
    ]
}
