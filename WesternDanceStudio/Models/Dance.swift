import Foundation

struct Dance: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let category: DanceCategory
    /// Short tagline shown below the title in the detail view.
    let summary: String
    /// Longer description used in lists and anywhere more context helps.
    let description: String
    let leaderVideoURL: URL?
    let followerVideoURL: URL?
    let bpm: Int
    let isPartnerDance: Bool
    let difficulty: Int
    let recommendedSongs: [String]
    /// For partner dances, the lead's steps. For solo dances (line dances),
    /// this is the single set of steps and `followSteps` is empty.
    let leadSteps: [String]
    /// For partner dances, the follow's steps. Empty for solo dances.
    let followSteps: [String]
    let youtubeID: String?

    enum DanceCategory: String, CaseIterable, Identifiable, Codable {
        case twoStep = "Two-Step Variations"
        case lineDance = "Line Dances"
        case swing = "Western Swing & Partner"
        case waltz = "Waltzes & Schottisches"
        case other = "Other Country Dances"
        var id: String { rawValue }
    }

    /// True if this dance has a distinct lead/follow (partner dance).
    var hasPartnerPerspectives: Bool {
        isPartnerDance && !followSteps.isEmpty
    }
}

// MARK: - Sample Dance Data

extension Dance {
    static let sampleDances: [Dance] =
        twoStepVariations + westernSwing + waltzesAndSchottisches + other + lineDances

    // MARK: Two-Step Variations

    private static let twoStepVariations: [Dance] = [
        Dance(
            id: "texas-two-step",
            name: "Texas Two-Step",
            category: .twoStep,
            summary: "The classic country partner dance — smooth, gliding, Quick-Quick-Slow-Slow around the floor.",
            description: "The classic country partner dance — also called Country Two-Step. Smooth gliding steps around the floor counter-clockwise, Quick-Quick-Slow-Slow timing.",
            leaderVideoURL: nil, followerVideoURL: nil,
            bpm: 170, isPartnerDance: true, difficulty: 3,
            recommendedSongs: [
                "Neon Moon — Brooks & Dunn",
                "Chattahoochee — Alan Jackson",
                "Amarillo By Morning — George Strait"
            ],
            leadSteps: [
                "Quick step forward with left foot",
                "Quick step forward with right foot",
                "Slow step forward with left foot (hold 2 beats)",
                "Slow step forward with right foot (hold 2 beats)"
            ],
            followSteps: [
                "Quick step back with right foot",
                "Quick step back with left foot",
                "Slow step back with right foot (hold 2 beats)",
                "Slow step back with left foot (hold 2 beats)"
            ],
            youtubeID: nil
        ),
        Dance(
            id: "triple-two-step",
            name: "Triple Two-Step",
            category: .twoStep,
            summary: "Also known as Shuffle or Fort Worth Shuffle — two triple-steps then two walking steps.",
            description: "Also called the Shuffle or Fort Worth Shuffle. Two triple-steps followed by two walking steps. Counted: 1-and-2, 3-and-4, walk, walk.",
            leaderVideoURL: nil, followerVideoURL: nil,
            bpm: 140, isPartnerDance: true, difficulty: 5,
            recommendedSongs: ["Boot Scootin' Boogie — Brooks & Dunn", "Fast as You — Dwight Yoakam"],
            leadSteps: [
                "Triple step left (1-and-2): left, right, left",
                "Triple step right (3-and-4): right, left, right",
                "Walk forward on left (5)",
                "Walk forward on right (6)"
            ],
            followSteps: [
                "Triple step right (1-and-2): right, left, right",
                "Triple step left (3-and-4): left, right, left",
                "Walk back on right (5)",
                "Walk back on left (6)"
            ],
            youtubeID: nil
        ),
        Dance(
            id: "double-two-step",
            name: "Double Two-Step",
            category: .twoStep,
            summary: "Two triple-steps and two slow steps. Popular in the Dallas/Fort Worth area.",
            description: "Similar to Triple Two but emphasized with two triple-steps and two slow steps. Sometimes called Progressive Double Two-Step in the Dallas/Fort Worth area.",
            leaderVideoURL: nil, followerVideoURL: nil,
            bpm: 130, isPartnerDance: true, difficulty: 5,
            recommendedSongs: ["Watermelon Crawl — Tracy Byrd", "Honky Tonk Attitude — Joe Diffie"],
            leadSteps: [
                "Triple step forward left (1-and-2)",
                "Triple step forward right (3-and-4)",
                "Slow step forward left (5-6)",
                "Slow step forward right (7-8)"
            ],
            followSteps: [
                "Triple step back right (1-and-2)",
                "Triple step back left (3-and-4)",
                "Slow step back right (5-6)",
                "Slow step back left (7-8)"
            ],
            youtubeID: nil
        ),
        Dance(
            id: "nightclub-two-step",
            name: "Nightclub Two-Step",
            category: .twoStep,
            summary: "Slow, romantic partner dance for mid-tempo ballads. Invented by Buddy Schwimmer in the 1960s.",
            description: "Slow, romantic partner dance developed by Buddy Schwimmer in the 1960s. Danced to mid-tempo ballads in 4/4 time with a Quick-Quick-Slow rhythm.",
            leaderVideoURL: nil, followerVideoURL: nil,
            bpm: 85, isPartnerDance: true, difficulty: 4,
            recommendedSongs: [
                "Lady in Red — Chris de Burgh",
                "Amazed — Lonestar",
                "Dance with My Father — Luther Vandross"
            ],
            leadSteps: [
                "Rock step back on your left foot (quick)",
                "Replace your weight forward onto your right foot (quick)",
                "Step to the side with your left foot (slow)",
                "Rock step back on your right foot (quick)",
                "Replace your weight forward onto your left foot (quick)",
                "Step to the side with your right foot (slow)"
            ],
            followSteps: [
                "Rock step back on your right foot (quick)",
                "Replace your weight forward onto your left foot (quick)",
                "Step to the side with your right foot (slow)",
                "Rock step back on your left foot (quick)",
                "Replace your weight forward onto your right foot (quick)",
                "Step to the side with your left foot (slow)"
            ],
            youtubeID: nil
        ),
        Dance(
            id: "progressive-two-step",
            name: "Progressive Two-Step",
            category: .twoStep,
            summary: "Texas variation with straight-line travel and defined patterns like Pop Turns and the Wrap.",
            description: "A Texas variation where the follower backs straight along the line of dance instead of zig-zagging. Keeps Quick-Quick-Slow-Slow timing but adds defined patterns like Pop Turns and the Wrap.",
            leaderVideoURL: nil, followerVideoURL: nil,
            bpm: 160, isPartnerDance: true, difficulty: 4,
            recommendedSongs: ["Should've Been a Cowboy — Toby Keith", "Fishin' in the Dark — Nitty Gritty Dirt Band"],
            leadSteps: [
                "Quick step forward left",
                "Quick step forward right",
                "Slow step forward left",
                "Slow step forward right"
            ],
            followSteps: [
                "Quick step back right",
                "Quick step back left",
                "Slow step back right",
                "Slow step back left"
            ],
            youtubeID: nil
        ),
        Dance(
            id: "rhythm-two-step",
            name: "Rhythm Two-Step",
            category: .twoStep,
            summary: "Arizona-style variation with a distinct rhythmic feel on the QQSS foundation.",
            description: "Arizona-style variation of the Two-Step with a distinct rhythmic feel. Same QQSS foundation but with different stylistic accents.",
            leaderVideoURL: nil, followerVideoURL: nil,
            bpm: 150, isPartnerDance: true, difficulty: 4,
            recommendedSongs: ["My Maria — Brooks & Dunn"],
            leadSteps: [
                "Quick step forward with your left foot",
                "Quick step forward with your right foot",
                "Slow step forward with your left foot with a rhythmic hip accent",
                "Slow step forward with your right foot with a rhythmic hip accent"
            ],
            followSteps: [
                "Quick step back with your right foot",
                "Quick step back with your left foot",
                "Slow step back with your right foot with a rhythmic hip accent",
                "Slow step back with your left foot with a rhythmic hip accent"
            ],
            youtubeID: nil
        ),
        Dance(
            id: "shadow-two-step",
            name: "Shadow Two-Step",
            category: .twoStep,
            summary: "Follower stands in front of the lead, both facing down the line of dance.",
            description: "Variation where the follower stands in front of the lead and both face down the line of dance. Same QQSS count, with the follower using the lead's footwork.",
            leaderVideoURL: nil, followerVideoURL: nil,
            bpm: 160, isPartnerDance: true, difficulty: 6,
            recommendedSongs: ["Check Yes or No — George Strait"],
            leadSteps: [
                "Set up with follow directly in front of you, both facing the line of dance, your right arm lightly around her waist",
                "Quick step forward with your left foot",
                "Quick step forward with your right foot",
                "Slow step forward with your left foot",
                "Slow step forward with your right foot"
            ],
            followSteps: [
                "Stand in front of the lead, facing the line of dance — you'll use the same footwork as the lead",
                "Quick step forward with your left foot",
                "Quick step forward with your right foot",
                "Slow step forward with your left foot",
                "Slow step forward with your right foot"
            ],
            youtubeID: nil
        ),
        Dance(
            id: "one-step",
            name: "One-Step",
            category: .twoStep,
            summary: "The simplest country partner dance — one step per beat, walking around the floor.",
            description: "The simplest country couple dance. One step per beat of music, walking around the floor in the line of dance. Predecessor to most other country dances and still used for very fast songs where two-step timing is impossible.",
            leaderVideoURL: nil, followerVideoURL: nil,
            bpm: 200, isPartnerDance: true, difficulty: 1,
            recommendedSongs: ["Deep in the Heart of Texas — traditional"],
            leadSteps: [
                "Step forward with your left foot",
                "Step forward with your right foot",
                "Step forward with your left foot",
                "Step forward with your right foot — one step per beat, traveling counter-clockwise around the floor"
            ],
            followSteps: [
                "Step backward with your right foot",
                "Step backward with your left foot",
                "Step backward with your right foot",
                "Step backward with your left foot — mirror your partner, moving in time with the beat"
            ],
            youtubeID: nil
        ),
    ]

    // MARK: Western Swing & Partner (including cha-chas and polkas)

    private static let westernSwing: [Dance] = [
        Dance(
            id: "east-coast-swing",
            name: "East Coast Swing",
            category: .swing,
            summary: "Upbeat 6-count swing with triple-steps and a rock step. A country bar essential.",
            description: "Classic swing partner dance with a 6-count pattern: triple-step, triple-step, rock step. Danced at most country bars to medium-to-fast tempo songs. The foundation for most country swing variations.",
            leaderVideoURL: nil, followerVideoURL: nil,
            bpm: 144, isPartnerDance: true, difficulty: 4,
            recommendedSongs: ["Boot Scootin' Boogie — Brooks & Dunn", "Rock My World — Brooks & Dunn"],
            leadSteps: [
                "Triple step to the left (1-and-2)",
                "Triple step to the right (3-and-4)",
                "Rock step back on left, recover on right (5-6)"
            ],
            followSteps: [
                "Triple step to the right (1-and-2)",
                "Triple step to the left (3-and-4)",
                "Rock step back on right, recover on left (5-6)"
            ],
            youtubeID: nil
        ),
        Dance(
            id: "west-coast-swing",
            name: "West Coast Swing",
            category: .swing,
            summary: "Smooth, slotted swing with elastic push-pull connection. Works with contemporary country.",
            description: "A slotted, smooth partner dance where the follower moves up and down a linear 'slot'. Features push-pull connection and elastic movement. Works with a wide range of music including contemporary country and pop.",
            leaderVideoURL: nil, followerVideoURL: nil,
            bpm: 120, isPartnerDance: true, difficulty: 7,
            recommendedSongs: ["Body Like a Back Road — Sam Hunt", "Cruise — Florida Georgia Line"],
            leadSteps: [
                "Walk forward along the slot: step forward with your left foot (count 1)",
                "Step forward with your right foot (count 2)",
                "Triple step in place: left-right-left (counts 3-and-4)",
                "Anchor step in place: right-left-right, keeping weight back (counts 5-and-6)"
            ],
            followSteps: [
                "Walk backward down the slot: step back with your right foot (count 1)",
                "Step back with your left foot (count 2)",
                "Triple step in place: right-left-right (counts 3-and-4)",
                "Anchor step in place: left-right-left, maintaining elastic tension with the lead (counts 5-and-6)"
            ],
            youtubeID: nil
        ),
        Dance(
            id: "country-jitterbug",
            name: "Country Jitterbug",
            category: .swing,
            summary: "Energetic single-step swing popular at country dance halls. Simpler than East Coast Swing.",
            description: "An energetic 6-count swing popular in country dance halls. Simpler than East Coast Swing — uses single steps instead of triple-steps, making it easier for beginners to pick up.",
            leaderVideoURL: nil, followerVideoURL: nil,
            bpm: 150, isPartnerDance: true, difficulty: 3,
            recommendedSongs: ["T-R-O-U-B-L-E — Travis Tritt"],
            leadSteps: [
                "Step forward with your left foot (count 1)",
                "Step forward with your right foot (count 2)",
                "Rock step back on your left foot, then recover forward on your right (counts 3-4)",
                "Repeat the 6-count pattern"
            ],
            followSteps: [
                "Step backward with your right foot (count 1)",
                "Step backward with your left foot (count 2)",
                "Rock step back on your right foot, then recover forward on your left (counts 3-4)",
                "Repeat the 6-count pattern"
            ],
            youtubeID: nil
        ),
        Dance(
            id: "aggie-swing",
            name: "Aggie Swing",
            category: .swing,
            summary: "Show-style swing popularized by the Texas A&M Aggie Wranglers. Spins, tricks, and lifts.",
            description: "Exhibition-style swing first popularized by the Aggie Wranglers, a show dance team from Texas A&M University. Combines Polka and Jitterbug steps with spins, tricks, and lifts. Intended for performance — not typical social dancing.",
            leaderVideoURL: nil, followerVideoURL: nil,
            bpm: 170, isPartnerDance: true, difficulty: 9,
            recommendedSongs: ["Deep in the Heart of Texas — various"],
            leadSteps: [
                "Start in a polka-style closed hold with the follow",
                "Polka basic: hop-step forward with your left foot, close right, step forward left — then repeat starting right",
                "Build momentum into spins: lead a free spin by raising your left hand",
                "Transition into dips, drops, and aerial tricks — requires trained follow and spotters"
            ],
            followSteps: [
                "Start in closed polka hold with the lead",
                "Polka basic: hop-step forward with your right foot, close left, step forward right — mirror the lead",
                "Follow spin leads by staying on the ball of your foot",
                "Trust the lead for tricks and lifts — never attempt aerials without proper training"
            ],
            youtubeID: nil
        ),
        Dance(
            id: "country-polka",
            name: "Country Polka",
            category: .swing,
            summary: "Fast, bouncy partner dance that travels around the floor. A traditional dance hall staple.",
            description: "Traditional partner dance with a lively 2/4 rhythm. Hop-step-close-step pattern travels around the floor counter-clockwise. A staple at classic Texas dance halls.",
            leaderVideoURL: nil, followerVideoURL: nil,
            bpm: 120, isPartnerDance: true, difficulty: 4,
            recommendedSongs: ["Beer Barrel Polka — traditional", "In Heaven There Is No Beer — traditional"],
            leadSteps: [
                "Hop slightly onto your right foot (and)",
                "Step forward with your left foot (count 1)",
                "Close your right foot next to your left (count 2)",
                "Step forward with your left foot (count 3)",
                "Repeat the pattern starting with a hop onto your left foot, leading with your right"
            ],
            followSteps: [
                "Hop slightly onto your left foot (and)",
                "Step back with your right foot (count 1)",
                "Close your left foot next to your right (count 2)",
                "Step back with your right foot (count 3)",
                "Repeat the pattern starting with a hop onto your right foot, leading back with your left"
            ],
            youtubeID: nil
        ),
        Dance(
            id: "polka-ten-step",
            name: "Polka Ten Step",
            category: .swing,
            summary: "Ten-count promenade dance in polka rhythm. Also called Ten Step Polka.",
            description: "Classic Western promenade dance that combines a 10-step stationary pattern with polka-style forward travel. Partners dance side-by-side in sweetheart position around the floor.",
            leaderVideoURL: nil, followerVideoURL: nil,
            bpm: 120, isPartnerDance: true, difficulty: 5,
            recommendedSongs: ["Cotton Eye Joe — traditional", "What's It to You — Clay Walker"],
            leadSteps: [
                "Start in sweetheart position — partners side by side, hands joined in front, follow on your right",
                "Touch your left heel forward (count 1), then touch your left toe next to your right foot (count 2)",
                "Touch your left heel forward (count 3), then close your left foot next to your right (count 4)",
                "Touch your right heel forward (count 5), then touch your right toe next to your left foot (count 6)",
                "Touch your right heel forward (count 7), then close your right foot next to your left (count 8)",
                "Two polka steps forward around the floor: hop-step-close-step, then repeat (counts 9-10 and beyond)"
            ],
            followSteps: ["Mirror the lead's 10-step pattern in sweetheart position, using the same footwork starting with your left foot"],
            youtubeID: nil
        ),
        Dance(
            id: "traveling-cha-cha",
            name: "Traveling Cha-Cha",
            category: .swing,
            summary: "Progressive country cha-cha that travels around the floor. Upbeat and fun.",
            description: "Country variation of the cha-cha that travels counter-clockwise around the dance floor. Maintains classic cha-cha timing (1, 2, 3-and-4) but with a progressive, traveling feel instead of ballroom's stationary hip action.",
            leaderVideoURL: nil, followerVideoURL: nil,
            bpm: 125, isPartnerDance: true, difficulty: 5,
            recommendedSongs: ["Neon Moon — Brooks & Dunn", "My Maria — Brooks & Dunn"],
            leadSteps: [
                "Rock step forward with your left foot (count 1)",
                "Replace your weight back onto your right foot (count 2)",
                "Triple step backward traveling along the line of dance: left-right-left (counts 3-and-4)",
                "Rock step back on your right foot (count 5)",
                "Replace your weight forward onto your left foot (count 6)",
                "Triple step forward: right-left-right (counts 7-and-8)"
            ],
            followSteps: [
                "Rock step back with your right foot (count 1)",
                "Replace your weight forward onto your left foot (count 2)",
                "Triple step forward: right-left-right (counts 3-and-4)",
                "Rock step forward on your left foot (count 5)",
                "Replace your weight back onto your right foot (count 6)",
                "Triple step backward: left-right-left (counts 7-and-8)"
            ],
            youtubeID: nil
        ),
        Dance(
            id: "cowboy-cha-cha",
            name: "Cowboy Cha-Cha",
            category: .swing,
            summary: "20-count 90s-era dance. Can be done as singles, partnered, or as a line dance.",
            description: "20-count partner dance from the 1990s. Can be danced as singles, partnered, or as a line dance. Five repeated step patterns.",
            leaderVideoURL: nil, followerVideoURL: nil,
            bpm: 100, isPartnerDance: true, difficulty: 5,
            recommendedSongs: ["Neon Moon — Brooks & Dunn", "Gone Country — Alan Jackson"],
            leadSteps: [
                "Side-by-side sweetheart position with the follow on your right",
                "Rock step forward with your left foot, replace back onto your right (counts 1-2)",
                "Triple step in place: left-right-left (counts 3-and-4)",
                "Rock step back with your right foot, replace forward onto your left (counts 5-6)",
                "Triple step in place: right-left-right (counts 7-and-8)",
                "Execute a 4-count turn — lead the follow under your joined hands as you rotate right",
                "Repeat the full 20-count pattern"
            ],
            followSteps: ["Mirror the lead's pattern starting with your right foot, accepting the turn lead"],
            youtubeID: nil
        ),
        Dance(
            id: "ten-step",
            name: "Ten Step",
            category: .swing,
            summary: "Ten stationary footwork steps followed by forward shuffles. Danced as partners with optional twirls.",
            description: "Partner dance with ten stationary footwork steps followed by a series of forward shuffles. The pair holds hands and repeats the pattern with optional twirls.",
            leaderVideoURL: nil, followerVideoURL: nil,
            bpm: 140, isPartnerDance: true, difficulty: 5,
            recommendedSongs: ["What's It to You — Clay Walker"],
            leadSteps: [
                "Start side-by-side with the follow, hands joined in sweetheart position",
                "Touch your left heel forward (count 1), then touch your left toe back (count 2)",
                "Touch your left heel forward (count 3), then close your left foot beside your right (count 4)",
                "Touch your right heel forward (count 5), then cross your right toe over your left (count 6)",
                "Touch your right heel to the side (count 7), then close your right foot beside your left (count 8)",
                "Shuffle forward: left-right-left (counts 9-and-10)",
                "Shuffle forward: right-left-right (counts 11-and-12)",
                "Optional: lead the follow through a twirl on the shuffle counts"
            ],
            followSteps: ["Mirror the lead's 10-step pattern starting with the same heel-toe touches, accept twirl leads during shuffles"],
            youtubeID: nil
        ),
        Dance(
            id: "horseshoe",
            name: "Horseshoe",
            category: .swing,
            summary: "Circle-style partner promenade danced around the floor as a group.",
            description: "Traditional Western promenade dance where couples form a large circle (horseshoe) and travel around the floor together. Includes a round-the-room couples mixer.",
            leaderVideoURL: nil, followerVideoURL: nil,
            bpm: 130, isPartnerDance: true, difficulty: 4,
            recommendedSongs: ["Should've Been a Cowboy — Toby Keith"],
            leadSteps: [
                "Form a large circle (horseshoe) around the floor with the other couples, all facing counter-clockwise",
                "Take sweetheart position with the follow on your right, hands joined in front",
                "Grapevine to the right: step right, cross your left behind right, step right, touch left beside right",
                "Grapevine to the left: step left, cross your right behind left, step left, touch right beside left",
                "Quarter turn left together, progressing around the floor",
                "Repeat the pattern — the couple ahead is your next partner in the mixer exchange"
            ],
            followSteps: ["Mirror the lead's grapevine pattern in sweetheart position, moving with the circle"],
            youtubeID: nil
        ),
    ]

    // MARK: Waltzes & Schottisches

    private static let waltzesAndSchottisches: [Dance] = [
        Dance(
            id: "country-waltz",
            name: "Country Waltz",
            category: .waltz,
            summary: "Graceful 3/4 partner dance that travels continuously around the line of dance.",
            description: "Beautiful, graceful partner dance in 3/4 time. Unlike ballroom waltz's box pattern, Country Waltz travels continuously around the dance floor in the line of dance.",
            leaderVideoURL: nil, followerVideoURL: nil,
            bpm: 90, isPartnerDance: true, difficulty: 3,
            recommendedSongs: ["Tennessee Waltz — Patti Page", "Could I Have This Dance — Anne Murray"],
            leadSteps: [
                "Step forward left (1)",
                "Step forward right (2)",
                "Close left to right (3)",
                "Step forward right (1)",
                "Step forward left (2)",
                "Close right to left (3)"
            ],
            followSteps: [
                "Step back right (1)",
                "Step back left (2)",
                "Close right to left (3)",
                "Step back left (1)",
                "Step back right (2)",
                "Close left to right (3)"
            ],
            youtubeID: nil
        ),
        Dance(
            id: "cross-step-waltz",
            name: "Cross-Step Waltz",
            category: .waltz,
            summary: "Smooth rotating waltz with a signature cross-step on the first beat.",
            description: "A modern partner waltz where the dancers cross one foot over the other on the first beat of each measure, then step side and forward. Popular as a social alternative to rotary waltz.",
            leaderVideoURL: nil, followerVideoURL: nil,
            bpm: 100, isPartnerDance: true, difficulty: 5,
            recommendedSongs: ["Fields of Gold — Sting", "The Dance — Garth Brooks"],
            leadSteps: [
                "Cross your left foot over your right foot (count 1)",
                "Step to the side with your right foot (count 2)",
                "Step in place with your left foot (count 3)",
                "Cross your right foot over your left foot (count 1)",
                "Step to the side with your left foot (count 2)",
                "Step in place with your right foot (count 3)"
            ],
            followSteps: ["Mirror the lead's crossing pattern, starting with your right foot crossing over your left"],
            youtubeID: nil
        ),
        Dance(
            id: "pursuit-waltz",
            name: "Pursuit Waltz",
            category: .waltz,
            summary: "1940s-era Texas waltz where the lead follows behind the follow. Distinctive traveling feel.",
            description: "A modern (1940s-50s) waltz variation from the West where the lead 'pursues' the follow down the line of dance rather than the traditional closed-frame rotary pattern. Distinctive Texas dance-hall flavor.",
            leaderVideoURL: nil, followerVideoURL: nil,
            bpm: 95, isPartnerDance: true, difficulty: 4,
            recommendedSongs: ["You Look So Good in Love — George Strait"],
            leadSteps: [
                "Start in open handhold behind the follow, both facing the line of dance — you 'pursue' her as she travels forward",
                "Step forward with your left foot (count 1)",
                "Step forward with your right foot (count 2)",
                "Close your left foot next to your right (count 3)",
                "Step forward with your right foot (count 1)",
                "Step forward with your left foot (count 2)",
                "Close your right foot next to your left (count 3)",
                "Periodically lead the follow into a spin under your raised hand while continuing to travel forward"
            ],
            followSteps: [
                "Start in front of the lead, both facing the line of dance — you lead the travel",
                "Step forward with your right foot (count 1), forward left (count 2), close right (count 3)",
                "Step forward with your left foot (count 1), forward right (count 2), close left (count 3)",
                "When the lead raises your hand, execute a spin in place then continue traveling forward"
            ],
            youtubeID: nil
        ),
        Dance(
            id: "queens-waltz",
            name: "Queen's Waltz",
            category: .waltz,
            summary: "36-step partner/circle waltz that progresses through four walls like a line dance.",
            description: "Stationary partner waltz with a 36-step pattern that progresses through four walls, similar to a line dance. Often danced alone or in a circle at country bars.",
            leaderVideoURL: nil, followerVideoURL: nil,
            bpm: 100, isPartnerDance: true, difficulty: 4,
            recommendedSongs: ["Could I Have This Dance — Anne Murray"],
            leadSteps: [
                "Waltz basic forward: step forward left (1), right (2), close left (3)",
                "Waltz basic backward: step back right (1), left (2), close right (3)",
                "Twinkle forward: cross your left over right (1), side right (2), close left (3)",
                "Twinkle backward: cross your right behind left (1), side left (2), close right (3)",
                "Under-arm turn: raise joined hands and lead the follow through a full rotation over 3 counts",
                "Quarter turn to the new wall and repeat the 36-count sequence"
            ],
            followSteps: [
                "Mirror the lead's basic using opposite feet — step back right when he steps forward left",
                "Follow the twinkle and under-arm turns as led",
                "Face the new wall on the quarter turn and repeat"
            ],
            youtubeID: nil
        ),
        Dance(
            id: "schottische",
            name: "Schottische",
            category: .waltz,
            summary: "Traditional partner or line dance in 4/4 with a step-step-step-hop pattern.",
            description: "Romantic partner or line dance in 4/4 time with a step-step-step-hop pattern. Originated in 19th-century Europe and traveled with settlers to Texas dance halls.",
            leaderVideoURL: nil, followerVideoURL: nil,
            bpm: 110, isPartnerDance: true, difficulty: 3,
            recommendedSongs: ["Cotton Eye Joe — traditional", "Put Your Little Foot — traditional"],
            leadSteps: [
                "Step left forward (1)",
                "Step right forward (2)",
                "Step left forward (3)",
                "Hop on left (4)",
                "Repeat starting right"
            ],
            followSteps: [
                "Step right forward (1)",
                "Step left forward (2)",
                "Step right forward (3)",
                "Hop on right (4)",
                "Repeat starting left"
            ],
            youtubeID: nil
        ),
        Dance(
            id: "sweetheart-schottische",
            name: "Sweetheart Schottische",
            category: .waltz,
            summary: "Partner schottische in sweetheart hold. Traveling step-step-step-hop pattern for couples.",
            description: "Schottische variation danced in sweetheart position (partners side by side, crossed hands in front). Classic Texas dance-hall mixer.",
            leaderVideoURL: nil, followerVideoURL: nil,
            bpm: 115, isPartnerDance: true, difficulty: 4,
            recommendedSongs: ["All You Ever Do Is Bring Me Down — The Mavericks"],
            leadSteps: [
                "Start in sweetheart position with the follow on your right, hands crossed in front, both facing the line of dance",
                "Step forward with your left foot (count 1)",
                "Step forward with your right foot (count 2)",
                "Step forward with your left foot (count 3)",
                "Hop on your left foot while lifting your right knee (count 4)",
                "Repeat starting with your right foot",
                "After 4 schottische patterns, lead the follow through a turn under your raised arm"
            ],
            followSteps: [
                "Start in sweetheart position on the lead's right, using the same footwork as the lead",
                "Step forward right (1), left (2), right (3), hop on your right while lifting your left knee (4)",
                "Repeat starting with your left foot",
                "Execute the turn under the lead's raised arm when signaled"
            ],
            youtubeID: nil
        ),
    ]

    // MARK: Other (round dances, square, clogging)

    private static let other: [Dance] = [
        Dance(
            id: "square-dance",
            name: "Square Dance",
            category: .other,
            summary: "Four couples in a square following a caller. America's traditional folk dance.",
            description: "Traditional American folk dance where four couples form a square and follow the instructions of a caller. Calls include allemande left, do-si-do, promenade, and swing your partner.",
            leaderVideoURL: nil, followerVideoURL: nil,
            bpm: 130, isPartnerDance: true, difficulty: 3,
            recommendedSongs: ["Turkey in the Straw — traditional", "Orange Blossom Special — traditional"],
            leadSteps: [
                "Form a square with three other couples, each couple facing the center",
                "Listen to the caller — every move is announced in real time",
                "Allemande Left: turn the opposite dancer (corner) with your left hand, then release",
                "Do-Si-Do: pass right shoulders with your partner, back-to-back, then return",
                "Promenade: take hands with your partner and walk counter-clockwise around the square",
                "Swing: hold your partner in closed position and rotate clockwise",
                "Common calls also include Circle Left, Circle Right, Ladies Chain, and Grand Right and Left"
            ],
            followSteps: ["Face the center with your partner, respond to each call as the gentleman does — allemande left with your corner, do-si-do your partner, promenade home"],
            youtubeID: nil
        ),
        Dance(
            id: "contra-dance",
            name: "Contra Dance",
            category: .other,
            summary: "Two long lines facing each other, progressive couples dance with a caller.",
            description: "Traditional American folk dance where couples form two long parallel lines facing each other. The dance progresses as couples move up or down the line to new partners. Like square dance with a caller.",
            leaderVideoURL: nil, followerVideoURL: nil,
            bpm: 120, isPartnerDance: true, difficulty: 3,
            recommendedSongs: ["Old-time fiddle tunes"],
            leadSteps: [
                "Form two long parallel lines facing your partner across the set — gentlemen on one side, ladies on the other",
                "Listen to the caller — common moves include swing your partner, do-si-do, allemande, and chain",
                "Balance and swing: step toward partner and back, then swing in closed position",
                "Ladies' chain: ladies cross over to opposite gentleman, who turns them around",
                "Progress down the line: at the end of each sequence, advance one position to a new partner"
            ],
            followSteps: ["Stand across from your partner in the opposite line, respond to the caller's instructions and progress down the line to a new partner each sequence"],
            youtubeID: nil
        ),
        Dance(
            id: "clogging",
            name: "Clogging",
            category: .other,
            summary: "Appalachian step dance — percussive footwork with heel and toe taps.",
            description: "Appalachian step dance danced in groups to bluegrass or old-time music. Features percussive heel-and-toe footwork similar to tap dance but with distinct mountain-music roots. Often performed in rhinestone costumes at competitions.",
            leaderVideoURL: nil, followerVideoURL: nil,
            bpm: 120, isPartnerDance: false, difficulty: 5,
            recommendedSongs: ["Rocky Top — Osborne Brothers", "Orange Blossom Special — Johnny Cash"],
            leadSteps: [
                "Basic double-toe: brush the ball of your right foot forward, then brush it back (double-toe)",
                "Heel: drop your right heel for a sharp tap (count 'and')",
                "Step: transfer weight fully onto your right foot",
                "Repeat on the opposite side: brush-brush-heel-step with your left foot",
                "Add accents: chug (slide and tap), rock (weight shift side-to-side), slide (heel-toe travel), drag (drag back foot behind)",
                "Chain basic steps together into longer patterns as learned in routines"
            ],
            followSteps: [],
            youtubeID: nil
        ),
    ]

    // MARK: Line Dances (solo — single step list)

    private static let lineDances: [Dance] = [
        Dance(
            id: "electric-slide",
            name: "Electric Slide",
            category: .lineDance,
            summary: "18-count 4-wall beginner favorite. Grapevines right and left, walk-back, quarter turn.",
            description: "Choreographed by Ric Silver in 1976. 18-count, 4-wall dance made famous by Marcia Griffiths' Electric Boogie. An easy starting point for beginners.",
            leaderVideoURL: nil, followerVideoURL: nil,
            bpm: 120, isPartnerDance: false, difficulty: 2,
            recommendedSongs: [
                "Electric Boogie — Marcia Griffiths",
                "I Like It, I Love It — Tim McGraw",
                "Why Don't We Just Dance — Josh Turner"
            ],
            leadSteps: [
                "Grapevine right: step right, cross your left behind your right, step right, scuff left beside right (counts 1-4)",
                "Grapevine left: step left, cross your right behind your left, step left, scuff right beside left (counts 5-8)",
                "Walk backward: step back right, back left, back right, touch left beside right (counts 9-12)",
                "Forward-back: step forward left, touch right beside left, step back right, touch left beside right (counts 13-16)",
                "Step forward on your left with a quarter turn to the left, then scuff your right heel forward (counts 17-18)",
                "Restart facing the new wall"
            ],
            followSteps: [],
            youtubeID: nil
        ),
        Dance(
            id: "cupid-shuffle",
            name: "Cupid Shuffle",
            category: .lineDance,
            summary: "32-count beginner favorite. The lyrics tell you every move.",
            description: "32-count line dance by Cupid (Bernard Bryson), 2006. Lyrics call out the moves — great for beginners and crossover crowds.",
            leaderVideoURL: nil, followerVideoURL: nil,
            bpm: 125, isPartnerDance: false, difficulty: 1,
            recommendedSongs: ["Cupid Shuffle — Cupid"],
            leadSteps: [
                "Step to the right with your right foot, bring your left foot to meet it — repeat 4 times",
                "Step to the left with your left foot, bring your right foot to meet it — repeat 4 times",
                "Kick forward with your right foot 2 times, then your left foot 2 times",
                "Walk in place with a quarter turn to the left over 4 counts — 'walk it by yourself'"
            ],
            followSteps: [],
            youtubeID: nil
        ),
        Dance(
            id: "cha-cha-slide",
            name: "Cha-Cha Slide",
            category: .lineDance,
            summary: "The lyrics call every move. Perfect for mixed crowds and weddings.",
            description: "Party line dance by DJ Casper where the lyrics call out every move. Perfect for mixed crowds — country bars to weddings.",
            leaderVideoURL: nil, followerVideoURL: nil,
            bpm: 120, isPartnerDance: false, difficulty: 1,
            recommendedSongs: ["Cha-Cha Slide — DJ Casper"],
            leadSteps: [
                "Slide to the left with your left foot, bring your right foot to meet it",
                "Slide to the right with your right foot, bring your left foot to meet it",
                "Criss-cross: jump feet apart, then cross right over left (and reverse)",
                "Cha-cha triple step: left-right-left, then right-left-right",
                "Follow the lyrics — the song calls every move"
            ],
            followSteps: [],
            youtubeID: nil
        ),
        Dance(
            id: "wobble",
            name: "Wobble",
            category: .lineDance,
            summary: "Party crowd-pleaser to V.I.C.'s hit. Step right, step left, wobble, bounce.",
            description: "Party line dance to V.I.C.'s 'Wobble'. Simple crowd-pleaser — steps right, left, wobble front/back, and bounce in place.",
            leaderVideoURL: nil, followerVideoURL: nil,
            bpm: 125, isPartnerDance: false, difficulty: 1,
            recommendedSongs: ["Wobble — V.I.C."],
            leadSteps: [
                "Step to the right with your right foot, bring your left foot to meet it — 4 counts",
                "Step to the left with your left foot, bring your right foot to meet it — 4 counts",
                "'Wobble' forward: bounce your hips/shoulders forward for 4 counts",
                "'Wobble' back: bounce your hips/shoulders back for 4 counts",
                "Bounce in place with a quarter turn to the left, then repeat facing the new wall"
            ],
            followSteps: [],
            youtubeID: nil
        ),
        Dance(
            id: "achy-breaky-heart",
            name: "Achy Breaky Heart",
            category: .lineDance,
            summary: "Billy Ray Cyrus's 1992 classic. The line dance that launched the 90s country craze.",
            description: "The line dance that brought country line dancing into the mainstream. Choreographed to Billy Ray Cyrus's 1992 mega-hit. Heel struts, hip swings, and quarter turns.",
            leaderVideoURL: nil, followerVideoURL: nil,
            bpm: 120, isPartnerDance: false, difficulty: 2,
            recommendedSongs: ["Achy Breaky Heart — Billy Ray Cyrus"],
            leadSteps: [
                "Grapevine right with hold: step right, cross your left behind right, step right, hold (counts 1-4)",
                "Hip bumps: bump your hips left, right, left, hold — end with your weight on the left (counts 5-8)",
                "Star turn: touch your right toe back, touch it to the side, step forward right pivoting a quarter left (counts 9-11)",
                "Spin a half turn left on your left foot, then step back on your right (count 12)",
                "Walk backward: step back left, step back right, step back left, stomp right together (counts 13-16)",
                "Weight shift: step right to the side and bump hips right-left-right-hold (counts 17-20)",
                "Quarter turn right, stomp left together, step left side, stomp right together (counts 21-24)",
                "Grapevine right again: step right, cross left behind, step right, stomp left next to right with clap (counts 25-32)"
            ],
            followSteps: [],
            youtubeID: nil
        ),
        Dance(
            id: "cowboy-hustle",
            name: "Cowboy Hustle",
            category: .lineDance,
            summary: "Slow-tempo beginner line dance with simple step-touches and vines.",
            description: "Slow-tempo country-western line dance with simple repeated footwork. Great for beginners.",
            leaderVideoURL: nil, followerVideoURL: nil,
            bpm: 95, isPartnerDance: false, difficulty: 2,
            recommendedSongs: ["Cotton Eye Joe — Rednex", "Neon Moon — Brooks & Dunn"],
            leadSteps: [
                "Step-touch right: step right, touch left beside right (counts 1-2)",
                "Step-touch left: step left, touch right beside left (counts 3-4)",
                "Grapevine right: step right, cross left behind, step right, touch left beside right (counts 5-8)",
                "Grapevine left: step left, cross right behind, step left, touch right beside left (counts 9-12)",
                "Walk forward: step forward right, left, right, touch left beside right (counts 13-16)",
                "Walk back with a quarter turn left: step back left, right, left with a quarter turn, touch right (counts 17-20)",
                "Repeat the 20-count pattern facing the new wall"
            ],
            followSteps: [],
            youtubeID: nil
        ),
        Dance(
            id: "cowboy-boogie",
            name: "Cowboy Boogie",
            category: .lineDance,
            summary: "Easy grapevines, hip bumps, and walks. Works to many country songs.",
            description: "Classic line dance done to many country songs. Easy to learn, plenty of regional variations — a great intro dance.",
            leaderVideoURL: nil, followerVideoURL: nil,
            bpm: 120, isPartnerDance: false, difficulty: 2,
            recommendedSongs: ["Ridin' the Rodeo — various", "Wagon Wheel — Darius Rucker"],
            leadSteps: [
                "Grapevine right: step right, cross your left behind right, step right, scuff left beside right (counts 1-4)",
                "Grapevine left: step left, cross your right behind left, step left, scuff right beside left (counts 5-8)",
                "Walk forward: step forward right, left, right, hitch your left knee (counts 9-12)",
                "Walk backward: step back left, right, left, hitch your right knee (counts 13-16)",
                "Bump your hips forward twice, then back twice (counts 17-20)",
                "Bump your hips right, left, right, left (counts 21-24)",
                "Execute a quarter turn left to face the new wall"
            ],
            followSteps: [],
            youtubeID: nil
        ),
        Dance(
            id: "cowboy-up",
            name: "Cowboy Up",
            category: .lineDance,
            summary: "Beginner-friendly line dance with heel touches, grapevines, and a quarter turn.",
            description: "Easy beginner line dance choreographed by Barbara Hile. Friendly entry point for someone new to line dancing.",
            leaderVideoURL: nil, followerVideoURL: nil,
            bpm: 120, isPartnerDance: false, difficulty: 2,
            recommendedSongs: ["Cowboy Up — Jill Johnson"],
            leadSteps: [
                "Touch right heel forward, step right home (counts 1-2)",
                "Touch left heel forward, step left home (counts 3-4)",
                "Grapevine right with a clap: step right, cross your left behind, step right, clap (counts 5-8)",
                "Grapevine left with a clap: step left, cross your right behind, step left, clap (counts 9-12)",
                "Walk forward: step right, left, right, kick left forward (counts 13-16)",
                "Walk backward with a quarter turn left: step back left, right, left turning a quarter left, touch right (counts 17-20)",
                "Repeat the 20-count pattern facing the new wall"
            ],
            followSteps: [],
            youtubeID: nil
        ),
        Dance(
            id: "macarena",
            name: "Macarena",
            category: .lineDance,
            summary: "1990s worldwide craze. Arm sequence then hip sway and jump-turn.",
            description: "Los Del Rio's 1990s hit. Series of arm movements (hands out, palms down, shoulders, head, hips) followed by a hip sway and jump-turn. Danced in country bars worldwide despite being a Spanish song.",
            leaderVideoURL: nil, followerVideoURL: nil,
            bpm: 105, isPartnerDance: false, difficulty: 1,
            recommendedSongs: ["Macarena — Los Del Rio"],
            leadSteps: [
                "Extend your right arm straight out, palm down (count 1)",
                "Extend your left arm straight out, palm down (count 2)",
                "Flip your right palm up (count 3)",
                "Flip your left palm up (count 4)",
                "Right hand on left shoulder (count 5)",
                "Left hand on right shoulder (count 6)",
                "Right hand behind your head (count 7)",
                "Left hand behind your head (count 8)",
                "Right hand on your left hip (count 9)",
                "Left hand on your right hip (count 10)",
                "Right hand on your right bottom (count 11)",
                "Left hand on your left bottom (count 12)",
                "Roll your hips three times (counts 13-15)",
                "Clap your hands and jump a quarter turn to the left (count 16) — face the new wall and repeat"
            ],
            followSteps: [],
            youtubeID: nil
        ),
        Dance(
            id: "copperhead-road",
            name: "Copperhead Road",
            category: .lineDance,
            summary: "Iconic Irish-flavored line dance with kicks and jumping spins.",
            description: "Iconic line dance to Steve Earle's 1988 country-rock hit. Includes Irish-style kicks and hops.",
            leaderVideoURL: nil, followerVideoURL: nil,
            bpm: 130, isPartnerDance: false, difficulty: 3,
            recommendedSongs: ["Copperhead Road — Steve Earle"],
            leadSteps: [
                "Heel steps: touch right heel forward, step right beside left, touch left heel forward, step left beside right (counts 1-4)",
                "Repeat heel steps: right heel, step, left heel, step (counts 5-8)",
                "Right heel hook: touch right heel forward, hook right heel across left shin, touch right heel forward, step right beside left (counts 9-12)",
                "Left heel hook: touch left heel forward, hook left heel across right shin, touch left heel forward, step left beside right (counts 13-16)",
                "Repeat heel steps: right heel, step, left heel, step (counts 17-20)",
                "Repeat heel steps again: right heel, step, left heel, step (counts 21-24)",
                "Lunge forward on your right foot with a quarter turn to the left, recover on left, step right together, step left together (counts 25-28)",
                "Lunge forward on your right foot, recover on left, step right together, step left together (counts 29-32) — repeat facing the new wall"
            ],
            followSteps: [],
            youtubeID: nil
        ),
        Dance(
            id: "boot-scootin-boogie",
            name: "Boot Scootin' Boogie",
            category: .lineDance,
            summary: "Heel struts, grapevines, and hip bumps to the Brooks & Dunn hit.",
            description: "Classic 4-wall line dance to the Brooks & Dunn hit. Features heel struts, grapevines, and hip bumps.",
            leaderVideoURL: nil, followerVideoURL: nil,
            bpm: 110, isPartnerDance: false, difficulty: 3,
            recommendedSongs: ["Boot Scootin' Boogie — Brooks & Dunn"],
            leadSteps: [
                "Grapevine right: step right, cross your left behind right, step right, touch your left heel diagonally forward with a clap (counts 1-4)",
                "Grapevine left: step left, cross your right behind left, step left, touch your right heel diagonally forward with a clap (counts 5-8)",
                "Step your right foot together, touch your left heel diagonally forward with a clap (counts 9-10)",
                "Step your left foot together, touch your right heel diagonally forward with a clap (counts 11-12)",
                "Swivel both heels right, left, right, center (counts 13-16)",
                "Stomp your right heel beside left twice, then kick your right foot forward twice (counts 17-20)",
                "Ball-change: step on ball of right, step left, stomp right beside left, kick right forward twice (counts 21-24)",
                "Step right forward, hook your left behind your right knee, step back left, hitch right (counts 25-28)",
                "Step back right, hitch left, step forward left, scuff right with a quarter turn left to face the new wall (counts 29-32)"
            ],
            followSteps: [],
            youtubeID: nil
        ),
        Dance(
            id: "watermelon-crawl",
            name: "Watermelon Crawl",
            category: .lineDance,
            summary: "Playful line dance featuring grapevines, heel steps, and a pivot turn.",
            description: "Playful line dance made famous by Tracy Byrd's hit. Features grapevines, heel steps, and a pivot turn.",
            leaderVideoURL: nil, followerVideoURL: nil,
            bpm: 100, isPartnerDance: false, difficulty: 3,
            recommendedSongs: ["Watermelon Crawl — Tracy Byrd"],
            leadSteps: [
                "Touch your right toe next to your left foot (toe turned in), then touch your right heel to the side (counts 1-2)",
                "Triple step in place: right-left-right (counts 3-and-4)",
                "Touch your left toe next to your right foot, then touch your left heel to the side (counts 5-6)",
                "Triple step in place: left-right-left (counts 7-and-8)",
                "Charleston: step forward right, kick left forward, step back left, touch right toe back (counts 9-12)",
                "Charleston repeat: step forward right, kick left forward, step back left, touch right next to left (counts 13-16)",
                "Grapevine right: step right, cross left behind, step right, touch left beside right (counts 17-20)",
                "Grapevine left with a quarter turn: step left, cross right behind, step left with a quarter turn left, touch right (counts 21-24)",
                "Step right forward diagonally, slide left together, clap (counts 25-28)",
                "Step left back diagonally, slide right together, clap (counts 29-32)",
                "Two hip bumps right, two hip bumps left (counts 33-36)",
                "Step right forward with a half pivot turn left, step right forward with another half pivot turn left (counts 37-40)"
            ],
            followSteps: [],
            youtubeID: nil
        ),
        Dance(
            id: "cotton-eyed-joe",
            name: "Cotton-Eyed Joe",
            category: .lineDance,
            summary: "Classic Texas line dance with heel kicks and polka-step travel.",
            description: "Classic country line dance to the Rednex version of the traditional folk tune. Features kicks, heel touches, and polka-style forward movement.",
            leaderVideoURL: nil, followerVideoURL: nil,
            bpm: 150, isPartnerDance: false, difficulty: 3,
            recommendedSongs: ["Cotton Eye Joe — Rednex"],
            leadSteps: [
                "Bring your right knee up and cross your right foot over your left shin (count 1)",
                "Kick your right foot forward (count 2)",
                "Triple step backward: right-left-right (counts 3-and-4)",
                "Bring your left knee up and cross your left foot over your right shin (count 5)",
                "Kick your left foot forward (count 6)",
                "Triple step backward: left-right-left (counts 7-and-8)",
                "Polka step forward: hop, step right forward, close left, step right (counts 9-10)",
                "Polka step forward: hop, step left forward, close right, step left (counts 11-12)",
                "Continue polka-stepping around the floor counter-clockwise"
            ],
            followSteps: [],
            youtubeID: nil
        ),
        Dance(
            id: "canadian-stomp",
            name: "Canadian Stomp",
            category: .lineDance,
            summary: "Classic 90s line dance with stomps, heel digs, and a quarter turn.",
            description: "Classic country line dance with stomps, heel touches, and quarter turns. A 90s country bar staple popularized by Shania Twain's 'Any Man of Mine'.",
            leaderVideoURL: nil, followerVideoURL: nil,
            bpm: 130, isPartnerDance: false, difficulty: 3,
            recommendedSongs: ["Any Man of Mine — Shania Twain"],
            leadSteps: [
                "Touch right toe next to left foot, touch right heel to the side, stomp right forward, hold (counts 1-4)",
                "Touch left toe next to right foot, touch left heel to the side, stomp left forward, hold (counts 5-8)",
                "Repeat toe-heel-stomp-hold with right foot (counts 9-12)",
                "Repeat toe-heel-stomp-hold with left foot (counts 13-16)",
                "Walk backward with claps: step back right, clap, step back left, clap (counts 17-20)",
                "Stomp right together, stomp left in place, stomp right in place, hold with weight on left (counts 21-24)",
                "Grapevine right: step right, cross left behind, step right, touch left (counts 25-28)",
                "Grapevine left with a quarter turn: step left, cross right behind, step left with a quarter turn left, touch right (counts 29-32)",
                "Jazz box: cross right over left, step back left, step right to side, close left beside right (counts 33-36)",
                "Jazz box again: cross right over left, step back left, step right to side, close left beside right (counts 37-40)"
            ],
            followSteps: [],
            youtubeID: nil
        ),
        Dance(
            id: "horseshoe-shuffle",
            name: "Horseshoe Shuffle",
            category: .lineDance,
            summary: "Circle-style 'round-the-room' line dance with optional couple moves.",
            description: "Circle-style line dance, danced in the round. Includes couple moves within the line formation. Popularized by Toby Keith's 'Should've Been a Cowboy'.",
            leaderVideoURL: nil, followerVideoURL: nil,
            bpm: 130, isPartnerDance: false, difficulty: 4,
            recommendedSongs: ["Should've Been a Cowboy — Toby Keith"],
            leadSteps: [
                "Form a circle with the other dancers, all facing the center",
                "Grapevine right: step right, cross left behind, step right, touch left beside right (counts 1-4)",
                "Grapevine left: step left, cross right behind, step left, touch right beside left (counts 5-8)",
                "Walk toward the center: step forward right, left, right, touch left (counts 9-12)",
                "Walk backward out of the center: step back left, right, left, touch right (counts 13-16)",
                "Quarter turn right to face the next wall and repeat the 16-count pattern"
            ],
            followSteps: [],
            youtubeID: nil
        ),
        Dance(
            id: "double-d",
            name: "Double D (Duck Dynasty)",
            category: .lineDance,
            summary: "32-count 4-wall dance with lots of rocking back and forth.",
            description: "32-count, 4-wall line dance choreographed by Trevor Thorton in 2015. Lots of rocking back and forth.",
            leaderVideoURL: nil, followerVideoURL: nil,
            bpm: 115, isPartnerDance: false, difficulty: 3,
            recommendedSongs: ["Cut 'em All — Colt Ford ft. Willie Robertson"],
            leadSteps: [
                "Rock step forward on your right foot, replace weight back on your left (counts 1-2)",
                "Triple step backward: right-left-right (counts 3-and-4)",
                "Rock step back on your left foot, replace weight forward on your right (counts 5-6)",
                "Triple step forward: left-right-left (counts 7-and-8)",
                "Grapevine right: step right, cross left behind, step right, touch left (counts 9-12)",
                "Rock step side left, replace weight right, cross left over right, step right (counts 13-16)",
                "Rock step side right, replace weight left, cross right over left, step left (counts 17-20)",
                "Step forward right with a quarter turn left, step left beside right, jazz box to close (counts 21-28)",
                "Stomp right, stomp left to finish the pattern (counts 29-32)"
            ],
            followSteps: [],
            youtubeID: nil
        ),
        Dance(
            id: "aw-naw",
            name: "Aw Naw",
            category: .lineDance,
            summary: "Upbeat line dance that starts with a distinctive boot kick.",
            description: "Upbeat line dance that emerged alongside Chris Young's 2013 hit. Starts with a distinctive boot kick.",
            leaderVideoURL: nil, followerVideoURL: nil,
            bpm: 130, isPartnerDance: false, difficulty: 3,
            recommendedSongs: ["Aw Naw — Chris Young"],
            leadSteps: [
                "Kick your right boot forward, step down right (counts 1-2)",
                "Kick your left boot forward, step down left (counts 3-4)",
                "Touch your right heel forward, cross right toe over left, touch right heel forward, step right together (counts 5-8)",
                "Grapevine left with a quarter turn: step left, cross right behind, step left with a quarter turn left, scuff right (counts 9-12)",
                "Hip roll right then left (counts 13-16)",
                "Walk forward: step right, left, right, hitch left with a quarter turn left (counts 17-20)",
                "Repeat the 20-count pattern facing the new wall"
            ],
            followSteps: [],
            youtubeID: nil
        ),
        Dance(
            id: "cowgirl-twist",
            name: "Cowgirl Twist",
            category: .lineDance,
            summary: "90s line dance to Vince Gill's 1994 country chart hit. Twisting heels and hip moves.",
            description: "Line dance choreographed to Vince Gill's 1994 country hit. Features twisting heels, hip work, and grapevines in a fun, playful pattern.",
            leaderVideoURL: nil, followerVideoURL: nil,
            bpm: 120, isPartnerDance: false, difficulty: 3,
            recommendedSongs: ["What the Cowgirls Do — Vince Gill"],
            leadSteps: [
                "Twist both heels right, left, right, left (counts 1-4)",
                "Grapevine right with a scuff: step right, cross left behind, step right, scuff left (counts 5-8)",
                "Grapevine left with a scuff: step left, cross right behind, step left, scuff right (counts 9-12)",
                "Hip rolls: roll your hips right, then left (counts 13-16)",
                "Walk forward: step right, left, right, hitch left (counts 17-20)",
                "Walk backward with a quarter turn: step back left, right, left with a quarter turn left, touch right (counts 21-24)",
                "Repeat the 24-count pattern facing the new wall"
            ],
            followSteps: [],
            youtubeID: nil
        ),
        Dance(
            id: "black-velvet",
            name: "Black Velvet",
            category: .lineDance,
            summary: "Smooth line dance with touches, kick-ball-changes, and a jazz box.",
            description: "Smooth line dance originally done to Alannah Myles' hit. Simple five-step pattern with touches, kick-ball-changes, and a jazz box.",
            leaderVideoURL: nil, followerVideoURL: nil,
            bpm: 100, isPartnerDance: false, difficulty: 4,
            recommendedSongs: ["Black Velvet — Alannah Myles"],
            leadSteps: [
                "Touch your right toe forward, step right beside left (counts 1-2)",
                "Touch your left toe forward, step left beside right (counts 3-4)",
                "Kick-ball-change with a half turn right: kick right, step on ball of right, step down left with a half turn right (counts 5-6)",
                "Walk forward: step right, left (counts 7-8)",
                "Kick-ball-change: kick right, step on ball of right, step left (counts 9-10)",
                "Shuffle forward: right-left-right (counts 11-and-12)",
                "Shuffle forward: left-right-left (counts 13-and-14)",
                "Jazz box: cross right over left, step back left, step right to side, close left beside right (counts 15-18)",
                "Repeat the pattern facing the new wall"
            ],
            followSteps: [],
            youtubeID: nil
        ),
        Dance(
            id: "swamp-thing",
            name: "Swamp Thing",
            category: .lineDance,
            summary: "Cajun-flavored line dance with hip sways and quick turns.",
            description: "Fun line dance with Cajun-influenced moves. Features hip sways, grapevines, and quick turns.",
            leaderVideoURL: nil, followerVideoURL: nil,
            bpm: 120, isPartnerDance: false, difficulty: 4,
            recommendedSongs: ["Swamp Thing — The Grid"],
            leadSteps: [
                "Hip sways: shift your weight and sway hips right, left, right, left (counts 1-4)",
                "Grapevine right with a stomp: step right, cross left behind, step right, stomp left beside right (counts 5-8)",
                "Grapevine left with a stomp: step left, cross right behind, step left, stomp right beside left (counts 9-12)",
                "Rock step: step forward right, rock back on left, step back right, rock forward on left (counts 13-16)",
                "Shuffle forward: right-left-right, then left-right-left (counts 17-20)",
                "Shuffle backward: right-left-right, then left-right-left (counts 21-24)",
                "Quarter turn left with a stomp and clap to finish (counts 25-26)",
                "Repeat facing the new wall"
            ],
            followSteps: [],
            youtubeID: nil
        ),
        Dance(
            id: "hoedown-throwdown",
            name: "Hoedown Throwdown",
            category: .lineDance,
            summary: "Zig-zag, shuffle, and spin to Miley Cyrus's Hannah Montana hit.",
            description: "Line dance to Miley Cyrus's 'Hoedown Throwdown' from the 2009 Hannah Montana movie. Features zig-zagging across the floor, diagonal shuffles, a one-footed 180 twist, and three claps.",
            leaderVideoURL: nil, followerVideoURL: nil,
            bpm: 125, isPartnerDance: false, difficulty: 4,
            recommendedSongs: ["Hoedown Throwdown — Miley Cyrus"],
            leadSteps: [
                "Hitch right knee, then hitch left knee while walking diagonally right (counts 1-4)",
                "Zig-zag across the floor diagonally, stepping on each beat (counts 5-8)",
                "Diagonal shuffle forward: right-left-right, then left-right-left (counts 9-12)",
                "Place hands on hips, then execute a one-footed 180° twist on your left foot (counts 13-14)",
                "Step right-left, slide, three claps (counts 15-18)",
                "Boom-boom-clap sequence with hip pops (counts 19-22)",
                "Zig-zag again to repeat the pattern — the song lyrics call out most of the moves"
            ],
            followSteps: [],
            youtubeID: nil
        ),
        Dance(
            id: "tush-push",
            name: "Tush Push",
            category: .lineDance,
            summary: "40-count, 4-wall line dance with hip bumps and cha-cha steps. Jim Ferrazzano's 80s classic.",
            description: "Choreographed by Jim Ferrazzano in the 1980s. 40-count, 4-wall dance featuring hip bumps, grapevines, and cha-cha steps. One of the most widespread line dances.",
            leaderVideoURL: nil, followerVideoURL: nil,
            bpm: 120, isPartnerDance: false, difficulty: 4,
            recommendedSongs: ["Chattahoochee — Alan Jackson", "Boot Scootin' Boogie — Brooks & Dunn"],
            leadSteps: [
                "Right heel taps: touch right heel forward, touch right beside left, touch right heel forward twice, step right beside left (counts 1-4)",
                "Left heel taps: touch left heel forward, touch left beside right, touch left heel forward twice, step left beside right (counts 5-8)",
                "Heel switches with clap: touch right heel forward, step right home, touch left heel forward, step left home, touch right heel forward, clap (counts 9-12)",
                "Bump your hips forward twice, then back twice — end weight on left (counts 13-16)",
                "Bump hips right, left, right, left — end weight on left (counts 17-20)",
                "Right forward shuffle and rock: chassé forward right-left-right, rock forward on left, recover back on right (counts 21-24)",
                "Left back shuffle and rock: chassé back left-right-left, rock back on right, recover forward on left (counts 25-28)",
                "Right forward shuffle and half turn right: chassé forward right-left-right, step left forward, pivot half right (counts 29-32)",
                "Left forward shuffle and half turn left: chassé forward left-right-left, step right forward, pivot half left (counts 33-36)",
                "Step right forward with a quarter turn left, stomp right together with a clap (counts 37-40)"
            ],
            followSteps: [],
            youtubeID: nil
        ),
        Dance(
            id: "bring-on-the-good-times",
            name: "Bring on the Good Times",
            category: .lineDance,
            summary: "32-count mix of claps, slides, and struts. Beginner-to-intermediate favorite.",
            description: "32-count line dance with a mix of claps, slides, and struts. A great transitional dance as you move from beginner to intermediate level.",
            leaderVideoURL: nil, followerVideoURL: nil,
            bpm: 120, isPartnerDance: false, difficulty: 4,
            recommendedSongs: ["Bring on the Good Times — Lisa McHugh"],
            leadSteps: [
                "Heel struts forward: touch right heel forward, step right down; touch left heel forward, step left down (counts 1-4)",
                "Two more heel struts forward with claps on each down-step (counts 5-8)",
                "Slide to the right: step right to side, slide left to meet right, step right to side, touch left (counts 9-12)",
                "Slide to the left: step left to side, slide right to meet left, step left to side, touch right (counts 13-16)",
                "Grapevine right with a quarter turn left: step right, cross left behind, step right with a quarter turn left, scuff left (counts 17-20)",
                "Grapevine left with a half turn: step left, cross right behind, pivot half left on left foot, scuff right (counts 21-24)",
                "Rock step forward right, recover back left (counts 25-26)",
                "Triple step backward: right-left-right (counts 27-and-28)",
                "Quarter turn left, step forward, scuff, and repeat facing new wall (counts 29-32)"
            ],
            followSteps: [],
            youtubeID: nil
        ),
        Dance(
            id: "tango-with-the-sheriff",
            name: "Tango With The Sheriff",
            category: .lineDance,
            summary: "48-count line dance with smooth tango-inspired slides and box steps.",
            description: "48-count, 4-wall line dance choreographed by Adrian Churm. Smooth tango-inspired slides, box steps, and stomps.",
            leaderVideoURL: nil, followerVideoURL: nil,
            bpm: 100, isPartnerDance: false, difficulty: 5,
            recommendedSongs: ["Cha Tango — Dave Sheriff"],
            leadSteps: [
                "Step left to the side, slide right to meet left, step left to the side, touch right (counts 1-4)",
                "Step right to the side, slide left to meet right, step right to the side, touch left (counts 5-8)",
                "Tango box: step forward left, step right beside left, step left to the side, close right (counts 9-12)",
                "Tango box backward: step back right, step left beside right, step right to the side, close left (counts 13-16)",
                "Stomp right, stomp left, stomp right, hold (counts 17-20)",
                "Stomp left, stomp right, stomp left, hold (counts 21-24)",
                "Tango walks forward: step right, step left, step right, touch left (counts 25-28)",
                "Tango walks backward: step left, step right, step left, touch right (counts 29-32)",
                "Step right forward, pivot half turn left (counts 33-34)",
                "Step right forward, pivot half turn left (counts 35-36)",
                "Grapevine right with a quarter turn and stomp (counts 37-40)",
                "Final 8 counts: rock steps and pivot to face new wall (counts 41-48)"
            ],
            followSteps: [],
            youtubeID: nil
        ),
        Dance(
            id: "slappin-leather",
            name: "Slappin' Leather",
            category: .lineDance,
            summary: "Fast honky-tonk favorite with heel slaps, kicks, and a pivot turn.",
            description: "Fast-paced classic country line dance with heel slaps, kicks, scuffs, and a pivot turn. A honky-tonk favorite.",
            leaderVideoURL: nil, followerVideoURL: nil,
            bpm: 140, isPartnerDance: false, difficulty: 5,
            recommendedSongs: ["T-R-O-U-B-L-E — Travis Tritt"],
            leadSteps: [
                "Swivel both heels apart, bring heels together (counts 1-2)",
                "Swivel both heels apart, bring heels together (counts 3-4)",
                "Touch right heel diagonally forward, step right beside left (counts 5-6)",
                "Touch left heel diagonally forward, step left beside right (counts 7-8)",
                "Touch right heel diagonally forward, step right beside left (counts 9-10)",
                "Touch left heel diagonally forward, step left beside right (counts 11-12)",
                "Touch right heel forward, touch right heel forward (counts 13-14)",
                "Touch right toe back, touch right toe back (counts 15-16)",
                "Touch right heel forward, touch right to side (counts 17-18)",
                "Flick right foot back and slap your right heel with your left hand (count 19)",
                "Repeat: touch right heel forward, flick right back and slap (counts 20-21)",
                "Touch right to side, hook right over left and slap with left hand, flick right back and slap (counts 22-24)",
                "Grapevine right: step right, cross left behind, step right, hop (counts 25-28)",
                "Grapevine left: step left, cross right behind, step left, hop (counts 29-32)",
                "Walk back: step back right, step back left, step back right, hop with heel up (counts 33-36)",
                "Walk forward: step left forward, step right forward, step left forward, stomp right beside left (counts 37-40)"
            ],
            followSteps: [],
            youtubeID: nil
        ),
        Dance(
            id: "indian-outlaw",
            name: "Indian Outlaw",
            category: .lineDance,
            summary: "Rowdy 1994 Tim McGraw line dance with pounding rhythm and big footwork.",
            description: "Line dance to Tim McGraw's 1994 breakout hit. Pounding rhythm, stomps, kicks, and energetic footwork that fills a dance floor.",
            leaderVideoURL: nil, followerVideoURL: nil,
            bpm: 135, isPartnerDance: false, difficulty: 5,
            recommendedSongs: ["Indian Outlaw — Tim McGraw"],
            leadSteps: [
                "Stomp right, stomp right (counts 1-2)",
                "Clap twice (counts 3-4)",
                "Grapevine right: step right, cross left behind, step right, kick left across right (counts 5-8)",
                "Grapevine left: step left, cross right behind, step left, kick right across left (counts 9-12)",
                "Jumping quarter turn right: jump apart landing with right turned out, jump together (counts 13-14)",
                "Jumping quarter turn right: jump apart, jump together (counts 15-16)",
                "Walk forward: step right, left, right, hitch left knee (counts 17-20)",
                "Walk backward: step back left, right, left, stomp right together (counts 21-24)",
                "Quarter turn left with hip pops and stomps to finish (counts 25-32)"
            ],
            followSteps: [],
            youtubeID: nil
        ),
        Dance(
            id: "footloose",
            name: "Footloose",
            category: .lineDance,
            summary: "High-energy line dance to the Kenny Loggins classic. Kicks, spins, and shuffles.",
            description: "High-energy line dance to Kenny Loggins' 'Footloose' (also redone by Blake Shelton). Fast kicks, grapevine spins, and shuffles.",
            leaderVideoURL: nil, followerVideoURL: nil,
            bpm: 172, isPartnerDance: false, difficulty: 6,
            recommendedSongs: ["Footloose — Kenny Loggins", "Footloose — Blake Shelton"],
            leadSteps: [
                "Kick right heel forward, touch right beside left (counts 1-2)",
                "Kick left heel forward, touch left beside right (counts 3-4)",
                "Step right forward at an angle, touch left together, step left back at an angle, touch right together (counts 5-8)",
                "Step right back at an angle, touch left together, step left forward at an angle, touch right together (counts 9-12)",
                "Grapevine right with a full turn right: step right, pivot full turn right, step right, touch left (counts 13-16)",
                "Grapevine left with a full turn left: step left, pivot full turn left, step left, touch right (counts 17-20)",
                "Shuffle forward: right-left-right (counts 21-and-22)",
                "Shuffle forward: left-right-left (counts 23-and-24)",
                "Shuffle backward: right-left-right (counts 25-and-26)",
                "Shuffle backward: left-right-left (counts 27-and-28)",
                "Step right forward, pivot a quarter turn left, stomp right together, clap (counts 29-32)"
            ],
            followSteps: [],
            youtubeID: nil
        ),
        Dance(
            id: "good-time",
            name: "Good Time",
            category: .lineDance,
            summary: "Crowd-favorite line dance to Alan Jackson's 2008 summer anthem.",
            description: "Line dance to Alan Jackson's 'Good Time'. Simple pattern of struts, grapevines, and hip pops that's perfect for a summer backyard party.",
            leaderVideoURL: nil, followerVideoURL: nil,
            bpm: 115, isPartnerDance: false, difficulty: 3,
            recommendedSongs: ["Good Time — Alan Jackson"],
            leadSteps: [
                "Heel struts forward: touch right heel forward, step right down; touch left heel forward, step left down (counts 1-4)",
                "Heel struts continue: touch right heel, step down; touch left heel, step down (counts 5-8)",
                "Grapevine right with a clap: step right, cross left behind, step right, clap (counts 9-12)",
                "Grapevine left with a clap: step left, cross right behind, step left, clap (counts 13-16)",
                "Hip pops: bump hips right twice, left twice (counts 17-20)",
                "Hip pops: bump hips right, left, right, left (counts 21-24)",
                "Walk forward: step right, left, right, touch left (counts 25-28)",
                "Walk backward with a quarter turn left: step back left, right, left with a quarter turn, touch right (counts 29-32)",
                "Repeat the 32-count pattern facing the new wall"
            ],
            followSteps: [],
            youtubeID: nil
        ),

        // MARK: - Schatzi (historical Texas two-step)

        Dance(
            id: "schatzi",
            name: "Schatzi",
            category: .twoStep,
            summary: "One of the two 'original' Texas two-steps — a bouncy, playful sweetheart-position dance taught at the Broken Spoke.",
            description: "Schatzi (German for 'sweetheart') is a historical Texas two-step danced in sweetheart/promenade position with both partners facing the line of dance. Unlike the smooth Classic Texas Two-Step, the Schatzi has a bouncy, playful character with vines, scuffs, underarm turns, and forward-back walks. Teri White explicitly teaches the Schatzi at the Broken Spoke in Austin as part of Texas dance-hall tradition.",
            leaderVideoURL: nil, followerVideoURL: nil,
            bpm: 110, isPartnerDance: true, difficulty: 4,
            recommendedSongs: ["Waltz Across Texas — Ernest Tubb", "Four Walls — Jim Reeves"],
            leadSteps: [
                "Set up in sweetheart position — follow on your right, both facing the line of dance, hands joined in front at waist level",
                "Step forward with your left foot, scuff your right heel forward past your left (counts 1-2)",
                "Step forward with your right foot, scuff your left heel forward past your right (counts 3-4)",
                "Grapevine left: step left to the side, cross your right behind left, step left, touch right beside left (counts 5-8)",
                "Grapevine right: step right to the side, cross your left behind right, step right, touch left beside right (counts 9-12)",
                "Walk forward four steps: left, right, left, right (counts 13-16)",
                "Raise your left hand and lead the follow through an underarm turn to her right as you continue forward",
                "Return to sweetheart position and repeat the pattern"
            ],
            followSteps: [
                "Mirror the lead's footwork in sweetheart position — step forward left, scuff right, step forward right, scuff left",
                "Match the grapevines to either side using the same footwork as the lead",
                "Walk forward four steps matching the lead",
                "On the underarm turn: rotate a full turn to your right under the lead's raised left hand, then settle back into sweetheart position"
            ],
            youtubeID: nil
        ),

        // MARK: - Shuffle Two-Step (Texas Shuffle)

        Dance(
            id: "shuffle-two-step",
            name: "Shuffle Two-Step",
            category: .twoStep,
            summary: "Bouncy, diagonal-moving Texas Two-Step variant popular on crowded honky-tonk floors.",
            description: "Also called the 'Texas Shuffle' or 'Fort Worth Shuffle'. A relaxed variant of the Texas Two-Step where the quick steps almost come together in a bouncy, diagonal shuffle. It's the most popular style on the crowded Broken Spoke floor because it travels less than the classic two-step — perfect for packed dance halls.",
            leaderVideoURL: nil, followerVideoURL: nil,
            bpm: 128, isPartnerDance: true, difficulty: 2,
            recommendedSongs: ["All My Ex's Live in Texas — George Strait", "Friends in Low Places — Garth Brooks"],
            leadSteps: [
                "Set up in closed position with the follow facing you",
                "Shuffle diagonally forward-left: quick step left, quick close right (counts 1-2)",
                "Slow step forward with your left foot, sliding slightly diagonally (count 3)",
                "Slow step forward with your right foot, continuing the diagonal drift (count 4)",
                "Repeat the pattern, letting the quicks come together in a relaxed bounce rather than a full step",
                "Keep the posture low and relaxed — the shuffle should feel lazy and on-the-beat rather than stiff"
            ],
            followSteps: [
                "Set up in closed position facing the lead",
                "Shuffle diagonally back-right: quick step back right, quick close left (counts 1-2)",
                "Slow step back with your right foot (count 3)",
                "Slow step back with your left foot (count 4)",
                "Stay relaxed and follow the lead's diagonal drift — the shuffle's character is its bounce, not its travel distance"
            ],
            youtubeID: nil
        ),

        // MARK: - Chicken Dance

        Dance(
            id: "chicken-dance",
            name: "Chicken Dance",
            category: .lineDance,
            summary: "Novelty party line dance with flapping arms and playful beaks — the wedding and Oktoberfest classic.",
            description: "Originating in Switzerland in the 1950s and popularized worldwide, the Chicken Dance is a 16-count novelty dance performed to the 'Birdie Song'. Silly, infectious, and perfect for family events — a guaranteed crowd-pleaser at weddings, birthdays, and Oktoberfest.",
            leaderVideoURL: nil, followerVideoURL: nil,
            bpm: 110, isPartnerDance: false, difficulty: 1,
            recommendedSongs: ["The Chicken Dance — Werner Thomas", "Dance Little Bird — Bob Kames"],
            leadSteps: [
                "Form 'beaks' with your hands: open and close your fingers against your thumbs four times at shoulder level (counts 1-4)",
                "Flap your arms like chicken wings — bend elbows, flap four times (counts 5-8)",
                "Wiggle your hips and tail-feather shimmy down four counts (counts 9-12)",
                "Clap your hands four times (counts 13-16)",
                "Break: hook arms with a neighbor and skip in a circle for 8 counts, or polka around the floor",
                "Return to place and repeat the full 16-count sequence — the song speeds up each round"
            ],
            followSteps: [],
            youtubeID: nil
        ),

        // MARK: - Y.M.C.A.

        Dance(
            id: "ymca",
            name: "Y.M.C.A.",
            category: .lineDance,
            summary: "Disco-era party classic where everyone spells out Y-M-C-A with their arms during the chorus.",
            description: "The Village People's 1978 hit remains one of the most-played party dances in history. While the verses feature optional line-dance footwork, the core of the dance is spelling Y-M-C-A overhead with your arms during each chorus — universally recognized and danced at weddings, ballgames, and parties everywhere.",
            leaderVideoURL: nil, followerVideoURL: nil,
            bpm: 127, isPartnerDance: false, difficulty: 1,
            recommendedSongs: ["Y.M.C.A. — Village People"],
            leadSteps: [
                "During the verses: march in place, clap to the beat, or do simple side-to-side steps with your line",
                "Optional verse footwork: grapevine right (step, cross, step, touch), then grapevine left (counts 1-8)",
                "When the chorus hits, spell 'YMCA' overhead:",
                "Y — raise both arms up and out in a wide V shape (counts 1-2)",
                "M — bring hands down with fingertips touching on top of your head, elbows out (counts 3-4)",
                "C — swing both arms out to your left side, curved like a C (counts 5-6)",
                "A — raise both arms straight up, hands meeting in a point above your head (counts 7-8)",
                "Repeat the Y-M-C-A spelling on every chorus — this is the dance"
            ],
            followSteps: [],
            youtubeID: nil
        ),

        // MARK: - A Bar Song (Tipsy)

        Dance(
            id: "a-bar-song-tipsy",
            name: "A Bar Song (Tipsy)",
            category: .lineDance,
            summary: "The newest massive country line dance — 2024's Shaboozey hit brought this 32-count beginner dance to every honky tonk.",
            description: "Choreographed by Ben Murphy in 2024 to Shaboozey's breakout crossover hit 'A Bar Song (Tipsy)'. A 32-count, 4-wall beginner dance with a playful rumba box, grapevines, heel touches, and hip bumps — one of the most popular new additions to the line dance scene.",
            leaderVideoURL: nil, followerVideoURL: nil,
            bpm: 81, isPartnerDance: false, difficulty: 2,
            recommendedSongs: ["A Bar Song (Tipsy) — Shaboozey"],
            leadSteps: [
                "Rumba box with tap — step right to the side, step left beside right, step right forward, tap left beside right (counts 1-4)",
                "Step left to the side, step right beside left, step left backward, tap right beside left (counts 5-8)",
                "Step-touch right, step-touch left: step right to the side, tap left beside right; step left to the side, tap right beside left (counts 9-12)",
                "Grapevine right: step right to the side, cross left behind right, step right to the side, tap left beside right (counts 13-16)",
                "Step-touch left, step-touch right: step left to the side, tap right beside left; step right to the side, tap left beside right (counts 17-20)",
                "Grapevine left with quarter turn: step left to the side, cross right behind left, step left forward with a quarter turn left, scuff right beside left (counts 21-24)",
                "Double heel touches: touch right heel forward diagonal, step right beside left; touch left heel forward diagonal, step left beside right (counts 25-28)",
                "Jump apart and bump hips: jump feet apart, bump hips right, left, right — end with weight settled (counts 29-32)",
                "Repeat the 32-count pattern facing the new wall"
            ],
            followSteps: [],
            youtubeID: nil
        ),

        // MARK: - Country Girl (Shake It For Me)

        Dance(
            id: "country-girl-shake",
            name: "Country Girl (Shake It For Me)",
            category: .lineDance,
            summary: "High-energy 32-count line dance to Luke Bryan's party anthem — shakes, stomps, and struts.",
            description: "Popular line dance to Luke Bryan's 'Country Girl (Shake It For Me)'. Features hip shakes, stomps, grapevines, and a quarter-turn pattern that lets the whole floor face each wall over four rotations. Beginner-friendly but genuinely fun at full tempo.",
            leaderVideoURL: nil, followerVideoURL: nil,
            bpm: 124, isPartnerDance: false, difficulty: 3,
            recommendedSongs: ["Country Girl (Shake It For Me) — Luke Bryan"],
            leadSteps: [
                "Heel struts forward: touch right heel forward, step right down; touch left heel forward, step left down (counts 1-4)",
                "Heel struts continue: right heel, step down; left heel, step down (counts 5-8)",
                "Hip shakes right: bump hips right, right, left, left (counts 9-12)",
                "Hip shakes left: bump hips left, left, right, right — end weight on right (counts 13-16)",
                "Grapevine right: step right to side, cross left behind right, step right, scuff left (counts 17-20)",
                "Grapevine left with a quarter turn: step left to side, cross right behind left, step left with quarter turn left, scuff right (counts 21-24)",
                "Walk forward: step right, left, right, stomp left beside right (counts 25-28)",
                "Walk backward: step back left, right, left, stomp right beside left (counts 29-32)",
                "Repeat the 32-count pattern facing the new wall"
            ],
            followSteps: [],
            youtubeID: nil
        ),

        // MARK: - Blurred Lines

        Dance(
            id: "blurred-lines",
            name: "Blurred Lines",
            category: .lineDance,
            summary: "32-count pop-country crossover line dance featuring hip rolls, turns, and a modern club feel.",
            description: "Line dance choreographed to Robin Thicke's 2013 hit 'Blurred Lines'. A 32-count, 4-wall intermediate dance with hip rolls, shuffles, and quarter turns that brought a modern pop-club energy to country dance halls during the early 2010s.",
            leaderVideoURL: nil, followerVideoURL: nil,
            bpm: 120, isPartnerDance: false, difficulty: 4,
            recommendedSongs: ["Blurred Lines — Robin Thicke"],
            leadSteps: [
                "Side rock and cross: step right to the side, rock onto left, cross right over left (counts 1-and-2)",
                "Side rock and cross: step left to the side, rock onto right, cross left over right (counts 3-and-4)",
                "Hip roll right: roll your hips in a circle to the right over two counts (counts 5-6)",
                "Hip roll left: roll your hips in a circle to the left over two counts (counts 7-8)",
                "Shuffle forward: right-left-right (counts 9-and-10)",
                "Step forward left, pivot a half turn right, shift weight onto right (counts 11-12)",
                "Shuffle forward: left-right-left (counts 13-and-14)",
                "Step forward right, pivot a half turn left, shift weight onto left (counts 15-16)",
                "Step right to the side, slide left to meet it, step right to the side, touch left beside right (counts 17-20)",
                "Step left to the side, slide right to meet it, step left to the side, touch right beside left (counts 21-24)",
                "Jazz box with a quarter turn right: cross right over left, step back left, step right to the side with a quarter turn right, step forward left (counts 25-28)",
                "Hip bumps: bump hips right, left, right, left (counts 29-32) — repeat facing the new wall"
            ],
            followSteps: [],
            youtubeID: nil
        ),
    ]
}
