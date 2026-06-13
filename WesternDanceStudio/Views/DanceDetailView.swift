import SwiftUI
import AVKit

struct DanceDetailView: View {
    let dance: Dance
    let store: DanceStore
    @State private var selectedPerspective: Perspective = .leader
    @State private var player = ObservablePlayer()
    @State private var stepsExpanded: Bool = true

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
                stepsSection
                structuredStepsSection
                tempoSection
                songsSection
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
            AdManager.shared.recordDetailReturn()
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
        } else {
            VStack(spacing: 8) {
                Image(systemName: "video.slash")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
                Text("Video coming soon")
                    .foregroundStyle(.secondary)
            }
            .frame(height: 200)
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

    @ViewBuilder
    private var structuredStepsSection: some View {
        if let steps = currentStructuredSteps {
            GroupBox("Beat Chart") {
                VStack(spacing: 0) {
                    // Header row
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

                    ForEach(steps) { step in
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

    private var tempoSection: some View {
        GroupBox("Tempo") {
            HStack {
                Image(systemName: "metronome")
                    .foregroundStyle(.orange)
                Text("\(dance.bpm) BPM")
                    .font(.headline)
                Spacer()
                Text("Set this tempo in the Start Here tab")
                    .font(.caption)
                    .foregroundStyle(.secondary)
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

    // MARK: - Helpers

    private func loadVideo() {
        if let url = currentVideoURL {
            player.setup(with: url)
        }
    }
}
