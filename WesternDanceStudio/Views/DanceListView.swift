import SwiftUI

struct DanceListView: View {
    let store: DanceStore
    @State private var searchText = ""
    @State private var debouncedSearch = ""
    /// Cached filter+group+sort result. Updated only when debouncedSearch changes,
    /// so store mutations (e.g. favorites) never trigger a recompute.
    @State private var groupedDances: [(Dance.DanceCategory, [Dance])] = Self.makeGrouped(query: "")

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
                if groupedDances.isEmpty && !debouncedSearch.isEmpty {
                    ContentUnavailableView.search(text: debouncedSearch)
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
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Dances")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: Dance.self) { dance in
                DanceDetailView(dance: dance, store: store)
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
