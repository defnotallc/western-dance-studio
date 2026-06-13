import SwiftUI

struct BeginnerBootcampView: View {
    @Bindable var store: DanceStore
    @State private var engine = MetronomeEngine()
    @State private var iap = IAPManager.shared
    @State private var showingRemoveAdsSheet = false
    /// Optional callback to navigate to another tab (wired by parent)
    var onOpenGlossary: (() -> Void)? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // MARK: Welcome
                    WesternBanner {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Howdy Partner!")
                                .font(WesternTheme.displayFont(size: 34))
                                .foregroundStyle(WesternTheme.primaryDark)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("New to country dancing?")
                                Text("Start right here.")
                                Text("No experience needed.")
                            }
                            .font(WesternTheme.headlineFont(size: 15, weight: .medium))
                            .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal)

                    // MARK: Safety & Etiquette
                    safetyTeaser
                        .padding(.horizontal)

                    // MARK: Two-Step vs Line Dance
                    GroupBox("Two-Step vs. Line Dance") {
                        VStack(alignment: .leading, spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Label("Two-Step", systemImage: "person.2.fill")
                                    .font(.headline)
                                    .foregroundStyle(.orange)
                                Text("A **partner dance**. You and a partner move together around the dance floor in a counter-clockwise circle. One partner **leads**, the other **follows**. Classic rhythm is **Quick-Quick-Slow-Slow**.")
                            }

                            Divider()

                            VStack(alignment: .leading, spacing: 4) {
                                Label("Line Dance", systemImage: "figure.stand.line.dotted.figure.stand")
                                    .font(.headline)
                                    .foregroundStyle(.orange)
                                Text("A **solo dance** done in lines with a group. Everyone performs the **same choreographed steps** at the same time. No partner needed — just follow the person in front of you.")
                            }

                            Divider()

                            VStack(alignment: .leading, spacing: 4) {
                                Text("The big difference")
                                    .font(.headline)
                                Text("Two-Step = you dance **with someone**. Line Dance = you dance **next to everyone**. Most country dance halls play both throughout the night.")
                            }
                        }
                    }
                    .padding(.horizontal)

                    // MARK: Western Swing
                    GroupBox("What is Western Swing?") {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Partner dance family", systemImage: "arrow.2.circlepath")
                                .font(.headline)
                                .foregroundStyle(.orange)
                            Text("Western Swing is a family of **energetic partner dances** with a rotational, bouncy feel. Unlike the Two-Step's smooth glide around the floor, Swing stays mostly in one spot with **spins, turns, and playful connection** between partners.")
                            Text("Stylistically it's **lively and syncopated** — expect triple-steps, rock steps, and lots of pretzel-like arm patterns. The three main variations are **East Coast Swing** (6-count, triple-steps), **West Coast Swing** (slotted, smooth, elastic), and **Country Jitterbug** (simpler single-step version).")
                            Text("Swing pairs well with up-tempo honky-tonk and rockabilly songs where Two-Step would feel too slow.")
                        }
                    }
                    .padding(.horizontal)

                    // MARK: Waltzes
                    GroupBox("What are Waltzes & Schottisches?") {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Graceful, traveling partner dances", systemImage: "music.quarternote.3")
                                .font(.headline)
                                .foregroundStyle(.orange)
                            Text("The **Country Waltz** is a flowing, graceful partner dance in **3/4 time** — counted 1-2-3, 1-2-3. Unlike ballroom waltzes that stay in a box, country waltzes **travel continuously around the floor**, with long rising-and-falling steps that feel almost like floating.")
                            Text("Stylistically: **smooth, elegant, and romantic**. Close partner frame, gentle rotation, and soft knees that rise on beat 1 and settle on beats 2-3.")
                            Text("The **Schottische** is a close cousin in **4/4 time** with a distinct step-step-step-hop pattern. It's livelier than a waltz but still traveling — often done in partner hold or as a line dance variation at Texas dance halls.")
                        }
                    }
                    .padding(.horizontal)

                    // MARK: Core concepts
                    GroupBox("What is a Beat?") {
                        Text("Every song has a steady pulse called the **beat**. Think of a clock ticking or your heart beating. Dancers move on these beats.")
                    }
                    .padding(.horizontal)

                    GroupBox("How to Count Music") {
                        Text("Most country songs are counted in groups of 4 beats: 1-2-3-4, 1-2-3-4...\n\nTwo-Step timing is **Quick-Quick-Slow-Slow** — counted 1-2-3-4 where the first two are fast steps and the last two are slow (each slow holds for 2 beats).")
                    }
                    .padding(.horizontal)

                    GroupBox("What is BPM?") {
                        Text("**BPM = Beats Per Minute**, the speed of a song. Slow dances are around 90 BPM. Two-Step is typically 160–180 BPM. The metronome below helps you feel the pace.")
                    }
                    .padding(.horizontal)

                    // MARK: What is a Metronome
                    GroupBox("What is a Metronome?") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("A **metronome** is a tool that produces a steady, repeating click at a set tempo. Musicians and dancers use it to **internalize timing** before adding music — you feel the beat without the distraction of melody, lyrics, or instrumentation.")
                            Text("**How to use it for dance:** Pick the BPM of the dance you're learning (shown on each dance's detail page). Start the metronome, count along with the clicks, and practice your footwork **slowly at a lower BPM first**, then gradually work up to the real song speed.")
                            Text("Tip: if you can comfortably step on every click at 120 BPM, you're ready to try a real song at that tempo.")
                        }
                    }
                    .padding(.horizontal)

                    // MARK: Metronome (embedded)
                    metronomeSection
                        .padding(.horizontal)

                    // MARK: Floor safety quick-ref
                    floorSafetyTip
                        .padding(.horizontal)

                    // MARK: Glossary tip
                    glossaryTip
                        .padding(.horizontal)

                    // MARK: More section — Remove Ads + Gear affiliate links
                    moreSection
                        .padding(.horizontal)

                    // MARK: App version footer
                    versionFooter
                        .padding(.top, 16)

                    Spacer(minLength: 24)
                }
                .padding(.vertical)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
            .onDisappear {
                engine.stop()
            }
        }
    }

    // MARK: - Safety teaser (Phase 2.1 + 2.3 summary)

    private var safetyTeaser: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 10) {
                Label("Safety & Etiquette", systemImage: "exclamationmark.shield.fill")
                    .font(.headline)
                    .foregroundStyle(WesternTheme.primaryDark)

                Text("Before you hit the dance floor, learn the three things that matter most:")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 6) {
                    safetyBullet("Force is never correct technique — leading is communication, not pressure.")
                    safetyBullet("Asking for a dance: a \"no\" needs no explanation. Respect it and move on.")
                    safetyBullet("The floor has traffic — all couples travel counterclockwise together.")
                }

                NavigationLink {
                    SafetyEtiquetteView()
                } label: {
                    HStack(spacing: 6) {
                        Text("Read Safety & Etiquette Guide")
                        Image(systemName: "arrow.right")
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(WesternTheme.primary)
                }
                .buttonStyle(.plain)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func safetyBullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 6) {
            Image(systemName: "checkmark.circle.fill")
                .font(.caption)
                .foregroundStyle(.orange)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Floor safety tip (Phase 2.2 summary)

    private var floorSafetyTip: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 10) {
                Label("The Dance Floor Has Rules", systemImage: "arrow.counterclockwise.circle.fill")
                    .font(.headline)
                    .foregroundStyle(WesternTheme.primaryDark)

                Text("Partner dances like Two-Step travel **counterclockwise** around the floor — this is the Line of Dance. Spot dances (line dancing, Swing) stay in the center.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text("Never stop in the middle of the dance floor, never travel against the counterclockwise flow, and always look ahead for other couples.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                NavigationLink {
                    SafetyEtiquetteView()
                } label: {
                    HStack(spacing: 6) {
                        Text("Full Floor Safety Guide")
                        Image(systemName: "arrow.right")
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(WesternTheme.primary)
                }
                .buttonStyle(.plain)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Glossary tip

    private var glossaryTip: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 10) {
                Label("New to the lingo?", systemImage: "book.closed.fill")
                    .font(.headline)
                    .foregroundStyle(WesternTheme.primaryDark)

                Text("Country dancing has its own vocabulary — terms like Grapevine, Anchor Step, and Sweetheart Position. Check the Glossary anytime you hit a word you don't know.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Button {
                    Haptics.selection()
                    onOpenGlossary?()
                } label: {
                    HStack(spacing: 6) {
                        Text("Open Glossary")
                        Image(systemName: "arrow.right")
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(WesternTheme.primary)
                }
                .buttonStyle(.plain)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - More section (Remove Ads + Gear links)

    private var moreSection: some View {
        VStack(spacing: 12) {
            if !iap.isPremium {
                GroupBox {
                    Button {
                        Haptics.selection()
                        showingRemoveAdsSheet = true
                    } label: {
                        HStack {
                            Image(systemName: "sparkles")
                                .foregroundStyle(WesternTheme.primary)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Remove Ads")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.primary)
                                Text("One-time upgrade — support the app")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.plain)
                }
            }

            GearLinksSection()
        }
        .sheet(isPresented: $showingRemoveAdsSheet) {
            RemoveAdsSheet(iap: iap)
        }
    }

    // MARK: - Version footer

    private var versionFooter: some View {
        VStack(spacing: 4) {
            Text("Western Dance Studio")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Text("Version \(Self.appVersion) (Build \(Self.appBuild))")
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text("Released \(Self.releaseDate)")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
    }

    private static let appVersion: String = {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
    }()

    private static let appBuild: String = {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—"
    }()

    /// Executable creation/modification date, read once at app start.
    private static let releaseDate: String = {
        guard
            let executableURL = Bundle.main.executableURL,
            let attrs = try? FileManager.default.attributesOfItem(atPath: executableURL.path),
            let date = attrs[.creationDate] as? Date ?? attrs[.modificationDate] as? Date
        else {
            return "—"
        }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }()

    // MARK: - Metronome

    private var metronomeSection: some View {
        GroupBox("Practice Metronome") {
            VStack(spacing: 20) {
                Text("\(Int(engine.bpm)) BPM")
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundStyle(.orange)

                ZStack {
                    Circle()
                        .stroke(lineWidth: 10)
                        .foregroundStyle(.orange.opacity(0.3))
                        .frame(width: 160, height: 160)

                    Circle()
                        .fill(engine.isPlaying ? Color.orange : Color.gray)
                        .frame(width: engine.beatPulse ? 80 : 55,
                               height: engine.beatPulse ? 80 : 55)
                        .animation(.easeInOut(duration: 0.1), value: engine.beatPulse)
                }

                Slider(value: $engine.bpm, in: 80...200, step: 1) {
                    Text("BPM")
                } minimumValueLabel: {
                    Text("80").font(.caption)
                } maximumValueLabel: {
                    Text("200").font(.caption)
                }
                .tint(.orange)

                Button(engine.isPlaying ? "Stop" : "Start Metronome") {
                    Haptics.impact(.medium)
                    if engine.isPlaying {
                        engine.stop()
                    } else {
                        engine.start()
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
                .font(.headline)

                // Presets
                VStack(alignment: .leading, spacing: 6) {
                    Text("Quick Presets")
                        .font(.subheadline.bold())
                        .foregroundStyle(.secondary)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(Dance.sampleDances.prefix(8)) { dance in
                                Button("\(dance.name) · \(dance.bpm)") {
                                    engine.bpm = Double(dance.bpm)
                                }
                                .buttonStyle(.bordered)
                                .tint(.orange)
                                .font(.caption)
                            }
                        }
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }
}
