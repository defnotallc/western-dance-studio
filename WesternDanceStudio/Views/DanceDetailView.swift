import SwiftUI
import AVKit

struct DanceDetailView: View {
    let dance: Dance
    let store: DanceStore
    @State private var selectedPerspective: Perspective = .leader
    @State private var player = ObservablePlayer()
    @State private var stepsExpanded: Bool = true
    @State private var practiceStore = PracticeStore.shared

    // Beat-synced step highlighter — local metronome, independent of the Start Here tab's engine.
    @State private var stepEngine = MetronomeEngine()
    @State private var highlightedStepIndex: Int = 0

    enum Perspective: String, CaseIterable, Identifiable {
        case leader = "Leader"
        case follower = "Follower"
        var id: String { rawValue }
    }

    private var currentVideoURL: URL? {
        selectedPerspective == .leader ? dance.leaderVideoURL : dance.followerVideoURL
    }

    /// Partner dances: honor the selected perspective.
    /// Solo dances (line dances): always show the single lead-step list.
    private var currentSteps: [String] {
        if dance.hasPartnerPerspectives {
            return selectedPerspective == .leader ? dance.leadSteps : dance.followSteps
        }
        return dance.leadSteps
    }

    private var currentStructuredSteps: [DanceStep]? {
        guard dance.hasPartnerPerspectives else { return dance.leaderStepData }
        return selectedPerspective == .leader ? dance.leaderStepData : dance.followerStepData
    }

    private var isFavorite: Bool { store.favorites.contains(dance.id) }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                header
                videoSection
                youTubeSection
                if dance.hasPartnerPerspectives {
                    perspectivePicker
                }
                if dance.isPartnerDance {
                    stepsSection
                    structuredStepsSection
                } else if let sheet = dance.stepSheet {
                    stepSheetSection(sheet)
                } else {
                    stepsSection
                }
                tempoSection
                practiceSection
                songsSection
                if !danceErrors.isEmpty {
                    commonMistakesSection
                }
            }
            .padding(.bottom, 32)
            // Cap content width on iPad/sidebar; outer frame centers the capped block.
            .frame(maxWidth: 800)
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { loadVideo() }
        .onChange(of: selectedPerspective) { _, _ in
            stepsExpanded = true
            loadVideo()
        }
        .onDisappear {
            player.teardown()
            stepEngine.stop()
            AdManager.shared.recordDetailReturn()
        }
        .onChange(of: stepEngine.currentBeat) { _, beat in
            guard stepEngine.isPlaying,
                  let steps = currentStructuredSteps, !steps.isEmpty,
                  stepEngine.rhythmPattern.soundsOnBeat(beat) else { return }
            highlightedStepIndex = (highlightedStepIndex + 1) % steps.count
        }
        .onChange(of: selectedPerspective) { _, _ in
            stepEngine.stop()
            highlightedStepIndex = 0
        }
        .withBannerAd()
    }

    // MARK: - Sections

    private var header: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                Text(dance.name)
                    .font(WesternTheme.displayFont(size: 30))
                    .foregroundStyle(WesternTheme.primaryDark)
                    .multilineTextAlignment(.center)

                Button {
                    Haptics.selection()
                    store.toggleFavorite(dance)
                } label: {
                    Image(systemName: isFavorite ? "star.fill" : "star")
                        .font(.title2)
                        .foregroundStyle(WesternTheme.primary)
                }
                .buttonStyle(.plain)
            }

            WesternDivider()

            Text(dance.summary)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            HStack(spacing: 6) {
                Text("Difficulty")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                DifficultyStars(difficulty: dance.difficulty, size: 12)
                Text("\(dance.difficulty)/10")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if dance.isPartnerDance {
                Label("Partner Dance", systemImage: "person.2.fill")
                    .font(.caption)
                    .foregroundStyle(WesternTheme.primary)
            } else {
                Label("Line Dance (Solo)", systemImage: "figure.stand")
                    .font(.caption)
                    .foregroundStyle(WesternTheme.primary)
            }
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    private var videoSection: some View {
        if let url = currentVideoURL {
            VideoPlayer(player: player.player)
                .aspectRatio(16 / 9, contentMode: .fit)
                .frame(maxWidth: .infinity)
                .cornerRadius(16)
                .padding(.horizontal)
                .id(url)
        }
    }

    @ViewBuilder
    private var youTubeSection: some View {
        if let ytID = dance.youtubeID {
            MediaPlayerView(mediaType: .youtube(videoID: ytID))
                .frame(height: 220)
                .cornerRadius(16)
                .padding(.horizontal)
        }
    }

    private var perspectivePicker: some View {
        Picker("Perspective", selection: $selectedPerspective) {
            ForEach(Perspective.allCases) { perspective in
                Text(perspective.rawValue).tag(perspective)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }

    private var numberedStepList: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(currentSteps.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .top, spacing: 8) {
                    Text("\(index + 1).")
                        .font(.headline)
                        .foregroundStyle(.orange)
                        .frame(width: 28, alignment: .trailing)
                    Text(step)
                }
                .padding(.vertical, 2)
            }
        }
    }

    private var stepsSection: some View {
        GroupBox("Step-by-Step Instructions") {
            VStack(alignment: .leading, spacing: 14) {
                StepDiagram(steps: currentSteps)

                StepDiagramLegend()

                if currentSteps.count > 8 {
                    DisclosureGroup(isExpanded: $stepsExpanded) {
                        numberedStepList.padding(.top, 8)
                    } label: {
                        Label("\(currentSteps.count) Steps", systemImage: "list.number")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(WesternTheme.primaryDark)
                    }
                } else {
                    numberedStepList
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal)
    }

    // MARK: - Step Sheet (Phase 3 — structured line dance step sheets)

    @ViewBuilder
    private func stepSheetSection(_ sheet: LineDanceStepSheet) -> some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 16) {

                // Header badges
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        stepSheetBadge("\(sheet.totalCounts) Counts", icon: "number")
                        stepSheetBadge(sheet.wallsDisplay, icon: "square.grid.2x2")
                        stepSheetBadge(sheet.level.rawValue, icon: "chart.bar.fill")
                    }
                    if let choreo = sheet.choreographer {
                        Label(choreo, systemImage: "person.fill")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Divider()

                // Count-by-count steps
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(sheet.steps.enumerated()), id: \.element.id) { index, step in
                        HStack(alignment: .top, spacing: 12) {
                            Text(step.countRange)
                                .font(.system(.caption, design: .monospaced).weight(.semibold))
                                .foregroundStyle(WesternTheme.primary)
                                .frame(width: 46, alignment: .trailing)

                            VStack(alignment: .leading, spacing: 3) {
                                Text(step.figure)
                                    .font(.subheadline.weight(.semibold))
                                Text(step.description)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                if let note = step.note {
                                    Label(note, systemImage: "info.circle")
                                        .font(.caption)
                                        .foregroundStyle(.blue.opacity(0.85))
                                        .padding(.top, 1)
                                }
                            }
                        }
                        .padding(.vertical, 8)

                        if index < sheet.steps.count - 1 {
                            Divider().padding(.leading, 58)
                        }
                    }
                }

                // Tags
                if !sheet.tags.isEmpty {
                    Divider()
                    VStack(alignment: .leading, spacing: 6) {
                        Label("Tags", systemImage: "tag.fill")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(WesternTheme.primaryDark)
                        ForEach(sheet.tags) { tag in
                            HStack(alignment: .top, spacing: 8) {
                                Text("After \(tag.afterCount)")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(WesternTheme.primary)
                                    .frame(width: 56, alignment: .trailing)
                                Text("\(tag.addedCounts) counts: \(tag.description)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                // Restarts
                if !sheet.restarts.isEmpty {
                    Divider()
                    VStack(alignment: .leading, spacing: 6) {
                        Label("Restarts", systemImage: "arrow.counterclockwise")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(WesternTheme.primaryDark)
                        ForEach(sheet.restarts) { restart in
                            HStack(alignment: .top, spacing: 8) {
                                Text("After \(restart.afterCount)")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(WesternTheme.primary)
                                    .frame(width: 56, alignment: .trailing)
                                Text(restart.description)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } label: {
            Label("Step Sheet", systemImage: "list.number")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(WesternTheme.primaryDark)
        }
        .padding(.horizontal)
    }

    private func stepSheetBadge(_ text: String, icon: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
            Text(text)
                .font(.caption.weight(.semibold))
        }
        .foregroundStyle(WesternTheme.primaryDark)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(WesternTheme.primary.opacity(0.12), in: Capsule())
    }

    @ViewBuilder
    private var structuredStepsSection: some View {
        if let steps = currentStructuredSteps {
            GroupBox {
                VStack(spacing: 0) {
                    // Beat-player controls
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Beat Chart")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(WesternTheme.primaryDark)
                            Text(stepEngine.isPlaying
                                 ? "Step \(highlightedStepIndex + 1) of \(steps.count)"
                                 : "\(steps.count) counts · tap ▶ to follow along")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        // BPM stepper
                        HStack(spacing: 6) {
                            Button {
                                stepEngine.bpm = max(40, stepEngine.bpm - 10)
                            } label: { Image(systemName: "minus.circle").foregroundStyle(.orange) }
                            .buttonStyle(.plain)
                            Text("\(Int(stepEngine.bpm))")
                                .font(.caption.monospacedDigit())
                                .frame(width: 32)
                            Button {
                                stepEngine.bpm = min(220, stepEngine.bpm + 10)
                            } label: { Image(systemName: "plus.circle").foregroundStyle(.orange) }
                            .buttonStyle(.plain)
                        }
                        // Play / Stop
                        Button {
                            Haptics.impact(.light)
                            if stepEngine.isPlaying {
                                stepEngine.stop()
                                highlightedStepIndex = 0
                            } else {
                                stepEngine.bpm = Double(dance.bpm)
                                stepEngine.rhythmPattern = dance.suggestedPattern
                                highlightedStepIndex = 0
                                stepEngine.start()
                            }
                        } label: {
                            Image(systemName: stepEngine.isPlaying ? "stop.circle.fill" : "play.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.orange)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.bottom, 8)

                    Divider()

                    // Column headers
                    HStack(spacing: 0) {
                        Text("#").frame(width: 28, alignment: .center)
                        Text("Beat").frame(width: 44, alignment: .center)
                        Text("Foot").frame(width: 44, alignment: .center)
                        Text("Direction").frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        Text("Q/S").frame(width: 32, alignment: .center)
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 4)

                    Divider()

                    ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                        let isHighlighted = stepEngine.isPlaying && index == highlightedStepIndex
                        HStack(spacing: 0) {
                            Text("\(step.count)")
                                .frame(width: 28, alignment: .center)
                            Text(step.beat)
                                .frame(width: 44, alignment: .center)
                            Text(step.foot.display)
                                .frame(width: 44, alignment: .center)
                                .foregroundStyle(step.foot == .left ? Color.blue : Color.orange)
                            Text(step.direction.display)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            Text(step.timing.shortDisplay)
                                .frame(width: 32, alignment: .center)
                                .fontWeight(.semibold)
                                .foregroundStyle(step.timing == .quick ? WesternTheme.primaryDark : .secondary)
                        }
                        .font(.subheadline)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 4)
                        .background(
                            isHighlighted
                                ? Color.orange.opacity(0.15)
                                : Color.clear
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .animation(.easeInOut(duration: 0.1), value: isHighlighted)

                        if let note = step.note {
                            Text(note)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 4)
                                .padding(.bottom, 4)
                        }

                        if step.id != steps.last?.id {
                            Divider()
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Practice section

    private var practiceSection: some View {
        GroupBox {
            VStack(spacing: 12) {
                HStack {
                    Label("Practice Log", systemImage: "checkmark.circle.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(WesternTheme.primaryDark)
                    Spacer()
                    if practiceStore.practiceCount(for: dance.id) > 0 {
                        Text("\(practiceStore.practiceCount(for: dance.id)) session\(practiceStore.practiceCount(for: dance.id) == 1 ? "" : "s")")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                if let last = practiceStore.lastPracticed(dance.id) {
                    HStack(spacing: 6) {
                        Image(systemName: "clock")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("Last practiced \(last.formatted(.relative(presentation: .named)))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                }

                Button {
                    Haptics.impact(.medium)
                    practiceStore.logPractice(danceID: dance.id)
                } label: {
                    Label(
                        practiceStore.practicedToday(dance.id) ? "Practiced today ✓" : "Log Practice",
                        systemImage: practiceStore.practicedToday(dance.id) ? "checkmark.circle.fill" : "checkmark.circle"
                    )
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(practiceStore.practicedToday(dance.id) ? .green : .orange)
            }
        }
        .padding(.horizontal)
    }

    private var tempoSection: some View {
        GroupBox("Tempo") {
            VStack(spacing: 10) {
                HStack {
                    Image(systemName: "metronome")
                        .foregroundStyle(.orange)
                    Text("\(dance.bpm) BPM")
                        .font(.headline)
                    Spacer()
                    Text(dance.suggestedPattern.subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Button {
                    Haptics.selection()
                    PracticeRequest.shared.pendingBPM = Double(dance.bpm)
                    PracticeRequest.shared.pendingPattern = dance.suggestedPattern
                    NotificationCenter.default.post(name: .openStartHereTab, object: nil)
                } label: {
                    Label("Practice at \(dance.bpm) BPM", systemImage: "metronome.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.orange)
            }
        }
        .padding(.horizontal)
    }

    private var songsSection: some View {
        GroupBox("Recommended Songs") {
            VStack(alignment: .leading, spacing: 6) {
                ForEach(dance.recommendedSongs, id: \.self) { song in
                    HStack {
                        Image(systemName: "music.note")
                            .foregroundStyle(.orange)
                        Text(song)
                    }
                    .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Common Mistakes (Phase 5)

    private var danceErrors: [CommonError] {
        CommonError.all.filter { $0.danceIDs.contains(dance.id) }
    }

    private var commonMistakesSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                Label("Common Mistakes", systemImage: "exclamationmark.triangle.fill")
                    .font(.headline)
                    .foregroundStyle(.orange)

                ForEach(danceErrors) { error in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 5) {
                            Image(systemName: error.category.icon)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Text(error.category.rawValue)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        Text(error.title)
                            .font(.subheadline.weight(.semibold))
                        Text(error.fix)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 2)

                    if error.id != danceErrors.last?.id {
                        Divider()
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal)
    }

    // MARK: - Helpers

    private func loadVideo() {
        if let url = currentVideoURL {
            player.setup(with: url)
        }
    }
}
