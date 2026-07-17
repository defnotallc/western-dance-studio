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
        "electric-slide":      electricSlide,
        "cupid-shuffle":       cupidShuffle,
        "boot-scootin-boogie": bootScootinBoogie,
        "copperhead-road":     copperheadRoad,
        "watermelon-crawl":    watermelonCrawl,
        "tush-push":           tushPush,
        "cowboy-boogie":       cowboyBoogie,
        "cowboy-hustle":       cowboyHustle,
        "wobble":              wobble,
        "achy-breaky-heart":   achyBreakyHeart,
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

    // ─── Cowboy Boogie ─────────────────────────────────────────────────────
    // Choreographer: Unknown / Traditional
    // Music: Any up-tempo country, 120–140 BPM
    //   Commonly: "Boot Scootin' Boogie" — Brooks & Dunn; "Prop Me Up Beside the Jukebox" — Joe Diffie
    // Count: 28   Walls: 4   Level: Beginner
    //
    // A staple at beginner nights. Combines a vine, a walk-back, a Charleston
    // rock, forward shuffles, and a Monterey turn for the wall change.

    private static let cowboyBoogie = LineDanceStepSheet(
        danceID: "cowboy-boogie",
        totalCounts: 28,
        walls: 4,
        level: .beginner,
        choreographer: nil,
        steps: [
            LineDanceStep(
                countRange: "1-4",
                figure: "Vine Right",
                description: "Step R to right side; cross L behind R; step R to right side; touch L beside R (no weight).",
                note: "Keep the cross-behind low and flat — no need to lift the foot high."
            ),
            LineDanceStep(
                countRange: "5-8",
                figure: "Vine Left",
                description: "Step L to left side; cross R behind L; step L to left side; touch R beside L (no weight).",
                note: nil
            ),
            LineDanceStep(
                countRange: "9-12",
                figure: "Walk Back 4",
                description: "Step back R; step back L; step back R; touch L beside R (no weight). Travel backward 3 steps, then close.",
                note: "Keep your chest up and weight over the balls of your feet — do not lean back."
            ),
            LineDanceStep(
                countRange: "13-16",
                figure: "Charleston Rock",
                description: "Rock forward on L (count 13); replace weight back onto R (count 14); rock back on L (count 15); replace forward onto R (count 16).",
                note: "A rock is a weight transfer, not a full step — the free foot barely leaves the floor."
            ),
            LineDanceStep(
                countRange: "17&18",
                figure: "Shuffle Forward Right",
                description: "Step forward R (count 17); close L beside R on the & (half-beat); step forward R (count 18). Three steps, 2 beats.",
                note: nil
            ),
            LineDanceStep(
                countRange: "19&20",
                figure: "Shuffle Forward Left",
                description: "Step forward L (count 19); close R beside L on the &; step forward L (count 20).",
                note: nil
            ),
            LineDanceStep(
                countRange: "21-24",
                figure: "Monterey Quarter Turn",
                description: "Touch R toe to right side (count 21); step R beside L making a 1/4 turn right (count 22); touch L toe to left side (count 23); step L beside R (count 24, no turn).",
                note: "The turn happens entirely on count 22 as the right foot steps home. You are now facing the new wall."
            ),
            LineDanceStep(
                countRange: "25-28",
                figure: "Step & Stomps",
                description: "Step R to right side (count 25); stomp L beside R (no weight, count 26); stomp L again in place (count 27); hold (count 28).",
                note: "Stomps have no weight — the L foot contacts the floor with authority but the R foot continues bearing your weight."
            ),
        ],
        restarts: [],
        tags: []
    )

    // ─── Cowboy Hustle ─────────────────────────────────────────────────────
    // Choreographer: Unknown / Traditional
    // Music: Any 4/4 country, 115–130 BPM
    //   Commonly: "Achy Breaky Heart" — Billy Ray Cyrus; "Neon Moon" — Brooks & Dunn
    // Count: 20   Walls: 4   Level: Beginner
    //
    // One of the shortest and easiest true 4-wall line dances. Five clean figures
    // that repeat reliably every 20 counts. Excellent first dance for absolute beginners.

    private static let cowboyHustle = LineDanceStepSheet(
        danceID: "cowboy-hustle",
        totalCounts: 20,
        walls: 4,
        level: .beginner,
        choreographer: nil,
        steps: [
            LineDanceStep(
                countRange: "1-4",
                figure: "Two Steps Right",
                description: "Step R to right side; close L beside R (weight transfers). Step R to right side again; close L beside R. Two side-close pairs, traveling right.",
                note: "Keep the steps compact — this is not a grapevine. Both feet stay roughly hip-width throughout."
            ),
            LineDanceStep(
                countRange: "5-8",
                figure: "Two Steps Left",
                description: "Step L to left side; close R beside L. Step L again; close R beside L. Two side-close pairs, traveling left.",
                note: nil
            ),
            LineDanceStep(
                countRange: "9-12",
                figure: "Walk Back",
                description: "Step back R (count 9); step back L (count 10); step back R (count 11); touch L beside R — no weight (count 12).",
                note: nil
            ),
            LineDanceStep(
                countRange: "13-16",
                figure: "Shuffle Forward",
                description: "Step forward L (count 13); close R beside L on the & (half-beat); step forward L (count 14). Step forward R (count 15); close L on &; step forward R (count 16). Two forward shuffles, L-R-L then R-L-R.",
                note: "This is the syncopated 1-&-2, 3-&-4 shuffle. Stay light on your feet."
            ),
            LineDanceStep(
                countRange: "17-20",
                figure: "Quarter Turn Left + Stomp",
                description: "Step forward L making a 1/4 turn left (count 17); stomp R beside L (no weight, count 18); stomp R again (count 19); hold (count 20).",
                note: "The 1/4 turn on count 17 completes the wall change. You are now facing the next of the 4 walls."
            ),
        ],
        restarts: [],
        tags: []
    )

    // ─── Wobble ────────────────────────────────────────────────────────────
    // Choreographer: V.I.C. / Migos-era choreography (popularized ~2010)
    // Music: "Wobble Baby" — V.I.C. (2008); also danced to any groove-heavy country
    // Count: 24   Walls: 4   Level: Beginner
    //
    // The Wobble is anchored in hip isolations and a characteristic double-dip
    // at the top of each cycle. Very forgiving for beginners — timing matters more
    // than precision footwork. Popular at country bars and wedding receptions alike.

    private static let wobble = LineDanceStepSheet(
        danceID: "wobble",
        totalCounts: 24,
        walls: 4,
        level: .beginner,
        choreographer: "Popularized by V.I.C. (2010)",
        steps: [
            LineDanceStep(
                countRange: "1-4",
                figure: "Hip Dip Forward",
                description: "Shift hips forward-right, dipping low (count 1); recover center (count 2); shift hips forward-right and dip again (count 3); recover center (count 4). This is a hip isolation, not a step — feet stay planted.",
                note: "Bend your knees slightly to get into the dip. The 'wobble' comes from a controlled hip drop, not from bouncing on the balls of your feet."
            ),
            LineDanceStep(
                countRange: "5-8",
                figure: "Hip Dip Back",
                description: "Shift hips back-right and dip (count 5); recover (count 6); dip back-right again (count 7); recover (count 8).",
                note: nil
            ),
            LineDanceStep(
                countRange: "9-12",
                figure: "Hip Sway Right",
                description: "Sway hips right (count 9); sway left (count 10); sway right (count 11); sway left (count 12). Four alternating hip isolations.",
                note: "Keep the sways controlled and rhythmic — one full sway per count of music."
            ),
            LineDanceStep(
                countRange: "13-16",
                figure: "Walk Right 4",
                description: "Walk four steps to the right: step R (13), step L (14), step R (15), step L (16). Travel right along the floor.",
                note: nil
            ),
            LineDanceStep(
                countRange: "17-20",
                figure: "Walk Left 4",
                description: "Walk four steps back to the left: step L (17), step R (18), step L (19), step R (20).",
                note: nil
            ),
            LineDanceStep(
                countRange: "21-24",
                figure: "Quarter Turn + Stomps",
                description: "Step L forward making a 1/4 turn left (count 21); stomp R beside L (no weight, count 22); stomp R in place again (count 23); hold (count 24). You are now facing the new wall.",
                note: "Four 1/4 turns across 4 repetitions complete a full 360°."
            ),
        ],
        restarts: [],
        tags: []
    )

    // ─── Achy Breaky Heart ─────────────────────────────────────────────────
    // Choreographer: Melanie Greenfield (1992)
    // Music: "Achy Breaky Heart" — Billy Ray Cyrus (1992)
    // Count: 32   Walls: 4   Level: Intermediate
    //
    // One of the most famous country line dances ever recorded — helped launch
    // the country line dance craze of the 1990s. Greenfield's original is
    // intermediate primarily because of the hip-roll and pivot sequence in the
    // second half; the first half is accessible to beginners.

    private static let achyBreakyHeart = LineDanceStepSheet(
        danceID: "achy-breaky-heart",
        totalCounts: 32,
        walls: 4,
        level: .intermediate,
        choreographer: "Melanie Greenfield (1992)",
        steps: [
            LineDanceStep(
                countRange: "1-4",
                figure: "Walk R then L",
                description: "Step forward R (1); touch L behind R heel (2); step forward L (3); touch R behind L heel (4). Two walks with a touch-behind.",
                note: "The touch is literally the heel of the free foot tapping behind the heel of the standing foot — a characteristic shape of this dance."
            ),
            LineDanceStep(
                countRange: "5-8",
                figure: "Walk Right + Touch",
                description: "Step R to right side (5); step L beside R (6); step R to right side (7); touch L beside R — no weight (8). A side-close-side-touch pattern.",
                note: nil
            ),
            LineDanceStep(
                countRange: "9-12",
                figure: "Walk Left + Touch",
                description: "Step L to left side (9); step R beside L (10); step L to left side (11); touch R beside L — no weight (12).",
                note: nil
            ),
            LineDanceStep(
                countRange: "13-16",
                figure: "Vine Right with Kick",
                description: "Step R to right side (13); cross L behind R (14); step R to right side (15); kick L forward across (16).",
                note: "The kick on count 16 crosses in front of the body — it is a diagonal forward kick, not straight out to the side."
            ),
            LineDanceStep(
                countRange: "17-20",
                figure: "Vine Left with Kick",
                description: "Step L to left side (17); cross R behind L (18); step L to left side (19); kick R forward across (20).",
                note: nil
            ),
            LineDanceStep(
                countRange: "21-24",
                figure: "Hip Roll + Walk Back",
                description: "Roll your hips in a full circle (counts 21-22, 2 beats); walk back R (23); walk back L (24).",
                note: "The hip roll is the most challenging element for beginners: rotate the pelvis in a smooth circle over 2 counts. If uncertain, substitute 2 hip bumps right-left."
            ),
            LineDanceStep(
                countRange: "25-28",
                figure: "Scoot Forward",
                description: "Hop forward on R while scooting (count 25); hop on R again (count 26); hop on R (count 27); hop on R (count 28). Four consecutive forward scoots on the right foot while the L foot drags.",
                note: "Each scoot is a small jump forward landing on R — L foot brushes/drags along for the ride. Knees stay soft."
            ),
            LineDanceStep(
                countRange: "29-32",
                figure: "Half-Turn + Quarter Turn",
                description: "Step L forward (29); pivot 1/2 turn right on the balls of both feet (30, you now face the opposite wall); step L forward (31); pivot 1/4 turn right (32, you now face the new wall, having turned 3/4 total from your starting position on count 29).",
                note: "The turn sequence: pivot 180° on count 30, then 90° on count 32 = 270° total. After four complete repetitions of this dance you will have made four 270° turns, completing three full rotations — this is a characteristic that makes the wall math non-obvious at first. Focus on the music and let the turns become automatic."
            ),
        ],
        restarts: [],
        tags: []
    )
}
