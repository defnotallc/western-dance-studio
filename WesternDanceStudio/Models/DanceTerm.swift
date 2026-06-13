import Foundation

// MARK: - Canonical Glossary Model (Phase 1.1 — Canonical Glossary)
//
// Every term used anywhere in the app — in a lesson, step description, video
// subtitle, or notification — must exist here first. This is the single source
// of truth. Update here; the change propagates everywhere.
//
// Role language standard (Phase 1.2): "leader" and "follower" are the only
// role terms used throughout all content. Gender-specific language ("gentleman",
// "lady", "man", "lady") is not used anywhere in instructional content.

struct DanceTerm: Identifiable, Hashable, Codable {
    var id: String { term }
    let term: String
    let category: TermCategory

    /// Plain-English definition, accessible to a complete beginner (1–3 sentences).
    let definition: String

    /// Deeper technical context for intermediate or curious learners.
    let technicalNote: String?

    /// What this term does NOT mean — addresses the most common misconception.
    let commonMisconceptions: String?

    /// Term names that are closely related, for cross-referencing in the UI.
    let relatedTerms: [String]

    enum TermCategory: String, CaseIterable, Identifiable, Codable, Hashable {
        case musicAndTiming   = "Music & Timing"
        case footwork         = "Footwork"
        case partnerDance     = "Partner Dancing"
        case lineDance        = "Line Dancing"
        case danceStyles      = "Dance Styles"
        case venueAndEtiquette = "Venue & Etiquette"
        var id: String { rawValue }
    }
}

// MARK: - Full Canonical Term List

extension DanceTerm {
    static let allTerms: [DanceTerm] = [

        // ─── MUSIC & TIMING ────────────────────────────────────────────────

        DanceTerm(
            term: "Beat",
            category: .musicAndTiming,
            definition: "The steady pulse of the music — the regular thud you naturally tap your foot to. Every other step in country dancing lands on a beat.",
            technicalNote: "In country music the kick drum produces beats 1 and 3; the snare drum accents beats 2 and 4. Together they create the clear pulse dancers follow. Most country music is in 4/4 time: four beats per measure.",
            commonMisconceptions: "The beat is not the same as the melody or the lyrics. If you are counting syllables in the words you are listening to the wrong layer of the music.",
            relatedTerms: ["Measure", "BPM", "Downbeat", "Phrase"]
        ),

        DanceTerm(
            term: "BPM",
            category: .musicAndTiming,
            definition: "Beats Per Minute — the speed of the music. A waltz runs around 90–120 BPM; Texas Two-Step at social venues typically runs 150–190 BPM.",
            technicalNote: "Beginners should practice at the low end of the BPM range for their dance and work up gradually. Rushing to social tempo before technique is solid creates compensatory habits that are very hard to unlearn.",
            commonMisconceptions: nil,
            relatedTerms: ["Beat", "Tempo"]
        ),

        DanceTerm(
            term: "Count",
            category: .musicAndTiming,
            definition: "The number you say aloud or think to track your position in a step pattern. For Two-Step: '1-2-3-4'. For waltz: '1-2-3'.",
            technicalNote: nil,
            commonMisconceptions: "Counting should be a temporary learning aid, not a permanent habit. Advanced dancers internalize the counts and listen to the music instead.",
            relatedTerms: ["Beat", "Measure", "Quick", "Slow"]
        ),

        DanceTerm(
            term: "Downbeat",
            category: .musicAndTiming,
            definition: "Beat 1 of each measure — the strongest beat in the bar, typically the kick drum. Starting a new pattern on the downbeat is the foundation of musical dancing.",
            technicalNote: "Identifying the downbeat is a learned skill. Practice with a song you know well and listen for the kick drum to thump and then count '1-2-3-4' from there.",
            commonMisconceptions: "The downbeat is not always the loudest moment in a song. In some country arrangements the verse is quiet but beat 1 is still felt as the anchor.",
            relatedTerms: ["Beat", "Measure", "Phrase"]
        ),

        DanceTerm(
            term: "Measure",
            category: .musicAndTiming,
            definition: "A group of beats. In most country music (4/4 time) a measure contains four beats. In waltz (3/4 time) it contains three beats.",
            technicalNote: "The Texas Two-Step QQ-SS pattern spans six beats, which does not divide evenly into four-beat measures. After four measures the pattern has completed 2⅔ cycles. This non-alignment is correct — it is a feature of Two-Step, not a counting error.",
            commonMisconceptions: nil,
            relatedTerms: ["Beat", "Phrase", "Quick", "Slow"]
        ),

        DanceTerm(
            term: "Metronome",
            category: .musicAndTiming,
            definition: "A device or app that produces a steady click at a set BPM to help you lock in the exact tempo while practicing alone.",
            technicalNote: nil,
            commonMisconceptions: nil,
            relatedTerms: ["BPM", "Tempo"]
        ),

        DanceTerm(
            term: "Phrase",
            category: .musicAndTiming,
            definition: "A musical sentence, typically eight measures (32 beats) long. Dancing with awareness of phrases — starting new patterns at phrase boundaries — is the beginning of musicality.",
            technicalNote: "Verses and choruses usually begin at phrase boundaries. A dancer who can feel the phrase can anticipate when the music will shift and make the dance feel connected to the song rather than just mechanically on the beat.",
            commonMisconceptions: "Dancing on the beat and dancing musically are different skills. Being on the beat is necessary; responding to phrases and dynamics is musicality.",
            relatedTerms: ["Beat", "Measure", "Downbeat"]
        ),

        DanceTerm(
            term: "Quick",
            category: .musicAndTiming,
            definition: "A step that occupies exactly one beat of music. In Texas Two-Step the pattern begins with two Quicks: Quick-Quick-Slow-Slow.",
            technicalNote: "A Quick requires a full, complete weight transfer. The most common error is rushing or shuffling the Quicks — each one must land cleanly on its beat.",
            commonMisconceptions: "Quick does not mean hurried or small. A Quick step should be the same size and quality as any other step; it simply occupies less time.",
            relatedTerms: ["Slow", "Measure", "Quick Quick Slow Slow", "Weight Transfer"]
        ),

        DanceTerm(
            term: "Quick Quick Slow Slow",
            category: .musicAndTiming,
            definition: "The core timing pattern of Texas Two-Step: two one-beat steps followed by two two-beat steps. Abbreviated QQSS. One full cycle occupies six beats of music.",
            technicalNote: "The Slows are NOT a step-then-hold. Both beats of each Slow are occupied by continuous body travel — the dancer steps on beat one of the Slow and glides through beat two without placing a new foot.",
            commonMisconceptions: "Do not think of the Slows as 'step-pause.' The body never pauses in good Two-Step — it glides continuously, with steps occurring at the Quick and the beginning of each Slow.",
            relatedTerms: ["Quick", "Slow", "Texas Two-Step"]
        ),

        DanceTerm(
            term: "Slow",
            category: .musicAndTiming,
            definition: "A step that occupies two beats of music. In Texas Two-Step, two Slows follow the two Quicks.",
            technicalNote: "The weight transfers on beat one of the Slow. The body continues moving through beat two. The foot does not step again until the next count begins.",
            commonMisconceptions: "A Slow is not a step followed by a hold or a pause. It is a step with continuous body travel through the second beat.",
            relatedTerms: ["Quick", "Quick Quick Slow Slow", "Weight Transfer"]
        ),

        DanceTerm(
            term: "Syncopation",
            category: .musicAndTiming,
            definition: "Dividing a beat into two half-beats — counted '1-and-2' — to insert an extra step. Creates a triple-step or shuffle feel.",
            technicalNote: "The '&' (and-count) is a half-beat between two whole beats. Triple Two-Step and East Coast Swing make extensive use of syncopation.",
            commonMisconceptions: nil,
            relatedTerms: ["Triple Step", "Shuffle", "Beat"]
        ),

        DanceTerm(
            term: "Tempo",
            category: .musicAndTiming,
            definition: "The speed of the music, measured in BPM. A slow waltz might be 90 BPM; a fast Two-Step can reach 200 BPM at some competitions.",
            technicalNote: nil,
            commonMisconceptions: nil,
            relatedTerms: ["BPM", "Beat"]
        ),

        // ─── FOOTWORK ──────────────────────────────────────────────────────

        DanceTerm(
            term: "Anchor Step",
            category: .footwork,
            definition: "A triple step (step-step-step) at the end of a West Coast Swing pattern that re-establishes connection between partners before the next figure begins.",
            technicalNote: nil,
            commonMisconceptions: nil,
            relatedTerms: ["Triple Step", "Connection", "West Coast Swing"]
        ),

        DanceTerm(
            term: "Ball Change",
            category: .footwork,
            definition: "A quick weight transfer from the ball of one foot back to the other foot. Counted as two rapid steps: '&1' or 'and-1'.",
            technicalNote: "The ball of the foot — not the toe and not the heel — contacts the floor. The movement is compact and sharp.",
            commonMisconceptions: nil,
            relatedTerms: ["Kick Ball Change", "Weight Transfer"]
        ),

        DanceTerm(
            term: "Box Step",
            category: .footwork,
            definition: "Six steps that trace a square on the floor: forward, side, close, back, side, close. Used in Rumba-style movements and some line dances.",
            technicalNote: nil,
            commonMisconceptions: nil,
            relatedTerms: ["Weight Transfer"]
        ),

        DanceTerm(
            term: "Brush",
            category: .footwork,
            definition: "Swinging the free foot so the ball lightly grazes the floor as the leg passes through. No weight is placed on the brushing foot.",
            technicalNote: nil,
            commonMisconceptions: "A brush has no weight on it. If weight is transferred, it is a step, not a brush.",
            relatedTerms: ["Scuff", "Touch"]
        ),

        DanceTerm(
            term: "Chasse",
            category: .footwork,
            definition: "A syncopated side step pattern: step to the side, close the other foot, step to the side again. Counted '1-and-2'.",
            technicalNote: nil,
            commonMisconceptions: nil,
            relatedTerms: ["Triple Step", "Syncopation"]
        ),

        DanceTerm(
            term: "Cross Step",
            category: .footwork,
            definition: "A step where one foot crosses in front of or behind the other foot. Described as 'cross over' (in front) or 'cross behind'.",
            technicalNote: nil,
            commonMisconceptions: nil,
            relatedTerms: ["Grapevine"]
        ),

        DanceTerm(
            term: "Grapevine",
            category: .footwork,
            definition: "A traveling side-step sequence: step to the side, cross behind, step to the side, touch (or kick or stomp). Used in nearly every line dance.",
            technicalNote: "A vine to the right is: right-foot side, left-foot cross behind, right-foot side, left-foot touch.",
            commonMisconceptions: nil,
            relatedTerms: ["Cross Step", "Touch"]
        ),

        DanceTerm(
            term: "Heel",
            category: .footwork,
            definition: "Placing the heel of the free foot on the floor without transferring weight. A common line-dance accent.",
            technicalNote: nil,
            commonMisconceptions: nil,
            relatedTerms: ["Touch", "Heel Strut"]
        ),

        DanceTerm(
            term: "Heel Strut",
            category: .footwork,
            definition: "A two-count step: place the heel on beat 1 with no weight, then roll onto the ball of the foot on beat 2 and transfer weight. Classic country styling.",
            technicalNote: nil,
            commonMisconceptions: nil,
            relatedTerms: ["Heel", "Weight Transfer"]
        ),

        DanceTerm(
            term: "Hip Bump",
            category: .footwork,
            definition: "Pushing one hip out sharply to the side on the beat. A signature move in the Tush Push and other hip-emphasis dances.",
            technicalNote: nil,
            commonMisconceptions: nil,
            relatedTerms: []
        ),

        DanceTerm(
            term: "Hitch",
            category: .footwork,
            definition: "Lifting one knee up to approximately hip height on a beat, with the foot hanging behind. A sharp, clean accent move.",
            technicalNote: nil,
            commonMisconceptions: nil,
            relatedTerms: ["Kick"]
        ),

        DanceTerm(
            term: "Hop",
            category: .footwork,
            definition: "A small jump off one foot, landing on the same foot. Used in Schottische patterns and some line dances.",
            technicalNote: nil,
            commonMisconceptions: nil,
            relatedTerms: []
        ),

        DanceTerm(
            term: "Jazz Box",
            category: .footwork,
            definition: "A four-count pattern that traces a box: cross one foot over the other, step back with the free foot, step to the side, bring feet together. Used in many line dances.",
            technicalNote: "A jazz box to the right is: right cross over left, left step back, right step right, left close to right.",
            commonMisconceptions: nil,
            relatedTerms: ["Cross Step"]
        ),

        DanceTerm(
            term: "Kick",
            category: .footwork,
            definition: "Extending the free leg forward (or to the side or back) with a controlled, sharp motion. No weight is placed on the kicking foot.",
            technicalNote: nil,
            commonMisconceptions: "A kick has no weight on it. Placing weight on a kick turns it into a step.",
            relatedTerms: ["Kick Ball Change", "Touch"]
        ),

        DanceTerm(
            term: "Kick Ball Change",
            category: .footwork,
            definition: "A three-part count: kick forward (no weight), step on the ball of the same foot, then change weight to the other foot. Counted '1-and-2'.",
            technicalNote: nil,
            commonMisconceptions: nil,
            relatedTerms: ["Kick", "Ball Change", "Syncopation"]
        ),

        DanceTerm(
            term: "Pivot",
            category: .footwork,
            definition: "A turn executed on the ball of one foot without lifting it from the floor. Pivots can be quarter, half, or full turns.",
            technicalNote: nil,
            commonMisconceptions: nil,
            relatedTerms: ["Pivot Turn"]
        ),

        DanceTerm(
            term: "Pivot Turn",
            category: .footwork,
            definition: "A half turn or quarter turn in which both feet rotate on their balls simultaneously. Used in line dances to change the direction you face.",
            technicalNote: nil,
            commonMisconceptions: nil,
            relatedTerms: ["Pivot", "Wall"]
        ),

        DanceTerm(
            term: "Rock Step",
            category: .footwork,
            definition: "Transferring weight onto one foot (the rock) and then immediately back to the other foot (the replace). Foundation of Swing dancing.",
            technicalNote: nil,
            commonMisconceptions: nil,
            relatedTerms: ["Weight Transfer"]
        ),

        DanceTerm(
            term: "Scuff",
            category: .footwork,
            definition: "Brushing the heel of the free foot along the floor as the leg swings forward. No weight is placed on the scuffing foot.",
            technicalNote: nil,
            commonMisconceptions: nil,
            relatedTerms: ["Brush", "Heel"]
        ),

        DanceTerm(
            term: "Shuffle",
            category: .footwork,
            definition: "A triple step counted '1-and-2': three steps taken over two beats. The nickname Triple Two-Step (Fort Worth Shuffle) comes from this pattern.",
            technicalNote: nil,
            commonMisconceptions: nil,
            relatedTerms: ["Triple Step", "Triple Two-Step"]
        ),

        DanceTerm(
            term: "Stomp",
            category: .footwork,
            definition: "Bringing the foot down firmly on the floor with weight. Distinguished from a 'stomp-up' which has no weight transfer.",
            technicalNote: nil,
            commonMisconceptions: nil,
            relatedTerms: []
        ),

        DanceTerm(
            term: "Touch",
            category: .footwork,
            definition: "Placing the ball or toe of the free foot lightly on the floor — or beside the standing foot — without transferring weight.",
            technicalNote: nil,
            commonMisconceptions: "A touch has no weight on it. If weight transfers, the step must be counted as a weight-bearing step.",
            relatedTerms: ["Brush", "Heel"]
        ),

        DanceTerm(
            term: "Triple Step",
            category: .footwork,
            definition: "Three small steps taken over two beats of music, counted '1-and-2'. The foundation of Triple Two-Step and East Coast Swing.",
            technicalNote: "The middle step (the 'and') lands on a half-beat between beats and is typically a small closing step. Each of the three steps carries full weight.",
            commonMisconceptions: nil,
            relatedTerms: ["Shuffle", "Syncopation", "Triple Two-Step"]
        ),

        DanceTerm(
            term: "Weight Transfer",
            category: .footwork,
            definition: "Shifting your full body weight onto one foot so the other foot is completely free. Every dance step requires a complete weight transfer — if you cannot lift the free foot without losing balance, the transfer is incomplete.",
            technicalNote: "A complete weight transfer begins in the center of gravity (approximately the pelvis), not in the foot. The center moves toward the stepping foot before the foot lands. On forward steps, the heel contacts the floor first and weight rolls through to the ball. On backward steps, the ball contacts first and weight settles back to the heel.",
            commonMisconceptions: "Weight transfer is not the same as leaning. The body should remain vertically centered over the stepping foot — not tilted.",
            relatedTerms: ["Quick", "Slow", "Rock Step"]
        ),

        // ─── PARTNER DANCING ───────────────────────────────────────────────

        DanceTerm(
            term: "Body Lead",
            category: .partnerDance,
            definition: "The technique by which a leader signals movement to the follower through the motion of their own torso — not by pushing or pulling with the arms. The leader's body moves first; the frame transmits that movement to the follower.",
            technicalNote: "A true body lead means the leader's center of gravity initiates the movement before the feet step. The frame is the transmission channel, not the motor. Arms that push or pull instead of transmit are one of the most common leader errors and often cause discomfort for the follower.",
            commonMisconceptions: "A body lead does not mean the leader leans into or drapes weight onto the follower. Each partner maintains their own axis.",
            relatedTerms: ["Frame", "Connection", "Leader"]
        ),

        DanceTerm(
            term: "Closed Position",
            category: .partnerDance,
            definition: "The standard partner hold: partners face each other with a slight offset (leader's right side to follower's right side), joined in a frame. This is the starting position for Texas Two-Step, Waltz, and most country partner dances.",
            technicalNote: "Partners do not stand fully face-to-face (as in a frontal hug). The offset is approximately one hand-width — the leader's right side aligns with the follower's center. The leader's right hand rests flat on the follower's left shoulder blade (not the waist). The joined hands are held at approximately the follower's eye level.",
            commonMisconceptions: "Closed position does not mean close together. Partners can be in closed position with comfortable space between them. Chest-to-chest contact is not required and is generally inappropriate for social dancing with a new partner.",
            relatedTerms: ["Frame", "Connection", "Open Position", "Leader", "Follower"]
        ),

        DanceTerm(
            term: "Connection",
            category: .partnerDance,
            definition: "The dynamic communication channel between partners, maintained through the frame and hand contact. Connection is maintained tension — like two people holding opposite ends of a rubber band — not grip strength or physical force.",
            technicalNote: "Good connection allows the leader's body movement to transmit through the frame to the follower and the follower's response to transmit back. It is a two-way conversation. A follower who collapses their frame offers nothing for the leader to transmit through; a leader who grips tightly loses the sensitivity needed to receive the follower's response.",
            commonMisconceptions: "Connection is not how tightly you hold your partner. Grip strength does not create connection — it destroys it. Tight gripping causes physical discomfort and blocks the subtle signals that make partner dancing work.",
            relatedTerms: ["Frame", "Body Lead", "Closed Position"]
        ),

        DanceTerm(
            term: "Cross Body Lead",
            category: .partnerDance,
            definition: "A figure in which the leader steps to the side to let the follower cross from one side of the leader to the other, walking past the leader as the leader steps out of the way.",
            technicalNote: nil,
            commonMisconceptions: nil,
            relatedTerms: ["Open Position", "Slot"]
        ),

        DanceTerm(
            term: "Dip",
            category: .partnerDance,
            definition: "A figure in which the leader supports the follower as they lean backward, lowering the follower's upper body in a controlled arc.",
            technicalNote: "Dips require the follower to commit their weight into the leader's support while maintaining their own frame. Leaders must be physically prepared to support the follower's weight completely. Dips should never be executed without clear communication — dipping an unprepared partner is a safety issue.",
            commonMisconceptions: nil,
            relatedTerms: ["Connection", "Frame"]
        ),

        DanceTerm(
            term: "Follower",
            category: .partnerDance,
            definition: "The partner who receives and responds to the leader's movement signals. The follower role is active, not passive — the follower interprets signals, executes their own footwork, and makes interpretive choices within the structure the leader provides.",
            technicalNote: "The follower is not 'moved' by the leader. The leader creates a direction or invitation; the follower chooses to follow it. A follower who understands this is far more capable and enjoyable to dance with than one who waits to be physically positioned.",
            commonMisconceptions: "The follower role is not 'easier' than the leader role. Maintaining an active frame, responding without anticipating, and executing footwork while receiving signals requires equal skill to leading. Role labels are not gender assignments — any dancer can lead or follow.",
            relatedTerms: ["Leader", "Connection", "Frame", "Back-Leading"]
        ),

        DanceTerm(
            term: "Frame",
            category: .partnerDance,
            definition: "The arm and upper-body position maintained by both partners in closed position that creates and preserves the connection channel. Good frame feels like a flexible but firm structure — neither rigid nor collapsed.",
            technicalNote: "Leader's right arm: hand flat on follower's left shoulder blade, fingers together, elbow pointing outward and slightly down. Follower's left arm: hand or forearm on leader's right upper arm, elbow at or near shoulder height. Joined hands: held at approximately the follower's eye level, elbow neither locked nor sharply bent. Both partners maintain their own frame — neither holds up the other's arm.",
            commonMisconceptions: "Frame is not rigidity. A stiff, locked frame blocks signals just as effectively as a collapsed one. Good frame has tone — like a muscle that is engaged but not clenched.",
            relatedTerms: ["Closed Position", "Connection", "Body Lead"]
        ),

        DanceTerm(
            term: "Hammerlock",
            category: .partnerDance,
            definition: "A position in which the follower's arm is bent behind their back, with the leader holding their wrist from the same side. Common in Nightclub Two-Step and some Two-Step variations.",
            technicalNote: nil,
            commonMisconceptions: nil,
            relatedTerms: ["Sweetheart Position", "Wrap"]
        ),

        DanceTerm(
            term: "Inside Turn",
            category: .partnerDance,
            definition: "A turn in which the follower rotates toward the leader's body — to the follower's left when facing the leader.",
            technicalNote: "The term 'inside' refers to the inside of the partnership space — the area between the two partners. An inside turn brings the follower's rotation toward that shared space.",
            commonMisconceptions: "Inside and outside turn terminology is sometimes reversed in different regional teaching traditions. This app defines inside turn as the follower rotating toward the leader (follower's left). When in doubt, describe the direction explicitly.",
            relatedTerms: ["Outside Turn", "Underarm Turn", "Leader", "Follower"]
        ),

        DanceTerm(
            term: "Leader",
            category: .partnerDance,
            definition: "The partner who initiates movements and guides the shared path and timing of the dance through body lead and frame signals. The leader role is not gender-specific — any dancer can lead.",
            technicalNote: "The leader communicates through body movement (body lead), not by physically pushing or pulling the follower. The leader is responsible for floor navigation in progressive dances and for the couple's safety on a crowded floor.",
            commonMisconceptions: "Leading is not the same as controlling. The leader creates invitations and framework; the follower chooses to respond. A lead that requires physical force is an incorrect lead.",
            relatedTerms: ["Follower", "Body Lead", "Frame", "Connection", "Floorcraft"]
        ),

        DanceTerm(
            term: "Line of Dance",
            category: .partnerDance,
            definition: "The counterclockwise direction that all progressive dances travel around the dance floor. Abbreviated LOD. Traveling in the line of dance is a safety rule, not optional etiquette.",
            technicalNote: "Looking at the dance floor from above, progressive couples travel counterclockwise — the same direction as the hands of an analog clock move, but in reverse. From the dancer's perspective standing on the floor, this means they travel to their left when facing the center of the room.",
            commonMisconceptions: "The line of dance is not 'the direction most people happen to be going.' It is a firm convention at every country western dance venue. Dancing against the line of dance is a collision hazard.",
            relatedTerms: ["Progressive Dance", "Floorcraft", "Texas Two-Step", "Waltz"]
        ),

        DanceTerm(
            term: "Open Position",
            category: .partnerDance,
            definition: "Partners face each other with arms extended and only hand-to-hand connection — no frame on the back. Used in turns, underarm passes, and some Two-Step variations.",
            technicalNote: nil,
            commonMisconceptions: nil,
            relatedTerms: ["Closed Position", "Two-Hand Hold", "Underarm Turn"]
        ),

        DanceTerm(
            term: "Outside Turn",
            category: .partnerDance,
            definition: "A turn in which the follower rotates away from the leader's body — to the follower's right when facing the leader.",
            technicalNote: "The term 'outside' refers to the area outside the partnership space. An outside turn takes the follower's rotation away from the shared center.",
            commonMisconceptions: "See Inside Turn — regional terminology variations exist. This app defines outside turn as follower rotating away from the leader (follower's right).",
            relatedTerms: ["Inside Turn", "Underarm Turn"]
        ),

        DanceTerm(
            term: "Promenade Position",
            category: .partnerDance,
            definition: "Partners stand side by side facing the same direction, right hips adjacent. The leader's right hand joins the follower's right hand; the leader's left hand joins the follower's left hand, with arms crossed in front. Both partners travel forward together.",
            technicalNote: "Also called 'side-by-side position' or 'skater's position' in some teaching traditions. Used in Two-Step variations, Schottische, and other country partner dances.",
            commonMisconceptions: nil,
            relatedTerms: ["Closed Position", "Shadow Position", "Sweetheart Position"]
        ),

        DanceTerm(
            term: "Progressive Dance",
            category: .partnerDance,
            definition: "A partner dance that travels counterclockwise around the perimeter of the dance floor. Texas Two-Step, One-Step, Waltz, and Polka are progressive dances.",
            technicalNote: nil,
            commonMisconceptions: "Progressive dances do not stay in one spot. If a couple is standing still while dancing a Two-Step, they are either in a transition figure or are blocking the line of dance.",
            relatedTerms: ["Line of Dance", "Spot Dance", "Floorcraft"]
        ),

        DanceTerm(
            term: "Shadow Position",
            category: .partnerDance,
            definition: "The follower stands directly in front of the leader, both facing the same direction. The leader's arms extend around the follower from behind, with hands joined on each side.",
            technicalNote: nil,
            commonMisconceptions: nil,
            relatedTerms: ["Promenade Position", "Sweetheart Position"]
        ),

        DanceTerm(
            term: "Slot",
            category: .partnerDance,
            definition: "The imaginary straight line on the floor along which the follower travels back and forth in West Coast Swing. The leader stays at one end of the slot and the follower passes through it.",
            technicalNote: nil,
            commonMisconceptions: nil,
            relatedTerms: ["West Coast Swing", "Cross Body Lead"]
        ),

        DanceTerm(
            term: "Spot Dance",
            category: .partnerDance,
            definition: "A dance performed in place or in a small defined area, without traveling counterclockwise around the floor. Line dances, West Coast Swing, and East Coast Swing are spot dances.",
            technicalNote: "Spot dances are danced away from the outer lane of the dance floor, which is reserved for progressive (traveling) couples.",
            commonMisconceptions: nil,
            relatedTerms: ["Progressive Dance", "Line of Dance", "Slot"]
        ),

        DanceTerm(
            term: "Sweetheart Position",
            category: .partnerDance,
            definition: "Side-by-side hold in which the leader's right arm passes over the follower's right shoulder and the hands join in front. Both partners face the same direction.",
            technicalNote: "Also called Varsouvienne position or 'sweetheart hold.' Common in Schottische and some Two-Step variations.",
            commonMisconceptions: nil,
            relatedTerms: ["Promenade Position", "Varsouvienne", "Shadow Position"]
        ),

        DanceTerm(
            term: "Two-Hand Hold",
            category: .partnerDance,
            definition: "Both of the leader's hands holding both of the follower's hands simultaneously, with both pairs of arms extended in an open, facing position. Used in Two-Step variations and transitions.",
            technicalNote: nil,
            commonMisconceptions: nil,
            relatedTerms: ["Open Position", "Closed Position"]
        ),

        DanceTerm(
            term: "Underarm Turn",
            category: .partnerDance,
            definition: "A turn executed when the leader raises a joined hand to create an arch and guides the follower (or themselves) to rotate underneath it.",
            technicalNote: "The follower does not spin independently — the leader creates the portal and the direction; the follower steps through it. The turn is a guided, connected movement, not a self-generated spin.",
            commonMisconceptions: "'Underarm turn,' 'spin,' and 'twirl' are sometimes used interchangeably, but they are different: a spin is independent; a twirl is informal; an underarm turn is a led, connected movement. This app uses 'underarm turn' as the canonical term.",
            relatedTerms: ["Inside Turn", "Outside Turn", "Connection"]
        ),

        DanceTerm(
            term: "Varsouvienne",
            category: .partnerDance,
            definition: "Another name for Sweetheart Position — the side-by-side hold with the leader's arm over the follower's shoulder. A classic country western partner hold with 19th-century European origins.",
            technicalNote: nil,
            commonMisconceptions: nil,
            relatedTerms: ["Sweetheart Position"]
        ),

        DanceTerm(
            term: "Wrap",
            category: .partnerDance,
            definition: "A figure that ends with the follower standing in front of the leader with arms crossed — the follower 'wrapped' in the leader's arms. A signature move in Progressive Two-Step.",
            technicalNote: nil,
            commonMisconceptions: nil,
            relatedTerms: ["Hammerlock", "Shadow Position"]
        ),

        // ─── LINE DANCING ──────────────────────────────────────────────────

        DanceTerm(
            term: "2-Wall Dance",
            category: .lineDance,
            definition: "A line dance that faces only two walls during its rotation — the front wall and the back wall.",
            technicalNote: nil,
            commonMisconceptions: nil,
            relatedTerms: ["4-Wall Dance", "Wall"]
        ),

        DanceTerm(
            term: "4-Wall Dance",
            category: .lineDance,
            definition: "A line dance that rotates through all four walls of the room — front, right side, back, left side — as the pattern repeats. Most line dances in this app are 4-wall.",
            technicalNote: nil,
            commonMisconceptions: nil,
            relatedTerms: ["2-Wall Dance", "Wall"]
        ),

        DanceTerm(
            term: "Choreographer",
            category: .lineDance,
            definition: "The person who created the sequence of steps for a particular line dance. Step sheets credit the choreographer whenever the information is verifiable.",
            technicalNote: nil,
            commonMisconceptions: nil,
            relatedTerms: ["Step Sheet"]
        ),

        DanceTerm(
            term: "Restart",
            category: .lineDance,
            definition: "A point in a line dance where the pattern begins again from the start before completing its full count. Restarts are flagged on step sheets with the exact count and the condition that triggers them (usually a specific wall or song section).",
            technicalNote: "Missing a restart is one of the most common line dance errors — the dancer continues while the rest of the group has already gone back to count 1. Restarts must be memorized, not just understood conceptually.",
            commonMisconceptions: nil,
            relatedTerms: ["Tag", "Step Sheet", "Wall"]
        ),

        DanceTerm(
            term: "Step Sheet",
            category: .lineDance,
            definition: "The written count-by-count description of every step in a line dance. A complete step sheet includes the total count, wall count, level, music suggestion, all restarts, and any tags.",
            technicalNote: nil,
            commonMisconceptions: nil,
            relatedTerms: ["Choreographer", "Tag", "Restart", "Wall"]
        ),

        DanceTerm(
            term: "Tag",
            category: .lineDance,
            definition: "Extra counts added into a line dance at a specific point — usually to keep the dance aligned with the music's phrasing. Tags are noted on the step sheet with the exact count where they occur.",
            technicalNote: nil,
            commonMisconceptions: "A tag is different from a restart. A tag adds counts to the pattern; a restart returns to the beginning early.",
            relatedTerms: ["Restart", "Step Sheet", "Phrase"]
        ),

        DanceTerm(
            term: "Wall",
            category: .lineDance,
            definition: "The direction you face at the start of each new repetition of the pattern in a line dance. In a 4-wall dance you face a new wall at the start of each repetition, cycling through all four.",
            technicalNote: nil,
            commonMisconceptions: nil,
            relatedTerms: ["4-Wall Dance", "2-Wall Dance", "Pivot Turn"]
        ),

        // ─── DANCE STYLES ──────────────────────────────────────────────────

        DanceTerm(
            term: "Cha-Cha",
            category: .danceStyles,
            definition: "A partner dance with a triple-step on the 4-and-1 count. In country settings this appears as the Traveling Cha-Cha or Cowboy Cha-Cha.",
            technicalNote: nil,
            commonMisconceptions: nil,
            relatedTerms: []
        ),

        DanceTerm(
            term: "Clogging",
            category: .danceStyles,
            definition: "An Appalachian step dance with percussive heel-and-toe footwork, usually performed to bluegrass or old-time music.",
            technicalNote: nil,
            commonMisconceptions: nil,
            relatedTerms: []
        ),

        DanceTerm(
            term: "East Coast Swing",
            category: .danceStyles,
            definition: "A 6-count partner swing dance with two triple-steps and a rock step. Common at country bars alongside Two-Step.",
            technicalNote: nil,
            commonMisconceptions: nil,
            relatedTerms: ["Triple Step", "Rock Step", "West Coast Swing"]
        ),

        DanceTerm(
            term: "Line Dance",
            category: .danceStyles,
            definition: "A solo choreographed dance performed in rows or lines without a partner, typically to a specific song. Everyone does the same steps at the same time.",
            technicalNote: nil,
            commonMisconceptions: "Line dancing is not a less-skilled form of dancing. Many accomplished partner dancers are expert line dancers. The skills transfer: timing, direction awareness, and body coordination developed in line dancing directly support partner dancing.",
            relatedTerms: ["Step Sheet", "Wall", "4-Wall Dance"]
        ),

        DanceTerm(
            term: "Nightclub Two-Step",
            category: .danceStyles,
            definition: "A slow, romantic partner dance developed by Buddy Schwimmer in the 1960s. Danced to mid-tempo ballads in 4/4 time with a Quick-Quick-Slow rhythm.",
            technicalNote: nil,
            commonMisconceptions: nil,
            relatedTerms: ["Texas Two-Step", "Connection"]
        ),

        DanceTerm(
            term: "Polka",
            category: .danceStyles,
            definition: "A fast, bouncy partner dance in 2/4 time that travels counterclockwise around the floor. Very popular at Texas dance halls.",
            technicalNote: nil,
            commonMisconceptions: nil,
            relatedTerms: ["Line of Dance", "Progressive Dance"]
        ),

        DanceTerm(
            term: "Schottische",
            category: .danceStyles,
            definition: "A partner or line dance in 4/4 time with a step-step-step-hop pattern. Often done in sweetheart or side-by-side position.",
            technicalNote: nil,
            commonMisconceptions: nil,
            relatedTerms: ["Sweetheart Position", "Hop"]
        ),

        DanceTerm(
            term: "Shuffle Dance",
            category: .danceStyles,
            definition: "Another name for Triple Two-Step — the Fort Worth Shuffle style. Uses triple-steps instead of the walking Quicks of basic Texas Two-Step.",
            technicalNote: nil,
            commonMisconceptions: nil,
            relatedTerms: ["Triple Two-Step", "Shuffle"]
        ),

        DanceTerm(
            term: "Texas Two-Step",
            category: .danceStyles,
            definition: "The classic Texas country partner dance with Quick-Quick-Slow-Slow timing, traveling counterclockwise around the floor in closed position. Smooth, gliding, and forward-traveling.",
            technicalNote: "Both partners step forward and backward — not side to side. The upper body remains level with no bounce. The leader starts on the left foot; the follower starts on the right foot.",
            commonMisconceptions: "The Slows in Texas Two-Step are NOT a step followed by a pause. Both beats of each Slow are occupied by continuous gliding movement.",
            relatedTerms: ["Quick Quick Slow Slow", "Closed Position", "Line of Dance", "One-Step"]
        ),

        DanceTerm(
            term: "Triple Two-Step",
            category: .danceStyles,
            definition: "A Texas Two-Step variation using syncopated triple-steps (1-and-2, 3-and-4) followed by two walking steps. Also called the Fort Worth Shuffle.",
            technicalNote: nil,
            commonMisconceptions: nil,
            relatedTerms: ["Texas Two-Step", "Triple Step", "Shuffle"]
        ),

        DanceTerm(
            term: "One-Step",
            category: .danceStyles,
            definition: "A country partner dance with one step per beat of music, traveling counterclockwise in closed position. Simpler timing than Two-Step, making it an excellent entry point for beginners.",
            technicalNote: "One-Step retains all the quality markers of partner dancing: frame, connection, floor travel, and level upper body. It is a legitimate social dance, not a beginner placeholder.",
            commonMisconceptions: "One-Step is not 'just walking.' It requires the same technique as Two-Step — frame, connection, counterclockwise travel, complete weight transfer — with simpler timing.",
            relatedTerms: ["Texas Two-Step", "Progressive Dance", "Closed Position"]
        ),

        DanceTerm(
            term: "Waltz",
            category: .danceStyles,
            definition: "A graceful partner dance in 3/4 time (three beats per measure). Country waltz travels counterclockwise around the floor rather than staying in a box.",
            technicalNote: nil,
            commonMisconceptions: nil,
            relatedTerms: ["Line of Dance", "Progressive Dance"]
        ),

        DanceTerm(
            term: "West Coast Swing",
            category: .danceStyles,
            definition: "A slotted partner dance with an elastic, push-pull connection. The follower travels back and forth along a straight slot while the leader stays at one end.",
            technicalNote: nil,
            commonMisconceptions: nil,
            relatedTerms: ["Slot", "Anchor Step", "Connection"]
        ),

        // ─── VENUE & ETIQUETTE ─────────────────────────────────────────────

        DanceTerm(
            term: "Back-Leading",
            category: .venueAndEtiquette,
            definition: "When a follower executes a movement before the leader has signaled it — anticipating instead of responding. Back-leading disrupts the connection and makes improvisation impossible for the leader.",
            technicalNote: "Back-leading is the single most common follower technical error. It often comes from knowing the pattern and executing it from memory rather than from feel. The cure is to consciously delay response until the signal is felt through the frame.",
            commonMisconceptions: nil,
            relatedTerms: ["Follower", "Connection", "Frame"]
        ),

        DanceTerm(
            term: "Dance Hall",
            category: .venueAndEtiquette,
            definition: "A venue purpose-built for partner and line dancing — typically with a hardwood or concrete floor, live band stage, and no chairs on the dance floor.",
            technicalNote: nil,
            commonMisconceptions: nil,
            relatedTerms: ["Honky Tonk", "Line of Dance"]
        ),

        DanceTerm(
            term: "Floorcraft",
            category: .venueAndEtiquette,
            definition: "The skill of navigating the dance floor safely — avoiding collisions, maintaining the line of dance, and adapting patterns to available space. Floorcraft is primarily the leader's responsibility in partner dancing.",
            technicalNote: "On a crowded floor, leaders must compress patterns — no large sweeps or dips when space is limited. Faster couples travel the outer lane; slower couples use inner lanes. Never stop on the dance floor.",
            commonMisconceptions: "Floorcraft is not optional for advanced dancers. It is a fundamental skill that every leader must develop from the first day of social dancing.",
            relatedTerms: ["Line of Dance", "Leader", "Progressive Dance"]
        ),

        DanceTerm(
            term: "Honky Tonk",
            category: .venueAndEtiquette,
            definition: "A bar or small club that plays country music and has a dance floor. Generally more informal than a dance hall.",
            technicalNote: nil,
            commonMisconceptions: nil,
            relatedTerms: ["Dance Hall"]
        ),

        DanceTerm(
            term: "Kicker",
            category: .venueAndEtiquette,
            definition: "Texas slang for a country-western dancer. Country dancing is sometimes called 'kicker dancing' in Texas.",
            technicalNote: nil,
            commonMisconceptions: nil,
            relatedTerms: []
        ),

        DanceTerm(
            term: "Mixer",
            category: .venueAndEtiquette,
            definition: "A partner dance where dancers rotate to a new partner at regular intervals — usually at the end of each phrase or pattern repetition.",
            technicalNote: nil,
            commonMisconceptions: nil,
            relatedTerms: []
        ),

    ].sorted { $0.term < $1.term }
}
