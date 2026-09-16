import SwiftUI

struct DanceListView: View {
    let store: DanceStore
    @State private var searchText = ""
    @State private var debouncedSearch = ""
    /// Cached filter+group+sort result. Updated only when debouncedSearch changes,
    /// so store mutations (e.g. favorites) never trigger a recompute.
    @State private var groupedDances: [(Dance.DanceCategory, [Dance])] = Self.makeGrouped(query: "")

    /// Semantic-search state. Additive: the keyword results above are always
    /// computed and shown, and this only ever appends a section.
    @State private var semanticMatches: [Dance] = []
    @State private var semanticState: SemanticState = .idle

    private let intelligence = DanceIntelligence.shared

    private enum SemanticState: Equatable {
        case idle, searching, done, failed
    }

    private static func makeGrouped(query: String) -> [(Dance.DanceCategory, [Dance])] {
        let base = Dance.sampleDances
        let filtered: [Dance] = query.isEmpty ? base : base.filter {
            $0.name.localizedCaseInsensitiveContains(query) ||
            $0.category.rawValue.localizedCaseInsensitiveContains(query) ||
            $0.recommendedSongs.contains { $0.localizedCaseInsensitiveContains(query) }
        }
        let grouped = Dictionary(grouping: filtered, by: \.category)
        return Dance.DanceCategory.allCases.compactMap { category in
            guard let dances = grouped[category], !dances.isEmpty else { return nil }
            return (category, dances.sorted { $0.difficulty < $1.difficulty })
        }
    }

    var body: some View {
        NavigationStack {
            List {
                // Always above the keyword results, including when there are
                // none — a query that keyword search cannot match is exactly
                // when semantic search earns its place.
                semanticSection
                if groupedDances.isEmpty && !debouncedSearch.isEmpty {
                    if semanticMatches.isEmpty {
                        ContentUnavailableView.search(text: debouncedSearch)
                    }
                } else {
                    ForEach(groupedDances, id: \.0) { category, categoryDances in
                        Section(header:
                            Text(category.rawValue)
                                .font(WesternTheme.displayFont(size: 16, weight: .bold))
                                .foregroundStyle(WesternTheme.primaryDark)
                        ) {
                            ForEach(categoryDances) { dance in
                                NavigationLink(value: dance) {
                                    DanceRow(dance: dance, store: store)
                                }
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search dances, songs, or categories...")
            .debounced(source: $searchText, into: $debouncedSearch)
            .onChange(of: debouncedSearch) { _, new in
                groupedDances = Self.makeGrouped(query: new)
                // A new query invalidates any previous semantic result.
                semanticMatches = []
                semanticState = .idle
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Dances")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: Dance.self) { dance in
                DanceDetailView(dance: dance, store: store)
            }
        }
    }

    // MARK: - Natural-language search

    /// Offered only on Apple Intelligence capable devices, and only for queries
    /// long enough to be a phrase rather than a partial word. Keyword search is
    /// untouched and remains the default on every device.
    @ViewBuilder
    private var semanticSection: some View {
        if intelligence.isSupported, debouncedSearch.split(separator: " ").count >= 2 {
            Section {
                switch semanticState {
                case .idle:
                    Button {
                        Haptics.selection()
                        runSemanticSearch(for: debouncedSearch)
                    } label: {
                        Label("Find dances that match this idea", systemImage: "sparkles")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(WesternTheme.primary)
                    }

                case .searching:
                    HStack(spacing: 8) {
                        ProgressView().controlSize(.small)
                        Text("Searching…").foregroundStyle(.secondary)
                    }

                case .done where semanticMatches.isEmpty:
                    Text("No close matches — try the keyword results below.")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                case .done:
                    ForEach(semanticMatches) { dance in
                        NavigationLink(value: dance) {
                            DanceRow(dance: dance, store: store)
                        }
                    }

                case .failed:
                    Text("Couldn't search just now — keyword results are below.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Suggested for \"\(debouncedSearch)\"")
                    .font(WesternTheme.displayFont(size: 16, weight: .bold))
                    .foregroundStyle(WesternTheme.primaryDark)
            }
        }
    }

    private func runSemanticSearch(for query: String) {
        semanticState = .searching
        Task {
            do {
                let ids = try await intelligence.matchingDanceIDs(for: query, in: Dance.sampleDances)
                // Resolve against the catalogue; unknown IDs were already
                // filtered by the service, this keeps ordering intentional.
                let byID = Dictionary(Dance.sampleDances.map { ($0.id, $0) },
                                      uniquingKeysWith: { first, _ in first })
                guard semanticState == .searching else { return }
                semanticMatches = ids.compactMap { byID[$0] }
                semanticState = .done
            } catch {
                AppLog.data.error("Semantic search failed: \(error.localizedDescription, privacy: .public)")
                semanticMatches = []
                semanticState = .failed
            }
        }
    }
}

// MARK: - Row

private struct DanceRow: View {
    let dance: Dance
    let store: DanceStore

    private var isFavorite: Bool { store.favorites.contains(dance.id) }

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(dance.name)
                    .font(WesternTheme.headlineFont(size: 18, weight: .bold))

                HStack(spacing: 6) {
                    DifficultyStars(difficulty: dance.difficulty, size: 9)
                    Text("\(dance.difficulty)/10")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Button {
                Haptics.selection()
                store.toggleFavorite(dance)
            } label: {
                Image(systemName: isFavorite ? "star.fill" : "star")
                    .foregroundStyle(WesternTheme.primary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(isFavorite ? "Remove from favorites" : "Add to favorites")
        }
        .padding(.vertical, 4)
    }
}
