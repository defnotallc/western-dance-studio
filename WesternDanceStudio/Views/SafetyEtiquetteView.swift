import SwiftUI

// MARK: - Phase 2: Safety & Social Standards
//
// 2.1 Consent & Social Safety
// 2.2 Floor Safety / Line of Dance
// 2.3 Force-is-wrong lead/follow statement
//
// This view is the canonical home for all safety and etiquette content.
// Every statement here is primary-source verified and role-language compliant.

struct SafetyEtiquetteView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                // MARK: 2.3 — Force is Never Correct Technique (highest priority)
                forceIsWrongCallout

                // MARK: 2.1 — Social Consent
                askingForADance
                duringTheDance
                betweenSongs

                // MARK: 2.2 — Floor Safety
                lineOfDance
                floorLanes
                floorRules
            }
            .padding(.horizontal)
            .padding(.vertical, 24)
            .frame(maxWidth: 800)
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .navigationTitle("Safety & Etiquette")
        .navigationBarTitleDisplayMode(.large)
        .withBannerAd()
    }

    // MARK: - 2.3 Force Is Wrong

    private var forceIsWrongCallout: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "exclamationmark.shield.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
                Text("Force Is Never Correct Technique")
                    .font(WesternTheme.headlineFont(size: 18, weight: .bold))
                    .foregroundStyle(.white)
            }

            Text("In every partner dance in this app, the leader communicates through body movement — **never through pushing, pulling, or gripping the follower's arms**.")
                .foregroundStyle(.white.opacity(0.95))

            Text("If you feel physical pressure that is uncomfortable or that moves a body part without your consent, you have the right to stop dancing immediately. Say **\"I need to stop\"** — you owe no further explanation.")
                .foregroundStyle(.white.opacity(0.95))

            Divider().overlay(Color.white.opacity(0.3))

            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.white)
                Text("Correct leading: the leader's torso moves first; the frame transmits that movement to the follower.")
                    .foregroundStyle(.white.opacity(0.95))
            }

            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.white.opacity(0.7))
                Text("Incorrect leading: pushing the follower's back, jerking the joined hand, or physically repositioning their body with force.")
                    .foregroundStyle(.white.opacity(0.95))
            }

            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.white)
                Text("If something hurts or feels wrong during a dance — say so. A good leader will immediately stop and adjust. It is always okay to step off the floor.")
                    .foregroundStyle(.white.opacity(0.95))
            }
        }
        .font(.subheadline)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(WesternTheme.primaryDark)
        )
    }

    // MARK: - 2.1 Social Consent

    private var askingForADance: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                Label("Asking for a Dance", systemImage: "hand.wave.fill")
                    .font(.headline)
                    .foregroundStyle(WesternTheme.primaryDark)

                safetyPoint(
                    icon: "person.crop.circle.badge.plus",
                    title: "How to ask",
                    body: "Approach from the front so you are visible. Make eye contact, smile, and say something simple: **\"Would you like to dance?\"** Keep it brief and low-pressure."
                )

                safetyPoint(
                    icon: "hand.thumbsup.fill",
                    title: "If they say yes",
                    body: "Lead them to the floor, introduce yourself if you haven't already, and let them know your experience level. \"I'm still learning Two-Step — thanks for bearing with me\" sets helpful expectations."
                )

                safetyPoint(
                    icon: "hand.raised.fill",
                    title: "If they say no",
                    body: "A \"no\" is complete. Say \"No problem — enjoy your evening\" and move on. Never ask why. Never push. Never pout visibly. A decline requires no explanation from the person who declined."
                )

                safetyPoint(
                    icon: "person.crop.circle.fill.badge.minus",
                    title: "Declining a request",
                    body: "You may always decline for any reason or no reason. If you decline someone and then immediately accept someone else for the same song, the first person may feel singled out — be thoughtful about timing."
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var duringTheDance: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                Label("During the Dance", systemImage: "figure.dance")
                    .font(.headline)
                    .foregroundStyle(WesternTheme.primaryDark)

                safetyPoint(
                    icon: "bubble.left.and.bubble.right",
                    title: "Communicate",
                    body: "If something is uncomfortable — a hold that hurts, a dip you weren't ready for, a tempo that's too fast — it is always appropriate to say so. \"Could we slow that down?\" or \"I'm not comfortable with dips\" are clear and fine."
                )

                safetyPoint(
                    icon: "hand.point.up.left.fill",
                    title: "Personal space",
                    body: "Closed position does not mean body-to-body contact. A comfortable dance frame has space between the partners' bodies. If your partner adjusts to close the space and you're uncomfortable, it's okay to gently re-establish your distance."
                )

                safetyPoint(
                    icon: "exclamationmark.triangle.fill",
                    title: "You can always stop",
                    body: "You may step off the floor at any point in the song, for any reason. \"Thank you, I need a break\" is always sufficient. No partner should question, guilt, or pressure you to continue."
                )

                safetyPoint(
                    icon: "figure.stand.line.dotted.figure.stand",
                    title: "Mutual enjoyment",
                    body: "Partner dancing is cooperative. Both partners contribute their skill and care. If the experience is not working for either person, it's okay to thank your partner and end the dance early."
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var betweenSongs: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                Label("Between Songs", systemImage: "music.note")
                    .font(.headline)
                    .foregroundStyle(WesternTheme.primaryDark)

                safetyPoint(
                    icon: "heart.fill",
                    title: "Thank your partner",
                    body: "When the song ends, thank your partner — a simple \"Thank you, that was fun\" goes a long way. At most Texas dance halls, it's customary to walk your partner back toward where they were standing."
                )

                safetyPoint(
                    icon: "arrow.2.circlepath",
                    title: "Dancing with multiple people",
                    body: "At social dances, rotating partners is normal and encouraged. You are not obligated to dance every song with the same person. Variety helps everyone practice with different leads and follows."
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - 2.2 Floor Safety

    private var lineOfDance: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                Label("Line of Dance", systemImage: "arrow.counterclockwise")
                    .font(.headline)
                    .foregroundStyle(WesternTheme.primaryDark)

                Text("All progressive partner dances — Two-Step, Waltz, One-Step, Polka — travel **counterclockwise** around the perimeter of the dance floor. This is called the **Line of Dance (LOD)**.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                // Visual diagram
                lineOfDanceDiagram

                safetyPoint(
                    icon: "exclamationmark.triangle.fill",
                    title: "Why it matters",
                    body: "When everyone travels the same direction, the floor is predictable and collisions are rare. A couple moving against the line of dance is a collision hazard for every couple on the floor."
                )

                safetyPoint(
                    icon: "arrow.turn.up.left",
                    title: "Which direction is counterclockwise?",
                    body: "Stand in the room facing the center. The counterclockwise direction means you travel to your **left**. From above, dancers move the same direction as a clock's hands would move — but reversed."
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var lineOfDanceDiagram: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                .frame(height: 120)
                .background(Color.secondary.opacity(0.04), in: RoundedRectangle(cornerRadius: 12))

            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let cx = w / 2
                let cy = h / 2
                let rx = w * 0.38
                let ry = h * 0.36

                // Floor oval
                Path { path in
                    path.addEllipse(in: CGRect(x: cx - rx, y: cy - ry, width: rx * 2, height: ry * 2))
                }
                .stroke(Color.orange.opacity(0.35), lineWidth: 2)

                // Arrows at cardinal points — counterclockwise
                Group {
                    arrowAt(center: CGPoint(x: cx, y: cy - ry + 4), angle: .degrees(180), color: .orange)  // top → left
                    arrowAt(center: CGPoint(x: cx - rx + 4, y: cy), angle: .degrees(90), color: .orange)   // left → down
                    arrowAt(center: CGPoint(x: cx, y: cy + ry - 4), angle: .degrees(0), color: .orange)    // bottom → right
                    arrowAt(center: CGPoint(x: cx + rx - 4, y: cy), angle: .degrees(270), color: .orange)  // right → up
                }

                // Label
                Text("Counterclockwise ↺")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.orange)
                    .position(x: cx, y: cy)
            }
        }
        .frame(height: 120)
    }

    private func arrowAt(center: CGPoint, angle: Angle, color: Color) -> some View {
        Image(systemName: "arrowtriangle.right.fill")
            .font(.system(size: 10))
            .foregroundStyle(color)
            .rotationEffect(angle)
            .position(center)
    }

    private var floorLanes: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                Label("Floor Lanes", systemImage: "road.lanes")
                    .font(.headline)
                    .foregroundStyle(WesternTheme.primaryDark)

                safetyPoint(
                    icon: "circle.fill",
                    title: "Outer lane — progressive couples",
                    body: "The lane nearest the walls is for couples actively traveling counterclockwise in Two-Step, Waltz, or Polka. Faster-traveling couples use the outermost edge."
                )

                safetyPoint(
                    icon: "circle",
                    title: "Inner area — spot dances",
                    body: "Line dances, West Coast Swing, East Coast Swing, and any dance that stays in place belong in the center of the floor — away from the traveling lane."
                )

                safetyPoint(
                    icon: "exclamationmark.circle.fill",
                    title: "If you need to stop",
                    body: "Step off the floor entirely — don't stop in the middle of a lane. A standing couple in the traveling lane is an invisible obstacle for couples moving at full speed."
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var floorRules: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                Label("Floorcraft Basics", systemImage: "eye.fill")
                    .font(.headline)
                    .foregroundStyle(WesternTheme.primaryDark)

                Text("Floorcraft is the skill of keeping yourself and everyone around you safe while dancing. It is primarily the **leader's responsibility** in partner dances.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                floorRule(icon: "arrow.up", text: "Look ahead — not just at your partner. Anticipate gaps and hazards before they happen.")
                floorRule(icon: "arrow.down.right.and.arrow.up.left", text: "On a crowded floor, compress your patterns. No large kicks, sweeping arm moves, or dips when there's no space.")
                floorRule(icon: "person.2.slash", text: "If you bump someone, stop, apologize, and check that no one is hurt before continuing.")
                floorRule(icon: "arrow.uturn.backward", text: "Never travel backward (against the line of dance). If you need to back up momentarily for a figure, keep it very small.")
                floorRule(icon: "person.fill.questionmark", text: "When you're new to a floor, spend one song watching the traffic pattern before joining.")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Helpers

    private func safetyPoint(icon: String, title: String, body: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(WesternTheme.primary)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(LocalizedStringKey(body))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func floorRule(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.orange)
                .frame(width: 20)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}
