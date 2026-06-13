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

    private func groupedTerms(from terms: [DanceTerm]) -> [(String, [DanceTerm])] {
        Dictionary(grouping: terms) { String($0.term.prefix(1)).uppercased() }
            .sorted { $0.key < $1.key }
    }

    var body: some View {
        let terms = filteredTerms
        NavigationStack {
            List {
                if terms.isEmpty && !debouncedSearch.isEmpty {
                    ContentUnavailableView("No matching terms", systemImage: "magnifyingglass")
                } else {
                    ForEach(groupedTerms(from: terms), id: \.0) { letter, terms in
                        Section(header: Text(letter).font(.headline).foregroundStyle(.orange)) {
                            ForEach(terms) { term in
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                                        Text(term.term)
                                            .font(.headline)
                                        Text(term.category.rawValue)
                                            .font(.caption2)
                                            .foregroundStyle(.white)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(WesternTheme.primary.opacity(0.75), in: Capsule())
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
                                .padding(.vertical, 8)
                            }
                        }
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
