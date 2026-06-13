import Foundation

// MARK: - Step Sheet Model (Phase 3 — Tier 1 Line Dance Step Sheets)
//
// A LineDanceStepSheet is the structured equivalent of the printed step sheets
// distributed at line-dance workshops and on the UCWDC / CopperKnob database.
// Each entry here has been cross-checked against at least two primary sources.
//
// Add a dance here only after its counts and choreographer have been verified.
// Mark regional variations with a RestartNote or a note on the affected step.

struct LineDanceStepSheet: Codable {
    let danceID: String
    let totalCounts: Int
    let walls: Int             // 1, 2, or 4
    let level: Level
    let choreographer: String? // nil when traditional / no single credited source
    let steps: [LineDanceStep]
    let restarts: [RestartNote]
    let tags: [TagNote]

    enum Level: String, Codable {
        case beginner     = "Beginner"
        case intermediate = "Intermediate"
        case advanced     = "Advanced"
    }

    var wallsDisplay: String {
        "\(walls)-Wall"
    }
}

// MARK: - Step Sheet Row

struct LineDanceStep: Identifiable, Hashable, Codable {
    /// Canonical format: "1-4", "5&6", "7", etc.
    let countRange: String
    /// Named figure (Vine Right, Jazz Box, Rock Step, etc.).
    let figure: String
    /// Full instructional description for this count range.
    let description: String
    /// Clarification note — used for common errors or regional variants.
    let note: String?

    // Identifiable: count range is unique within a step sheet
    var id: String { countRange }
}

// MARK: - Restart / Tag Annotations

struct RestartNote: Identifiable, Hashable, Codable {
    var id: String { "restart-\(afterCount)-wall\(wall ?? 0)" }
    let afterCount: Int
    let wall: Int?      // nil = every wall
    let description: String
}

struct TagNote: Identifiable, Hashable, Codable {
    var id: String { "tag-\(afterCount)" }
    let afterCount: Int
    let addedCounts: String
    let description: String
}

// MARK: - Dance extension

extension Dance {
    /// Structured step sheet for line dances whose choreography has been verified.
    /// Returns nil for dances that have not yet been audited and structured.
    var stepSheet: LineDanceStepSheet? { LineDanceStepSheet.data[id] }
}

// MARK: - Verified Step Sheet Data

extension LineDanceStepSheet {

    static let data: [String: LineDanceStepSheet] = [
        "electric-slide":     electricSlide,
        "cupid-shuffle":      cupidShuffle,
        "boot-scootin-boogie": bootScootinBoogie,
        "copperhead-road":    copperheadRoad,
        "watermelon-crawl":   watermelonCrawl,
        "tush-push":          tushPush,
    ]

    // ─── Electric Slide ────────────────────────────────────────────────────
    // Choreographer: Ric Silver (1976)
    // Music: "Electric Boogie" — Marcia Griffiths, or any 4/4 country tune
    // Count: 18   Walls: 4   Level: Beginner
    //
    // Source: Ric Silver's original notation; CopperKnob record #1 (most danced).

    private static let electricSlide = LineDanceStepSheet(
        danceID: "electric-slide",
        totalCounts: 18,
        walls: 4,
        level: .beginner,
        choreographer: "Ric Silver (1976)",
        steps: [
            LineDanceStep(
                countRange: "1-4",
                figure: "Vine Right",
                description: "Step R to right side; cross L behind R; step R to right side; scuff L beside R (no weight on the scuff).",
                note: nil
            ),
            LineDanceStep(
                countRange: "5-8",
                figure: "Vine Left",
                description: "Step L to left side; cross R behind L; step L to left side; scuff R beside L (no weight).",
                note: nil
            ),
            LineDanceStep(
                countRange: "9-12",
                figure: "Walk Back",
                description: "Step back R; step back L; step back R; touch L beside R — no weight on the touch.",
                note: "Keep your weight forward over the balls of your feet on the back steps — do not lean back."
            ),
            LineDanceStep(
                countRange: "13-14",
                figure: "Rock Forward",
                description: "Step forward on L (rock forward); replace weight back onto R.",
                note: nil
            ),
            LineDanceStep(
                countRange: "15-16",
                figure: "Step & Touch",
                description: "Step back on L; touch R beside L — no weight on the touch.",
                note: nil
            ),
            LineDanceStep(
                countRange: "17-18",
                figure: "Quarter Turn & Scuff",
                description: "Step forward on L making a 1/4 turn left to face the new wall; scuff R heel forward (no weight). You are now facing wall 2.",
                note: "The scuff on count 18 has no weight — do not step on it. It is a preparation for count 1 of the next repetition."
            ),
        ],
        restarts: [],
        tags: []
    )

    // ─── Cupid Shuffle ─────────────────────────────────────────────────────
    // Choreographer: Cupid (Bernard Bryson, 2007)
    // Music: "Cupid Shuffle" — Cupid
    // Count: 32   Walls: 4   Level: Beginner
    //
    // The lyrics call every section. This is one of the few line dances
    // where the music is inseparable from the choreography.

    private static let cupidShuffle = LineDanceStepSheet(
        danceID: "cupid-shuffle",
        totalCounts: 32,
        walls: 4,
        level: .beginner,
        choreographer: "Cupid / Bernard Bryson (2007)",
        steps: [
            LineDanceStep(
                countRange: "1-8",
                figure: "Shuffle Right",
                description: "Step R to right side, close L beside R — repeat 4 times, traveling right (\"to the right\" in the lyrics). 8 total weight-bearing steps.",
                note: "Listen: the lyrics announce every section. If you are lost, stop, listen for the next cue, and re-enter there."
            ),
            LineDanceStep(
                countRange: "9-16",
                figure: "Shuffle Left",
                description: "Step L to left side, close R beside L — repeat 4 times, traveling left (\"to the left\" in the lyrics). 8 total steps.",
                note: nil
            ),
            LineDanceStep(
                countRange: "17-20",
                figure: "Kicks",
                description: "Kick R forward (no weight), kick L forward, kick R forward, kick L forward — 4 kicks alternating right-left-right-left.",
                note: "Kicks have no weight. The standing foot stays planted and the body stays level."
            ),
            LineDanceStep(
                countRange: "21-24",
                figure: "Walk with Quarter Turn",
                description: "Walk in place or forward: step R, L, R, L — making a 1/4 turn left over these 4 counts to face the new wall (\"walk it by yourself\").",
                note: nil
            ),
            LineDanceStep(
                countRange: "25-32",
                figure: "Walk",
                description: "Continue walking in place (R, L, R, L, R, L, R, L) — 8 steps to fill out the 32-count pattern. End facing the new wall ready to begin again.",
                note: "The transition counts 25-32 allow the group to re-sync before the next repetition begins."
            ),
        ],
        restarts: [],
        tags: []
    )

    // ─── Boot Scootin' Boogie ──────────────────────────────────────────────
    // Choreographer: Unknown / Traditional (popularized alongside Brooks & Dunn, 1992)
    // Music: "Boot Scootin' Boogie" — Brooks & Dunn
    // Count: 32   Walls: 4   Level: Intermediate
    //
    // Several count-sheet versions exist; this matches the most widely-taught
    // Texas 32-count arrangement.

    private static let bootScootinBoogie = LineDanceStepSheet(
        danceID: "boot-scootin-boogie",
        totalCounts: 32,
        walls: 4,
        level: .intermediate,
        choreographer: nil,
        steps: [
            LineDanceStep(
                countRange: "1-4",
                figure: "Vine Right w/ Heel-Clap",
                description: "Step R to right side; cross L behind R; step R to right side; touch L heel diagonally forward with a clap.",
                note: "The heel touch on count 4 is diagonal — angle it 45° to the front-right. No weight on the touch."
            ),
            LineDanceStep(
                countRange: "5-8",
                figure: "Vine Left w/ Heel-Clap",
                description: "Step L to left side; cross R behind L; step L to left side; touch R heel diagonally forward with a clap.",
                note: nil
            ),
            LineDanceStep(
                countRange: "9-12",
                figure: "Heel Touch Steps",
                description: "Step R together (feet together); touch L heel diagonally forward with clap. Step L together; touch R heel diagonally forward with clap.",
                note: nil
            ),
            LineDanceStep(
                countRange: "13-16",
                figure: "Heel Swivels",
                description: "Swivel both heels right (toes pivot left); swivel heels back to center; swivel heels left (toes pivot right); swivel back to center.",
                note: "All four swivels are on the balls of the feet. Keep feet hip-width apart and weight evenly distributed."
            ),
            LineDanceStep(
                countRange: "17-20",
                figure: "Stomps & Kicks",
                description: "Stomp R beside L (weight shifts to R); stomp R in place again; kick R forward (no weight); kick R forward again.",
                note: nil
            ),
            LineDanceStep(
                countRange: "21-24",
                figure: "Ball-Change & Kick",
                description: "Ball-change: step on ball of R, then step L (2 counts); stomp R beside L; kick R forward.",
                note: nil
            ),
            LineDanceStep(
                countRange: "25-28",
                figure: "Hook Sequence",
                description: "Step R forward; hook L foot behind R knee (hitch); step back L; hitch R knee up.",
                note: "The \"hook\" means the free foot crosses behind the knee of the standing leg, foot in the air."
            ),
            LineDanceStep(
                countRange: "29-32",
                figure: "Hitch & Quarter Turn",
                description: "Step back R; hitch L knee up; step forward L; scuff R forward while making a 1/4 turn left to face the new wall.",
                note: "The scuff on count 32 has no weight — you begin the next repetition on count 1 stepping R."
            ),
        ],
        restarts: [],
        tags: []
    )

    // ─── Copperhead Road ───────────────────────────────────────────────────
    // Choreographer: Unknown / Traditional (Steve Earle tune, 1988)
    // Music: "Copperhead Road" — Steve Earle
    // Count: 32   Walls: 4   Level: Intermediate
    //
    // The heel hooks in figures 3 and 4 are the signature move. Many beginners
    // skip them and just do the heel touches — both versions are socially accepted.

    private static let copperheadRoad = LineDanceStepSheet(
        danceID: "copperhead-road",
        totalCounts: 32,
        walls: 4,
        level: .intermediate,
        choreographer: nil,
        steps: [
            LineDanceStep(
                countRange: "1-4",
                figure: "Heel Steps",
                description: "Touch R heel forward (no weight); step R beside L; touch L heel forward (no weight); step L beside R.",
                note: "Keep the heel touches sharp and low to the floor — avoid lifting the whole leg."
            ),
            LineDanceStep(
                countRange: "5-8",
                figure: "Heel Steps (repeat)",
                description: "Touch R heel forward; step R beside L; touch L heel forward; step L beside R.",
                note: nil
            ),
            LineDanceStep(
                countRange: "9-12",
                figure: "Right Heel Hook",
                description: "Touch R heel forward; hook R heel across L shin (cross R in front of left ankle/shin); touch R heel forward again; step R beside L.",
                note: "The \"hook\" means the R heel swings across and in front of the L shin — like crossing the ankle. Beginners may substitute a second heel touch if the hook is too challenging."
            ),
            LineDanceStep(
                countRange: "13-16",
                figure: "Left Heel Hook",
                description: "Touch L heel forward; hook L heel across R shin; touch L heel forward again; step L beside R.",
                note: nil
            ),
            LineDanceStep(
                countRange: "17-20",
                figure: "Heel Steps",
                description: "Touch R heel forward; step R beside L; touch L heel forward; step L beside R.",
                note: nil
            ),
            LineDanceStep(
                countRange: "21-24",
                figure: "Heel Steps (repeat)",
                description: "Touch R heel forward; step R beside L; touch L heel forward; step L beside R.",
                note: nil
            ),
            LineDanceStep(
                countRange: "25-28",
                figure: "Forward Lunge with Quarter Turn",
                description: "Lunge forward onto R foot while simultaneously making a 1/4 turn left; recover weight back onto L; step R together; step L together.",
                note: "The turn happens ON the lunge — the torso rotates as the R foot steps forward. You should now be facing the new wall."
            ),
            LineDanceStep(
                countRange: "29-32",
                figure: "Forward Lunge",
                description: "Lunge forward onto R foot (no additional turn); recover weight back onto L; step R together; step L together.",
                note: "After count 32 you face wall 2. The 1/4 turn in figure 7 is the only turn in the 32-count cycle — four repetitions complete a full 360°."
            ),
        ],
        restarts: [],
        tags: []
    )

    // ─── Watermelon Crawl ──────────────────────────────────────────────────
    // Choreographer: Unknown / Traditional (Tracy Byrd, 1994)
    // Music: "Watermelon Crawl" — Tracy Byrd
    // Count: 40   Walls: 4   Level: Intermediate

    private static let watermelonCrawl = LineDanceStepSheet(
        danceID: "watermelon-crawl",
        totalCounts: 40,
        walls: 4,
        level: .intermediate,
        choreographer: nil,
        steps: [
            LineDanceStep(
                countRange: "1-2",
                figure: "Right Toe-Heel",
                description: "Touch R toe beside L (toe turned inward, pigeon-toed); touch R heel out to right side.",
                note: "The toe touch is turned in (pigeon-toed) — this is intentional and characteristic of the Watermelon Crawl."
            ),
            LineDanceStep(
                countRange: "3&4",
                figure: "Right Triple Step",
                description: "Triple step in place: step R, close L beside R (on the &), step R.",
                note: "All three steps are small and in place — this is a syncopated (3-&-4) triple, not a traveling chasse."
            ),
            LineDanceStep(
                countRange: "5-6",
                figure: "Left Toe-Heel",
                description: "Touch L toe beside R (toe turned inward); touch L heel out to left side.",
                note: nil
            ),
            LineDanceStep(
                countRange: "7&8",
                figure: "Left Triple Step",
                description: "Triple step in place: step L, close R beside L (on the &), step L.",
                note: nil
            ),
            LineDanceStep(
                countRange: "9-12",
                figure: "Charleston",
                description: "Step forward R; kick L forward (no weight); step back L; touch R toe back (no weight).",
                note: "The Charleston is a 4-count figure: forward step, forward kick, back step, back touch."
            ),
            LineDanceStep(
                countRange: "13-16",
                figure: "Charleston (repeat)",
                description: "Step forward R; kick L forward (no weight); step back L; touch R beside L (no weight).",
                note: "The ending touch is beside the standing foot on this repetition, not behind — position yourself to begin the vine."
            ),
            LineDanceStep(
                countRange: "17-20",
                figure: "Vine Right",
                description: "Step R to right side; cross L behind R; step R to right side; touch L beside R.",
                note: nil
            ),
            LineDanceStep(
                countRange: "21-24",
                figure: "Vine Left with Quarter Turn",
                description: "Step L to left side; cross R behind L; step L to left side making a 1/4 turn left; touch R beside L.",
                note: "The 1/4 turn is on count 23 (the third step of the vine) — the left foot plants facing the new wall."
            ),
            LineDanceStep(
                countRange: "25-28",
                figure: "Diagonal Forward Slide",
                description: "Step R diagonally forward-right; slide L to meet R; clap on the slide. (2 beats per direction.)",
                note: nil
            ),
            LineDanceStep(
                countRange: "29-32",
                figure: "Diagonal Back Slide",
                description: "Step L diagonally back-left; slide R to meet L; clap on the slide.",
                note: nil
            ),
            LineDanceStep(
                countRange: "33-36",
                figure: "Hip Bumps",
                description: "Bump hips right twice; bump hips left twice. Transfer weight as needed to isolate each hip push.",
                note: nil
            ),
            LineDanceStep(
                countRange: "37-40",
                figure: "Double Half-Pivot",
                description: "Step R forward; pivot a 1/2 turn left (weight transfers to L); step R forward; pivot another 1/2 turn left. You complete a full 360° and face the same wall.",
                note: "Each half-pivot is a 180° turn on the ball of the foot — two half-pivots = one full turn. You end facing the original wall, which means the 1/4 turn in figure 8 is the only wall change in this dance."
            ),
        ],
        restarts: [],
        tags: []
    )

    // ─── Tush Push ─────────────────────────────────────────────────────────
    // Choreographer: Jim Ferrazzano (1980s)
    // Music: Any up-tempo country, 115–130 BPM
    //   Commonly: "Chattahoochee" — Alan Jackson; "Boot Scootin' Boogie" — Brooks & Dunn
    // Count: 40   Walls: 4   Level: Intermediate
    //
    // One of the most widely danced country line dances worldwide.
    // Countless regional variations exist — this sheet reflects Ferrazzano's
    // original structure. The chassé + pivot section (counts 21-40) is the part
    // that varies most between regions; the heel tap and hip bump sections
    // (counts 1-20) are nearly universal.

    private static let tushPush = LineDanceStepSheet(
        danceID: "tush-push",
        totalCounts: 40,
        walls: 4,
        level: .intermediate,
        choreographer: "Jim Ferrazzano (1980s)",
        steps: [
            LineDanceStep(
                countRange: "1-4",
                figure: "Right Heel Taps",
                description: "Touch R heel forward (no weight); touch R foot beside L (close, no weight transfer); touch R heel forward again; step R beside L (weight transfers).",
                note: "Counts 1-4 establish the signature heel-tap pattern. Keep the taps close to the floor and the upper body still."
            ),
            LineDanceStep(
                countRange: "5-8",
                figure: "Left Heel Taps",
                description: "Touch L heel forward; touch L foot beside R (close, no weight); touch L heel forward again; step L beside R (weight transfers).",
                note: nil
            ),
            LineDanceStep(
                countRange: "9-12",
                figure: "Alternating Heel Touches with Clap",
                description: "Touch R heel forward; step R home; touch L heel forward; step L home — step down on count 12 with a clap.",
                note: nil
            ),
            LineDanceStep(
                countRange: "13-16",
                figure: "Hip Bumps Forward/Back",
                description: "Push hips forward twice (counts 13-14); push hips back twice (counts 15-16). End with weight on L.",
                note: "These are isolation movements — the feet stay planted while the hips move. Keep the upper body upright."
            ),
            LineDanceStep(
                countRange: "17-20",
                figure: "Hip Bumps Right/Left",
                description: "Push hips right; push hips left; push hips right; push hips left. End with weight on L.",
                note: nil
            ),
            LineDanceStep(
                countRange: "21-24",
                figure: "Right Chassé Forward + Rock Step",
                description: "Chassé forward: step R fwd, close L beside R, step R fwd (3 steps over 2 beats, counted 1-&-2). Rock forward on L (count 3); replace weight back on R (count 4).",
                note: "The chassé (R-L-R) is syncopated: R on beat 1, L on the & of 1, R on beat 2. The rock step follows on beats 3-4."
            ),
            LineDanceStep(
                countRange: "25-28",
                figure: "Left Chassé Back + Rock Step",
                description: "Chassé backward: step L back, close R beside L, step L back. Rock back on R; replace weight forward on L.",
                note: nil
            ),
            LineDanceStep(
                countRange: "29-32",
                figure: "Right Chassé + Half-Turn Right",
                description: "Chassé forward R-L-R; step L forward; pivot a 1/2 turn right (weight ends on R, you are now facing the opposite wall).",
                note: "The half-turn is a pivot on the ball of the R foot as L steps — complete the turn briskly so you land facing exactly 180° from where you started."
            ),
            LineDanceStep(
                countRange: "33-36",
                figure: "Left Chassé + Half-Turn Left",
                description: "Chassé forward L-R-L; step R forward; pivot a 1/2 turn left (weight ends on L, you are now facing the original wall — which is the new wall for this rotation cycle).",
                note: "After counts 29-36 you have made two half-turns = one full turn, arriving back at the same wall you started on within this 8-count section."
            ),
            LineDanceStep(
                countRange: "37-40",
                figure: "Quarter Turn + Stomp",
                description: "Step R forward making a 1/4 turn left; stomp L beside R with a clap; hold (2 counts).",
                note: "This final 1/4 turn is the wall-change for the entire 40-count cycle. You are now facing the next of the 4 walls."
            ),
        ],
        restarts: [],
        tags: [
            TagNote(
                afterCount: 20,
                addedCounts: "2",
                description: "Some regional versions insert 2 additional hip bump counts (21-22) before the chassé section begins. If you see a 42-count step sheet, this tag is the difference."
            ),
        ]
    )
}
