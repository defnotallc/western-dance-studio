import SwiftUI

struct FavoritesView: View {
    @Bindable var store: DanceStore

    /// Honours the user's chosen order rather than the catalogue order.
    var favoriteDances: [Dance] {
        let byID = Dictionary(Dance.sampleDances.map { ($0.id, $0) },
                              uniquingKeysWith: { first, _ in first })
        return store.favoriteOrder.compactMap { byID[$0] }
    }

    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        if favoriteDances.isEmpty {
                            emptyState
                                .padding(.horizontal)
                                .padding(.top, 40)
                        } else {
                            reorderableFavoritesList
                        }

                        // Gear section always visible — monetizes the empty state
                        // and fills space below the user's favorites list.
                        GearLinksSection()
                            .padding(.horizontal)

                        Spacer(minLength: 24)
                    }
                    .padding(.vertical)
                    // Fills the full available height on iPad so no dead space below.
                    .frame(minHeight: proxy.size.height)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Favorites")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: Dance.self) { dance in
                DanceDetailView(dance: dance, store: store)
            }
        }
    }

    // MARK: - Favorites list

    /// iOS 27 adds drag-to-reorder and swipe actions for non-`List` content.
    /// Below 27 the same rows render without either, so the screen keeps
    /// working unchanged on the 26.4 deployment target.
    @ViewBuilder
    private var reorderableFavoritesList: some View {
        if #available(iOS 27.0, *) {
            favoritesStack
                .reorderContainer(for: Dance.self) { difference in
                    let beforeID: String?
                    switch difference.destination.position {
                    case .before(let id): beforeID = id
                    case .end:            beforeID = nil
                    }
                    withAnimation(.snappy) {
                        store.applyReorder(sources: difference.sources, before: beforeID)
                    }
                }
        } else {
            favoritesStack
        }
    }

    private var favoritesStack: some View {
        VStack(spacing: 0) {
            favoriteRows
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal)
    }

    @ViewBuilder
    private var favoriteRows: some View {
        if #available(iOS 27.0, *) {
            ForEach(favoriteDances) { dance in
                favoriteRowLink(dance)
                    .swipeActionsContainer()
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            unfavorite(dance)
                        } label: {
                            Label("Remove", systemImage: "star.slash")
                        }
                    }
                Divider()
                    .padding(.leading)
            }
            .reorderable()
        } else {
            ForEach(favoriteDances) { dance in
                favoriteRowLink(dance)
                Divider()
                    .padding(.leading)
            }
        }
    }

    private func favoriteRowLink(_ dance: Dance) -> some View {
        NavigationLink(value: dance) {
            favoriteRow(dance)
        }
        .buttonStyle(.plain)
        // Available on every supported OS, so removing a favorite is never
        // gated behind the iOS 27-only swipe affordance.
        .contextMenu {
            Button(role: .destructive) {
                unfavorite(dance)
            } label: {
                Label("Remove from Favorites", systemImage: "star.slash")
            }
        }
    }

    private func unfavorite(_ dance: Dance) {
        Haptics.selection()
        withAnimation(.snappy) {
            store.toggleFavorite(dance)
        }
    }

    // MARK: - Subviews

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "star")
                .font(.system(size: 48))
                .foregroundStyle(WesternTheme.primary.opacity(0.6))
            Text("No favorites yet")
                .font(.headline)
            Text("Tap the star on any dance to save it here.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(32)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func favoriteRow(_ dance: Dance) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(dance.name)
                    .font(WesternTheme.headlineFont(size: 17, weight: .bold))
                    .foregroundStyle(.primary)
                Text(dance.category.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding()
        .contentShape(Rectangle())
    }
}
