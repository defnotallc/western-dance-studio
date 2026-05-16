import Foundation

struct DanceTerm: Identifiable, Hashable, Codable {
    var id: String { term }
    let term: String
    let definition: String
}

extension DanceTerm {
    static let allTerms: [DanceTerm] = [

        // MARK: Music & Timing — concepts used throughout app dances
        DanceTerm(term: "Beat", definition: "The basic unit of musical time — the steady pulse that dancers move to."),
        DanceTerm(term: "BPM", definition: "Beats Per Minute — the speed of the music. Used to set the metronome."),
        DanceTerm(term: "Count", definition: "How you verbally track the beats of a step, e.g. '1-2-3' for waltz or '1-and-2' for a shuffle."),
        DanceTerm(term: "Measure", definition: "A group of beats — 4 beats in 4/4 time (most country) or 3 beats in 3/4 time (waltz)."),
        DanceTerm(term: "Metronome", definition: "A device that produces a steady click at a set BPM to help you feel the exact tempo."),
        DanceTerm(term: "Quick", definition: "A step that takes one beat. Two-Step uses Quick-Quick-Slow-Slow timing."),
        DanceTerm(term: "Quick Quick Slow", definition: "The core Two-Step timing: two quick steps followed by two slow steps (counts 1-2-3-4)."),
        DanceTerm(term: "Slow", definition: "A step that takes two beats of music. Holds for one extra beat."),
        DanceTerm(term: "Syncopation", definition: "Splitting a beat into two half-beats — e.g. '1-and-2' — adding an extra step."),
        DanceTerm(term: "Tempo", definition: "The speed of the music that determines how quickly you dance."),

        // MARK: Footwork — steps referenced in dance instructions
        DanceTerm(term: "Anchor Step", definition: "The triple step that ends each West Coast Swing pattern to re-establish connection."),
        DanceTerm(term: "Ball Change", definition: "Shift weight onto the ball of one foot, then back. Part of 'Kick Ball Change'."),
        DanceTerm(term: "Box Step", definition: "Four steps forming a square: forward, side, close, back, side, close. Used in some line dances."),
        DanceTerm(term: "Brush", definition: "Using the ball of the foot to brush the floor as the foot swings forward or back."),
        DanceTerm(term: "Chasse", definition: "Syncopated side step: step, close, step."),
        DanceTerm(term: "Cross Step", definition: "A step where one foot crosses in front of or behind the other. Signature of Cross-Step Waltz."),
        DanceTerm(term: "Grapevine", definition: "Traveling side step: step, behind, step, touch. Used in almost every line dance."),
        DanceTerm(term: "Heel", definition: "Touching the heel to the floor with no weight — a common line-dance accent."),
        DanceTerm(term: "Heel Strut", definition: "Step heel first, then roll onto the ball of the foot. Classic country styling."),
        DanceTerm(term: "Hip Bump", definition: "Pushing your hip out to one side on the beat. Signature move of the Tush Push."),
        DanceTerm(term: "Hitch", definition: "Lifting one knee up to hip level. Used in Cowboy Boogie."),
        DanceTerm(term: "Hop", definition: "Jumping off and landing on the same foot. Used in Schottische and Copperhead Road."),
        DanceTerm(term: "Jazz Box", definition: "Four-count square: cross over, step back, step side, step together. Used in Black Velvet and others."),
        DanceTerm(term: "Kick", definition: "Extending the leg forward, back, or to the side with a sharp motion."),
        DanceTerm(term: "Kick Ball Change", definition: "Kick forward, step on ball of foot, change weight to the other foot."),
        DanceTerm(term: "Pivot", definition: "A turn on the ball of one foot without lifting it."),
        DanceTerm(term: "Pivot Turn", definition: "A quarter or half turn executed by pivoting on both feet. Used to change walls in line dances."),
        DanceTerm(term: "Rock Step", definition: "Step onto one foot, then transfer weight back to the other. Foundation of Swing."),
        DanceTerm(term: "Scuff", definition: "Brushing the heel of one foot along the floor as it swings forward."),
        DanceTerm(term: "Shuffle", definition: "A triple step counted '1-and-2'. The 'Shuffle' nickname comes from this."),
        DanceTerm(term: "Stomp", definition: "Bringing the foot down forcefully with weight transfer. Signature of Canadian Stomp."),
        DanceTerm(term: "Touch", definition: "Placing the ball or toe of one foot on the floor with no weight."),
        DanceTerm(term: "Triple Step", definition: "Three small steps taken over two beats, counted '1-and-2'. Foundation of Triple Two-Step and East Coast Swing."),

        // MARK: Partner Dance — terms used in Two-Step, Swing, and Waltz
        DanceTerm(term: "Closed Position", definition: "Standard partner hold with lead's right hand on follow's back and joined hands to the side."),
        DanceTerm(term: "Connection", definition: "The gentle physical tension between partners that lets the lead signal moves through the frame."),
        DanceTerm(term: "Cross Body Lead", definition: "The lead moves the follow from one side to the other, passing him as she walks."),
        DanceTerm(term: "Dip", definition: "The lead lowers the follow's upper body backward in a controlled bend."),
        DanceTerm(term: "Follow", definition: "The partner who responds to the lead's signals — traditionally the lady."),
        DanceTerm(term: "Frame", definition: "The arm and hand position in partner dancing that creates connection between lead and follow."),
        DanceTerm(term: "Hammerlock", definition: "A position where one of the follow's arms is behind her back, held by the lead. Common in Nightclub Two-Step."),
        DanceTerm(term: "Inside Turn", definition: "A turn where the follow rotates to her left (toward the lead's body)."),
        DanceTerm(term: "Lead", definition: "The partner who initiates and directs movement — traditionally the gentleman."),
        DanceTerm(term: "Line of Dance", definition: "The counterclockwise direction couples travel around the dance floor. Abbreviated LOD."),
        DanceTerm(term: "Outside Turn", definition: "A turn where the follow rotates to her right (away from the lead's body)."),
        DanceTerm(term: "Promenade Position", definition: "Partners side-by-side with hands joined in front, traveling forward together."),
        DanceTerm(term: "Shadow Position", definition: "Follow stands in front of the lead, both facing the same direction. Core of Shadow Two-Step."),
        DanceTerm(term: "Slot", definition: "The linear lane the follow travels in during West Coast Swing."),
        DanceTerm(term: "Sweetheart Position", definition: "Side-by-side hold with the lead's right arm over the follow's right shoulder. Used in Sweetheart Schottische."),
        DanceTerm(term: "Underarm Turn", definition: "The lead raises an arm and the follow rotates underneath it."),
        DanceTerm(term: "Varsouvienne", definition: "Another name for Sweetheart Position — classic western partner hold."),
        DanceTerm(term: "Wrap", definition: "A move ending with the follow wrapped in front of the lead, arms crossed. A Progressive Two-Step signature."),

        // MARK: Line Dance Structure
        DanceTerm(term: "2-Wall Dance", definition: "A line dance that progresses through two opposite walls (front and back)."),
        DanceTerm(term: "4-Wall Dance", definition: "A line dance that rotates through all four walls. Most dances in this app are 4-wall."),
        DanceTerm(term: "Choreographer", definition: "The person who created the sequence of steps that make up a line dance."),
        DanceTerm(term: "Step Sheet", definition: "A written description of every step in a line dance, broken down count-by-count."),
        DanceTerm(term: "Wall", definition: "A direction you face during a line dance. Dances rotate through multiple walls."),

        // MARK: Dance Styles present in the app
        DanceTerm(term: "Cha-Cha", definition: "Partner dance with a triple-step on beats 4-and-1. In country: Traveling Cha-Cha or Cowboy Cha-Cha."),
        DanceTerm(term: "Clogging", definition: "Appalachian step dance with percussive heel-and-toe footwork, usually to bluegrass."),
        DanceTerm(term: "Contra Dance", definition: "Traditional folk dance where couples form two long lines and progress down the line to new partners."),
        DanceTerm(term: "East Coast Swing", definition: "6-count swing with two triple-steps and a rock step. Popular at country bars."),
        DanceTerm(term: "Line Dance", definition: "A solo choreographed dance performed in lines or rows without a partner."),
        DanceTerm(term: "Nightclub Two-Step", definition: "Slow romantic partner dance developed by Buddy Schwimmer in the 1960s. Quick-Quick-Slow timing."),
        DanceTerm(term: "Polka", definition: "Fast bouncy partner dance in 2/4 time that travels counter-clockwise around the floor."),
        DanceTerm(term: "Schottische", definition: "Partner or line dance in 4/4 time with a step-step-step-hop pattern."),
        DanceTerm(term: "Shuffle Dance", definition: "Another name for Triple Two-Step — the Fort Worth shuffle style."),
        DanceTerm(term: "Square Dance", definition: "Traditional folk dance with four couples in a square following a caller."),
        DanceTerm(term: "Swing", definition: "Family of partner dances with rotational, bouncy feel. Includes East Coast, West Coast, and Jitterbug."),
        DanceTerm(term: "Two-Step", definition: "Classic country partner dance with gliding Quick-Quick-Slow-Slow footwork around the floor."),
        DanceTerm(term: "Waltz", definition: "Graceful partner dance in 3/4 time. Country waltz travels around the floor rather than staying in a box."),
        DanceTerm(term: "West Coast Swing", definition: "Slotted smooth swing with elastic push-pull connection."),

        // MARK: Venue & Etiquette
        DanceTerm(term: "Dance Hall", definition: "A venue built for partner and line dancing — wooden floor, live bands, no chairs on the floor."),
        DanceTerm(term: "Floor Craft", definition: "The skill of navigating the dance floor safely — avoiding collisions and maintaining the line of dance."),
        DanceTerm(term: "Honky Tonk", definition: "A bar or small club that plays country music and has a dance floor."),
        DanceTerm(term: "Kicker", definition: "Texas slang for a country-western dancer. Country dancing is sometimes called 'kicker dancing'."),
        DanceTerm(term: "Mixer", definition: "A partner dance where dancers change partners at regular intervals."),

    ].sorted { $0.term < $1.term }
}
