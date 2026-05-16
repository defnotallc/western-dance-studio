import SwiftUI
import AVKit

struct DanceDetailView: View {
    let dance: Dance
    @Bindable var store: DanceStore
    @State private var selectedPerspective: Perspective = .lead
    @State private var player = ObservablePlayer()

    enum Perspective: String, CaseIterable, Identifiable {
        case lead = "Lead (Gentlemen)"
        case follow = "Follow (Ladies)"
        var id: String { rawValue }
    }

    private var currentVideoURL: URL? {
        selectedPerspective == .lead ? dance.maleVideoURL : dance.femaleVideoURL
    }

    /// Partner dances: honor the selected perspective.
    /// Solo dances (line dances): always show the single lead-step list.
    private var currentSteps: [String] {
        if dance.hasPartnerPerspectives {
            return selectedPerspective == .lead ? dance.leadSteps : dance.followSteps
        }
        return dance.leadSteps
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
        .onChange(of: selectedPerspective) { _, _ in loadVideo() }
        .onDisappear {
            // Count this as a detail-view "return" for interstitial frequency gating.
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

    private var stepsSection: some View {
        GroupBox("Step-by-Step Instructions") {
            VStack(alignment: .leading, spacing: 14) {
                StepDiagram(steps: currentSteps)

                StepDiagramLegend()

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
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal)
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
