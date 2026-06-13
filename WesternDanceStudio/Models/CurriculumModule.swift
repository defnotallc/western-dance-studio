import Foundation

// MARK: - Curriculum Module Model (Phase 4 — Curriculum Structure)
//
// Eight modules, numbered 0–7, forming a progressive learning path from
// floor safety through intermediate partner and line dancing.
//
// Design principles:
//   • No hard locks — every module is accessible at any time.
//   • Completion is self-reported via CurriculumStore.
//   • Module order reflects pedagogical consensus, not game mechanics.
//   • Content that lived in BeginnerBootcampView now lives here.

struct CurriculumModule: Identifiable {
    let id: String
    let number: Int
    let title: String
    let subtitle: String
    /// What the student will be able to do after this module.
    let skills: [String]
    /// 2–3 sentence overview shown in the module list card.
    let overview: String
    /// Rich explanatory sections shown in the module detail view.
    let concepts: [Concept]
    /// Dance IDs to practice during this module.
    let danceIDs: [String]
    /// Glossary term names relevant to this module.
    let glossaryTerms: [String]
    let estimatedHours: Double

    /// A named explanatory block within a module detail view.
    struct Concept: Identifiable {
        let id: String
        let heading: String
        let body: String
    }

    var numberDisplay: String { "Module \(number)" }

    var estimatedTimeDisplay: String {
        estimatedHours < 1 ? "< 1 hr" :
        estimatedHours == 1 ? "~ 1 hr" :
        "~ \(Int(estimatedHours)) hrs"
    }
}

// MARK: - Full 8-Module Curriculum

extension CurriculumModule {

    static let all: [CurriculumModule] = [
        module0, module1, module2, module3,
        module4, module5, module6, module7,
    ]

    // ─── Module 0: Before You Dance ───────────────────────────────────────

    static let module0 = CurriculumModule(
        id: "module-0",
        number: 0,
        title: "Before You Dance",
        subtitle: "Safety, etiquette, and floor rules",
        skills: [
            "Identify the line of dance and travel counterclockwise",
            "Ask for a dance respectfully; accept a refusal gracefully",
            "Recognize the outer (progressive) and inner (spot) floor lanes",
            "Know when and how to step off the floor safely",
            "Understand that force is never correct technique",
        ],
        overview: "Everything before your first step matters. Country dancing has a clear etiquette code and a floor safety system. Skipping this module is the most common beginner mistake — and the most dangerous one.",
        concepts: [
            Concept(id: "m0-safety", heading: "Force Is Never Correct Technique",
                body: "In every partner dance, the leader communicates through body movement — never through pushing, pulling, or gripping. If you feel physical pressure that is uncomfortable, you have the right to stop dancing immediately. Say \"I need to stop\" — you owe no further explanation."),
            Concept(id: "m0-ask", heading: "Asking for a Dance",
                body: "Approach from the front, make eye contact, and ask simply: \"Would you like to dance?\" A \"no\" is complete. Say \"No problem — enjoy your evening\" and move on. Never ask why. Never push. A decline requires no explanation from the person who declined."),
            Concept(id: "m0-lod", heading: "The Line of Dance",
                body: "All progressive dances — Two-Step, Waltz, One-Step — travel counterclockwise around the floor. Viewed from above, couples move like the hands of a clock run in reverse. Traveling against this flow is a collision hazard for everyone on the floor."),
            Concept(id: "m0-lanes", heading: "Floor Lanes",
                body: "The outer lane nearest the walls is for couples actively traveling counterclockwise. Spot dances — line dancing, West Coast Swing, East Coast Swing — belong in the center. Never stop in the middle of a traveling lane; step off the floor instead."),
        ],
        danceIDs: [],
        glossaryTerms: ["Line of Dance", "Floorcraft", "Leader", "Follower", "Progressive Dance", "Spot Dance"],
        estimatedHours: 0.5
    )

    // ─── Module 1: Music & Timing ──────────────────────────────────────────

    static let module1 = CurriculumModule(
        id: "module-1",
        number: 1,
        title: "Music & Timing",
        subtitle: "Beats, BPM, counting, and the metronome",
        skills: [
            "Find the beat in a country song",
            "Count beats in groups of four: 1-2-3-4",
            "Identify the downbeat (beat 1) by ear",
            "Set and use the in-app metronome",
            "Match footsteps to the click before adding music",
        ],
        overview: "Dancing starts with hearing the music. Before your feet move, your ears need to find the pulse. This module covers what a beat is, how BPM affects dance speed, and how to use a metronome to build steady timing.",
        concepts: [
            Concept(id: "m1-beat", heading: "What Is a Beat?",
                body: "Every song has a steady pulse called the beat — the regular thud you naturally tap your foot to. In country music the kick drum produces beats 1 and 3; the snare drum accents beats 2 and 4. Together they create the clear pulse dancers follow. Think of a clock ticking or your heart beating."),
            Concept(id: "m1-count", heading: "How to Count Music",
                body: "Most country songs are counted in groups of four beats: 1-2-3-4, 1-2-3-4. Four beats make a measure. Two-Step timing is Quick-Quick-Slow-Slow — counted 1-2-3-4 where the Quicks are one beat each and the Slows hold for two beats. Waltz counts in threes: 1-2-3, 1-2-3."),
            Concept(id: "m1-bpm", heading: "What Is BPM?",
                body: "BPM stands for Beats Per Minute — the speed of a song. Slow dances like Nightclub Two-Step run around 75–90 BPM. Country Waltz sits at 90–120 BPM. Texas Two-Step at most venues runs 150–190 BPM. The BPM for each dance is listed on its detail page. Start below the real tempo and work up."),
            Concept(id: "m1-metro", heading: "Using a Metronome",
                body: "A metronome produces a steady click at a set tempo. Use it to internalize timing before adding music — you feel the beat without the distraction of melody, lyrics, or instrumentation. Practice: set it to 100 BPM, count along with the clicks, and step on every beat. Once you can do that comfortably, try a real song at that speed. The metronome is on the Start Here tab."),
        ],
        danceIDs: [],
        glossaryTerms: ["Beat", "BPM", "Count", "Downbeat", "Measure", "Phrase", "Quick", "Slow", "Tempo"],
        estimatedHours: 1.0
    )

    // ─── Module 2: One-Step ────────────────────────────────────────────────

    static let module2 = CurriculumModule(
        id: "module-2",
        number: 2,
        title: "One-Step",
        subtitle: "Your first partner dance — one step per beat",
        skills: [
            "Stand in closed position with correct frame",
            "Maintain arm and upper-body tone without rigidity",
            "Complete a full weight transfer on every beat",
            "Travel counterclockwise as a couple",
            "Communicate direction through body lead, not arm force",
        ],
        overview: "The One-Step is exactly what it sounds like — one step per beat of music. It has all the quality markers of great partner dancing: frame, connection, and counterclockwise travel. This is not a beginner placeholder; it is a complete social dance.",
        concepts: [
            Concept(id: "m2-position", heading: "Closed Position",
                body: "Partners face each other with a slight offset (about one hand-width) — not fully face-to-face. The leader's right hand rests flat on the follower's left shoulder blade, fingers together, elbow pointing out. The follower's left arm rests on the leader's upper arm. Joined hands are held at approximately the follower's eye level. There should be comfortable space between the partners' bodies."),
            Concept(id: "m2-frame", heading: "Frame and Connection",
                body: "Frame is the structure that transmits signals between partners. Good frame has tone — like a muscle that is engaged but not clenched. The leader's body moves first; the frame carries that movement to the follower. Neither partner drapes their weight on the other or collapses their arms."),
            Concept(id: "m2-weight", heading: "Weight Transfer",
                body: "Every step requires a complete weight transfer — the body's center of gravity fully shifts onto the stepping foot so the other foot is free. On forward steps, the heel contacts the floor first and weight rolls through to the ball. On backward steps, the ball contacts first. If you can't lift the free foot without losing balance, the transfer is incomplete."),
            Concept(id: "m2-onestep", heading: "One-Step vs. Two-Step",
                body: "Two-Step has Quick-Quick-Slow-Slow timing (six beats per cycle). One-Step has one step per beat — simpler timing on the same counterclockwise path. Master One-Step first: the frame, connection, and floor travel you learn here carry directly into Two-Step. The only thing that changes is the timing pattern."),
        ],
        danceIDs: ["one-step"],
        glossaryTerms: ["Closed Position", "Frame", "Connection", "Weight Transfer", "Body Lead", "Leader", "Follower"],
        estimatedHours: 2.0
    )

    // ─── Module 3: Texas Two-Step ──────────────────────────────────────────

    static let module3 = CurriculumModule(
        id: "module-3",
        number: 3,
        title: "Texas Two-Step",
        subtitle: "Quick-Quick-Slow-Slow — the heart of country dancing",
        skills: [
            "Count the QQSS pattern over six beats",
            "Step cleanly on the Quicks without bouncing",
            "Glide through both beats of each Slow without pausing",
            "Lead or follow the basic Two-Step in counterclockwise traffic",
            "Maintain level shoulders and upper body throughout",
        ],
        overview: "Texas Two-Step is the defining country partner dance — smooth, gliding, and powerful. The most important thing a beginner learns here: a Slow is not a step followed by a pause. Both beats of a Slow are occupied by continuous movement.",
        concepts: [
            Concept(id: "m3-qqss", heading: "Quick-Quick-Slow-Slow",
                body: "The Two-Step pattern spans six beats of music: Quick (beat 1), Quick (beat 2), Slow (beats 3–4), Slow (beats 5–6). One full cycle = six beats. The leader starts on the left foot moving forward; the follower starts on the right foot moving backward. Both partners alternate feet naturally through the pattern."),
            Concept(id: "m3-slow", heading: "The Slow Is Not a Pause",
                body: "This is the single most important concept in Two-Step. A Slow step occupies two beats of music. The weight transfers on beat one; the body continues moving through beat two without a new step. Think of it as a glide, not a step-then-hold. If you hear the click-click rhythm of someone pausing on their Slows, that is the error to avoid."),
            Concept(id: "m3-quicks", heading: "Clean Quicks",
                body: "Each Quick requires a full, complete weight transfer in one beat. The most common error is rushing or shuffling the Quicks — treating them as small, tentative steps. A Quick should be the same size and quality as any other step; it simply occupies less time. On forward steps, lead with the heel."),
            Concept(id: "m3-level", heading: "Level Upper Body",
                body: "Texas Two-Step has no bounce. The upper body remains at a constant height as the feet travel. Beginners often bob up and down as they step — this is usually caused by stepping with bent knees instead of walking through the foot. Imagine a glass of water resting on your head: it should not spill."),
        ],
        danceIDs: ["texas-two-step"],
        glossaryTerms: ["Quick Quick Slow Slow", "Quick", "Slow", "Weight Transfer", "Closed Position"],
        estimatedHours: 3.0
    )

    // ─── Module 4: First Line Dances ──────────────────────────────────────

    static let module4 = CurriculumModule(
        id: "module-4",
        number: 4,
        title: "First Line Dances",
        subtitle: "Electric Slide, Cupid Shuffle, and the 4-wall concept",
        skills: [
            "Track which wall you face and rotate correctly",
            "Execute a vine (grapevine) to the right and left",
            "Handle a quarter-turn within a pattern without losing the group",
            "Dance the Electric Slide from memory",
            "Dance the Cupid Shuffle using the music's lyric cues",
        ],
        overview: "Line dances are solo choreographed dances — no partner needed. Everyone does the same steps at the same time. A '4-wall dance' means you face a different wall at the start of each repetition, rotating counterclockwise through the room.",
        concepts: [
            Concept(id: "m4-linedance", heading: "What Is a Line Dance?",
                body: "A line dance is a choreographed sequence repeated in rows or lines, with all dancers performing the same steps simultaneously. Unlike partner dances, you need no partner — just a group willing to do the same thing. Line dancing and partner dancing share the same floor, just different areas of it (line dances in the center; partner dances in the outer lane)."),
            Concept(id: "m4-4wall", heading: "The 4-Wall Concept",
                body: "Most country line dances are '4-wall' — meaning the pattern ends with a quarter-turn, so you face a new wall at the start of each repetition. After four repetitions you've completed a full 360°. The four walls are usually called Front, Right Side, Back, and Left Side. If you find yourself facing the wrong wall, step back to the edge of the group and re-enter on the next repetition."),
            Concept(id: "m4-vine", heading: "The Grapevine (Vine)",
                body: "A grapevine is a 4-count sideways sequence: step to the side, cross behind, step to the side, touch (or scuff, or stomp). A vine to the right: step R side, step L crossing behind R, step R side, touch L. A vine to the left is the mirror image. The grapevine appears in nearly every line dance — master it and half the dances become easy."),
        ],
        danceIDs: ["electric-slide", "cupid-shuffle", "achy-breaky-heart"],
        glossaryTerms: ["4-Wall Dance", "Wall", "Grapevine", "Line Dance", "Step Sheet"],
        estimatedHours: 2.0
    )

    // ─── Module 5: Two-Step Figures ────────────────────────────────────────

    static let module5 = CurriculumModule(
        id: "module-5",
        number: 5,
        title: "Two-Step Figures",
        subtitle: "Underarm turns, promenade, and open position",
        skills: [
            "Lead and follow an underarm turn without using arm force",
            "Move through promenade position while maintaining connection",
            "Distinguish inside from outside turns",
            "Signal a turn with a raised hand, not a push",
            "Return to closed position after any figure",
        ],
        overview: "Once you have the basic Two-Step, figures are the vocabulary you add. Each figure starts and ends in connection. The most important rule: every turn is led through the frame, never by pushing the follower's shoulder or spinning their arm.",
        concepts: [
            Concept(id: "m5-underarm", heading: "Underarm Turn",
                body: "An underarm turn happens when the leader raises a joined hand to create an arch and guides the follower (or themselves) to rotate underneath it. The follower does not spin independently — the leader creates the direction; the follower steps through it. The hand that raises creates the arch; the other hand maintains connection."),
            Concept(id: "m5-inside-outside", heading: "Inside vs. Outside Turns",
                body: "An inside turn rotates the follower toward the leader's body — the follower turns to their left when facing the leader. An outside turn rotates away from the leader's body — the follower turns to their right. Inside turns are generally easier to signal; outside turns require more precise lead timing."),
            Concept(id: "m5-promenade", heading: "Promenade Position",
                body: "Promenade has both partners side by side, right hips adjacent, both facing the line of dance. The leader's right hand joins the follower's right hand; the leader's left hand joins the follower's left hand, with arms crossed in front. Both partners travel forward together down the line of dance. It is used as a transition position between figures."),
            Concept(id: "m5-force", heading: "Why Force Doesn't Work",
                body: "A turn that requires physical force is an incorrect lead. The leader's torso initiates the direction; the frame communicates it; the follower chooses to respond. When leaders grip and yank, followers can't feel the subtle signals, and both partners end up working against each other. Use less force, not more, when a turn is not working — then check your frame and body position."),
        ],
        danceIDs: ["texas-two-step", "one-step"],
        glossaryTerms: ["Underarm Turn", "Inside Turn", "Outside Turn", "Promenade Position", "Open Position", "Two-Hand Hold", "Body Lead"],
        estimatedHours: 3.0
    )

    // ─── Module 6: Intermediate Line Dances ───────────────────────────────

    static let module6 = CurriculumModule(
        id: "module-6",
        number: 6,
        title: "Intermediate Line Dances",
        subtitle: "Boot Scootin', Copperhead Road, Watermelon Crawl, Tush Push",
        skills: [
            "Execute a heel strut (heel touch → roll to ball)",
            "Syncopate with a triple step (1-&-2 count)",
            "Perform a jazz box and a hook sequence",
            "Handle a restart without losing the group",
            "Dance all four Tier 1 intermediate line dances at social tempo",
        ],
        overview: "These four line dances appear at virtually every country bar and dance hall. Together they cover heel struts, hip bumps, chassés, jazz boxes, and pivot turns — the essential vocabulary of intermediate country line dancing.",
        concepts: [
            Concept(id: "m6-heelstrut", heading: "Heel Strut",
                body: "A heel strut is a 2-count step: place the heel on the floor (count 1, no weight), then roll onto the ball of the foot (count 2, weight transfers). The characteristic forward heel placement before the rolldown is what gives country dancing its boot-wearing, strutting quality. Common error: placing the whole foot at once instead of heel-then-ball."),
            Concept(id: "m6-triple", heading: "Triple Step (Syncopation)",
                body: "A triple step fits three small steps into two beats of music: step on beat 1, step on the '&' (half-beat), step on beat 2. It is counted '1-&-2' or '3-&-4.' The middle step (the '&') is a small closing step — bring the free foot adjacent to the standing foot before the third step travels. Rushing the '&' is the most common error."),
            Concept(id: "m6-jazzbox", heading: "Jazz Box",
                body: "A jazz box is a 4-count figure that traces a box on the floor: cross one foot over the other (count 1), step back with the free foot (count 2), step to the side (count 3), bring the free foot together or touch (count 4). The cross-over on count 1 is what distinguishes a jazz box from a simple box step."),
            Concept(id: "m6-restart", heading: "Restarts",
                body: "A restart is a point in a line dance where the pattern begins again from count 1 before it has completed its full count. Restarts are used to keep the dance synchronized with the music's phrasing. They are listed on the step sheet with the exact count and the wall where they occur. If you miss a restart and continue while the group has returned to count 1, step to the edge and re-enter on the next repetition."),
        ],
        danceIDs: ["boot-scootin-boogie", "copperhead-road", "watermelon-crawl", "tush-push"],
        glossaryTerms: ["Triple Step", "Syncopation", "Heel Strut", "Jazz Box", "Restart", "Tag", "Shuffle"],
        estimatedHours: 3.0
    )

    // ─── Module 7: Swing & Waltz ───────────────────────────────────────────

    static let module7 = CurriculumModule(
        id: "module-7",
        number: 7,
        title: "Swing & Waltz",
        subtitle: "East Coast Swing, Country Waltz, and when to use each",
        skills: [
            "Count and step a 6-count East Coast Swing pattern",
            "Execute a rock step with clean rebound",
            "Recognize waltz timing (1-2-3) by ear",
            "Choose between Two-Step, Swing, and Waltz based on the song",
            "Navigate the floor in waltz hold",
        ],
        overview: "Two-Step and line dancing are the foundation; Swing and Waltz expand your vocabulary. Swing is lively and stays in place. Waltz is graceful and travels. Recognizing which dance fits a song is a skill that develops with listening.",
        concepts: [
            Concept(id: "m7-swing", heading: "What Is Western Swing?",
                body: "Western Swing is a family of energetic partner dances with a rotational, bouncy feel. Unlike the Two-Step's smooth glide around the floor, Swing stays mostly in one spot with spins, turns, and playful connection. East Coast Swing (6-count, triple-steps) is the most common at country venues. West Coast Swing is slotted and smoother. Swing pairs well with up-tempo honky-tonk where Two-Step would feel too slow."),
            Concept(id: "m7-ecs", heading: "East Coast Swing Pattern",
                body: "The basic 6-count East Coast Swing pattern: triple step right (1-&-2), triple step left (3-&-4), rock back (5), replace forward (6). The rock step on counts 5-6 creates the rebound energy that drives the next triple. Partners mirror each other: leader steps right first, follower steps left. This is a spot dance — it stays in the center of the floor."),
            Concept(id: "m7-waltz", heading: "Country Waltz",
                body: "The Country Waltz is a flowing, graceful partner dance in 3/4 time — counted 1-2-3, 1-2-3. Unlike ballroom waltzes that box in place, country waltzes travel continuously counterclockwise, with long rising-and-falling steps that feel almost like floating. The musical signature of waltz is unmistakable: a strong beat-1 followed by two softer beats. If you hear that pattern, waltz."),
            Concept(id: "m7-choose", heading: "Choosing the Right Dance",
                body: "Same dance floor, different dances for different songs. General guidelines: fast 4/4 country (150+ BPM) → Two-Step; energetic 4/4 (120–150 BPM) with bouncy feel → Swing; 3/4 time (any tempo) → Waltz; mid-tempo ballads → Nightclub Two-Step or slow Two-Step. When in doubt, watch what the experienced couples around you are choosing."),
        ],
        danceIDs: ["east-coast-swing", "country-waltz", "triple-two-step"],
        glossaryTerms: ["East Coast Swing", "Rock Step", "Triple Step", "Waltz", "West Coast Swing", "Spot Dance"],
        estimatedHours: 4.0
    )
}
