import SwiftUI

struct DanceListView: View {
    @Bindable var store: DanceStore
    @State private var searchText = ""
    @State private var debouncedSearch = ""

    /// All dances filtered by the current search, grouped by category and
    /// pre-sorted by difficulty. Computed once per render instead of
    /// per-category inside ForEach (which was ~5x redundant work).
    private var groupedDances: [(Dance.DanceCategory, [Dance])] {
        let base = Dance.sampleDances
        let filtered: [Dance] = debouncedSearch.isEmpty ? base : base.filter {
            $0.name.localizedCaseInsensitiveContains(debouncedSearch) ||
            $0.category.rawValue.localizedCaseInsensitiveContains(debouncedSearch) ||
            $0.recommendedSongs.contains { $0.localizedCaseInsensitiveContains(debouncedSearch) }
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
            .searchable(text: $searchText, prompt: "Search dances, songs, or categories...")
            .task(id: searchText) {
                do {
                    try await Task.sleep(for: .milliseconds(250))
                    debouncedSearch = searchText
                } catch {
                    // cancelled
                }
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
    @Bindable var store: DanceStore

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
        }
        .padding(.vertical, 4)
    }
}
