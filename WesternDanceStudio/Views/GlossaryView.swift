import SwiftUI

struct GlossaryView: View {
    @State private var searchText = ""
    @State private var debouncedSearch = ""

    private var filteredTerms: [DanceTerm] {
        let all = DanceTerm.allTerms
        return debouncedSearch.isEmpty ? all : all.filter {
            $0.term.localizedCaseInsensitiveContains(debouncedSearch) ||
            $0.definition.localizedCaseInsensitiveContains(debouncedSearch) ||
            ($0.technicalNote?.localizedCaseInsensitiveContains(debouncedSearch) == true) ||
            ($0.commonMisconceptions?.localizedCaseInsensitiveContains(debouncedSearch) == true) ||
            $0.relatedTerms.contains { $0.localizedCaseInsensitiveContains(debouncedSearch) }
        }
    }

    var body: some View {
        let terms = filteredTerms
        NavigationStack {
            List {
                if terms.isEmpty && !debouncedSearch.isEmpty {
                    ContentUnavailableView("No matching terms", systemImage: "magnifyingglass")
                } else {
                    ForEach(terms) { term in
                        GlossaryRow(term: term)
                            .padding(.vertical, 6)
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search terms like 'metronome', 'beat', or 'frame'...")
            .debounced(source: $searchText, into: $debouncedSearch)
            .listStyle(.insetGrouped)
            .navigationTitle("Dance Glossary")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

private struct GlossaryRow: View {
    let term: DanceTerm

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top) {
                Text(term.term)
                    .font(.headline)
                Spacer()
                CategoryBadge(category: term.category)
            }
            Text(term.definition)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            if let note = term.technicalNote {
                Label(note, systemImage: "info.circle")
                    .font(.caption)
                    .foregroundStyle(.blue.opacity(0.85))
            }
            if let myth = term.commonMisconceptions {
                Label(myth, systemImage: "exclamationmark.triangle")
                    .font(.caption)
                    .foregroundStyle(.orange.opacity(0.9))
            }
        }
    }
}

private struct CategoryBadge: View {
    let category: DanceTerm.TermCategory

    var color: Color {
        switch category {
        case .musicAndTiming:    return .purple
        case .footwork:          return .blue
        case .partnerDance:      return Color(red: 0.8, green: 0.2, blue: 0.4)
        case .lineDance:         return .teal
        case .danceStyles:       return Color(red: 0.55, green: 0.35, blue: 0.1)
        case .venueAndEtiquette: return .green
        }
    }

    var body: some View {
        Text(category.rawValue)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(color, in: Capsule())
    }
}
