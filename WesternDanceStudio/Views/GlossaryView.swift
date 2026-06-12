import SwiftUI

struct GlossaryView: View {
    @State private var searchText = ""
    @State private var debouncedSearch = ""

    private var filteredTerms: [DanceTerm] {
        let all = DanceTerm.allTerms
        return debouncedSearch.isEmpty ? all : all.filter {
            $0.term.localizedCaseInsensitiveContains(debouncedSearch) ||
            $0.definition.localizedCaseInsensitiveContains(debouncedSearch)
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
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(term.term)
                                        .font(.headline)
                                    Text(term.definition)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.vertical, 8)
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search terms like 'metronome', 'beat', or 'frame'...")
            .task(id: searchText) {
                do {
                    try await Task.sleep(for: .milliseconds(250))
                    debouncedSearch = searchText
                } catch {}
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Dance Glossary")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}
