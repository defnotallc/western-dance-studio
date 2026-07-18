import SwiftUI

struct BeginnerBootcampView: View {
    @Bindable var store: DanceStore
    @State private var engine = MetronomeEngine()
    @State private var iap = IAPManager.shared
    @State private var consent = ConsentManager.shared
    @State private var practiceStore = PracticeStore.shared
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

                    // MARK: Practice Streak
                    if practiceStore.totalSessions > 0 {
                        practiceStreakWidget
                            .padding(.horizontal)
                    }

                    // MARK: Learning Path (Phase 4)
                    CurriculumView(store: store)
                        .padding(.horizontal)

                    // MARK: Common Mistakes (Phase 5)
                    NavigationLink {
                        CommonErrorsView()
                    } label: {
                        GroupBox {
                            HStack(spacing: 12) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.title3)
                                    .foregroundStyle(.orange)
                                VStack(alignment: .leading, spacing: 3) {
                                    Text("Common Mistakes to Avoid")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(.primary)
                                    Text("25 mistakes beginners make — and exactly how to fix them")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal)

                    // MARK: Practice Tools
                    metronomeSection
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

            // Ad Preferences — only visible to EEA/UK/CH users (GDPR).
            // privacyOptionsRequired is false for US users, so this is a no-op there.
            if consent.privacyOptionsRequired {
                GroupBox {
                    Button {
                        Haptics.selection()
                        Task { await ConsentManager.shared.presentPrivacyOptionsForm() }
                    } label: {
                        HStack {
                            Image(systemName: "hand.raised.fill")
                                .foregroundStyle(WesternTheme.primary)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Ad Preferences")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.primary)
                                Text("Manage your advertising consent (GDPR)")
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

    // MARK: - Practice streak widget

    private var practiceStreakWidget: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 16) {
                    // Streak counter
                    VStack(spacing: 2) {
                        Text("\(practiceStore.currentStreak)")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(.orange)
                        Text(practiceStore.currentStreak == 1 ? "day streak" : "day streak")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Divider().frame(height: 44)

                    // Totals
                    VStack(alignment: .leading, spacing: 4) {
                        Label("\(practiceStore.totalSessions) total sessions", systemImage: "checkmark.circle")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Label("\(practiceStore.uniqueDancesPracticed) dance\(practiceStore.uniqueDancesPracticed == 1 ? "" : "s") practiced", systemImage: "figure.dance")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                // 14-day activity dots
                let activeDays = practiceStore.activeDays(inLast: 14)
                let calendar = Calendar.current
                HStack(spacing: 4) {
                    ForEach(0..<14, id: \.self) { daysAgo in
                        let day = calendar.date(byAdding: .day, value: -(13 - daysAgo), to: calendar.startOfDay(for: Date())) ?? Date()
                        let active = activeDays.contains(day)
                        let isToday = daysAgo == 13
                        Circle()
                            .fill(active ? Color.orange : Color.gray.opacity(0.2))
                            .frame(width: isToday ? 13 : 10, height: isToday ? 13 : 10)
                            .overlay(
                                Circle().stroke(isToday ? Color.orange : Color.clear, lineWidth: 1.5)
                            )
                    }
                    Spacer()
                    Text("14 days")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } label: {
            Label("Practice Streak", systemImage: "flame.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(WesternTheme.primaryDark)
        }
    }

    // MARK: - Metronome

    private var pendingBPM: Double? { PracticeRequest.shared.pendingBPM }
    private var pendingPattern: RhythmPattern? { PracticeRequest.shared.pendingPattern }

    private var metronomeSection: some View {
        GroupBox("Practice Metronome") {
            VStack(spacing: 16) {

                // Rhythm pattern picker
                VStack(alignment: .leading, spacing: 6) {
                    Text("Rhythm Pattern")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Picker("Pattern", selection: $engine.rhythmPattern) {
                        ForEach(RhythmPattern.allCases) { pattern in
                            Text(pattern.displayName).tag(pattern)
                        }
                    }
                    .pickerStyle(.segmented)
                    Text(engine.rhythmPattern.subtitle)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                // Beat position indicator
                if engine.rhythmPattern.length > 1 {
                    HStack(spacing: 8) {
                        ForEach(1...engine.rhythmPattern.length, id: \.self) { pos in
                            let sounds = engine.rhythmPattern.soundsOnBeat(pos)
                            let isCurrent = engine.isPlaying && engine.currentBeat == pos
                            let isAccent = engine.rhythmPattern.isAccent(pos)
                            Circle()
                                .fill(
                                    isCurrent
                                        ? (isAccent ? WesternTheme.primary : Color.orange)
                                        : (sounds ? Color.orange.opacity(0.25) : Color.gray.opacity(0.12))
                                )
                                .frame(width: isCurrent ? 16 : 12, height: isCurrent ? 16 : 12)
                                .overlay(
                                    Circle()
                                        .stroke(sounds ? Color.orange.opacity(0.6) : Color.gray.opacity(0.3), lineWidth: 1)
                                )
                                .animation(.easeInOut(duration: 0.08), value: isCurrent)
                        }
                    }
                }

                // BPM display + pulse circle
                Text("\(Int(engine.bpm)) BPM")
                    .font(.system(size: 52, weight: .bold, design: .rounded))
                    .foregroundStyle(.orange)

                ZStack {
                    Circle()
                        .stroke(lineWidth: 10)
                        .foregroundStyle(.orange.opacity(0.3))
                        .frame(width: 140, height: 140)

                    Circle()
                        .fill(
                            engine.accentPulse ? WesternTheme.primary :
                            (engine.isPlaying ? Color.orange : Color.gray)
                        )
                        .frame(width: engine.beatPulse ? 75 : 50,
                               height: engine.beatPulse ? 75 : 50)
                        .animation(.easeInOut(duration: 0.08), value: engine.beatPulse)
                        .animation(.easeInOut(duration: 0.08), value: engine.accentPulse)
                }

                Slider(value: $engine.bpm, in: 60...220, step: 1) {
                    Text("BPM")
                } minimumValueLabel: {
                    Text("60").font(.caption)
                } maximumValueLabel: {
                    Text("220").font(.caption)
                }
                .tint(.orange)

                // Count-in toggle + start button
                VStack(spacing: 10) {
                    Toggle(isOn: $engine.countInEnabled) {
                        Label("Count-In (4 beats)", systemImage: "4.square")
                            .font(.subheadline)
                    }
                    .tint(.orange)

                    Button(engine.isPlaying ? "Stop" : "Start") {
                        Haptics.impact(.medium)
                        engine.toggle()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                }

                // Presets
                VStack(alignment: .leading, spacing: 6) {
                    Text("Quick Presets")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(Dance.sampleDances.prefix(10)) { dance in
                                Button("\(dance.name) · \(dance.bpm)") {
                                    engine.bpm = Double(dance.bpm)
                                    engine.rhythmPattern = dance.suggestedPattern
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
        .onChange(of: pendingBPM) { _, bpm in
            if let bpm {
                engine.bpm = bpm
                PracticeRequest.shared.pendingBPM = nil
            }
        }
        .onChange(of: pendingPattern) { _, pattern in
            if let pattern {
                engine.rhythmPattern = pattern
                PracticeRequest.shared.pendingPattern = nil
            }
        }
    }
}
