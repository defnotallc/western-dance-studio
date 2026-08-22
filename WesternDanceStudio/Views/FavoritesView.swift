import SwiftUI

struct FavoritesView: View {
    @Bindable var store: DanceStore

    var favoriteDances: [Dance] {
        Dance.sampleDances.filter { store.favorites.contains($0.id) }
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
                            VStack(spacing: 0) {
                                ForEach(favoriteDances) { dance in
                                    NavigationLink(value: dance) {
                                        favoriteRow(dance)
                                    }
                                    .buttonStyle(.plain)
                                    Divider()
                                        .padding(.leading)
                                }
                            }
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding(.horizontal)
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
