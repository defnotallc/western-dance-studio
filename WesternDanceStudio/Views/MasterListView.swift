import SwiftUI
import MapKit
import CoreLocation

// MARK: - Master List

struct MasterListView: View {
    @State private var searchText: String = ""
    @State private var searchCenter: CLLocationCoordinate2D?
    @State private var isGeocoding: Bool = false
    @State private var geocodingError: String?

    private let store = DanceHallStore.shared

    /// Query is interpreted intelligently:
    /// - Empty: show all venues grouped by state
    /// - 5-digit zip OR city/location text: geocode and show venues within 50 miles (nearest first)
    /// - Name fragment: fall through to text match across name/city/state/zip
    private var filteredByState: [(state: String, venues: [DanceHall])] {
        let query = searchText.trimmingCharacters(in: .whitespaces).lowercased()

        if query.isEmpty {
            return store.venuesByState
        }

        if let center = searchCenter {
            let nearby = store.venues(within: 50, of: center)
            if nearby.isEmpty { return [] }
            let grouped = Dictionary(grouping: nearby, by: { $0.state })
            return grouped.keys.sorted().map { state in
                (state: state, venues: (grouped[state] ?? []).sorted { $0.city < $1.city })
            }
        }

        let all = store.allVenues.filter { hall in
            hall.city.lowercased().contains(query)
                || hall.state.lowercased().contains(query)
                || hall.zip.contains(query)
                || hall.name.lowercased().contains(query)
        }
        let grouped = Dictionary(grouping: all, by: { $0.state })
        return grouped.keys.sorted().map { state in
            (state: state, venues: (grouped[state] ?? []).sorted { $0.city < $1.city })
        }
    }

    private var nearbySortedByDistance: [DanceHall]? {
        guard let center = searchCenter else { return nil }
        return store.venues(within: 50, of: center)
    }

    var body: some View {
        VStack(spacing: 0) {
            List {
                Section {
                    HStack(spacing: 6) {
                        Image(systemName: "info.circle")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("List last updated \(store.lastUpdated)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                if let error = geocodingError {
                    Section {
                        Label(error, systemImage: "exclamationmark.triangle.fill")
                            .foregroundStyle(.red)
                            .font(.caption)
                    }
                }

                if let nearby = nearbySortedByDistance, !searchText.isEmpty {
                    Section("Within 50 miles of '\(searchText)'") {
                        if nearby.isEmpty {
                            Text("No venues within 50 miles. Try a different location.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(nearby) { hall in
                                venueRow(hall, distanceFrom: searchCenter)
                            }
                        }
                    }
                } else {
                    ForEach(filteredByState, id: \.state) { group in
                        Section(group.state) {
                            ForEach(group.venues) { hall in
                                venueRow(hall, distanceFrom: nil)
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .searchable(text: $searchText, prompt: "Search zip, city, or venue name")
            .onSubmit(of: .search) {
                tryGeocode(searchText)
            }
            .onChange(of: searchText) { _, newValue in
                let trimmed = newValue.trimmingCharacters(in: .whitespaces)
                if trimmed.isEmpty {
                    searchCenter = nil
                    geocodingError = nil
                    return
                }
                if trimmed.count == 5, Int(trimmed) != nil {
                    tryGeocode(trimmed)
                }
            }
            .overlay {
                if isGeocoding {
                    ProgressView().padding(12)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else if let nearby = nearbySortedByDistance, nearby.isEmpty {
                    ContentUnavailableView(
                        "No venues within 50 miles",
                        systemImage: "map",
                        description: Text("Try a different city or zip code.")
                    )
                } else if filteredByState.isEmpty && searchCenter == nil {
                    ContentUnavailableView.search
                }
            }
        }
    }

    private func tryGeocode(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            searchCenter = nil
            return
        }
        isGeocoding = true
        geocodingError = nil
        Task { await geocodeAsync(trimmed) }
    }

    private func geocodeAsync(_ text: String) async {
        if #available(iOS 26.0, *) {
            guard let request = MKGeocodingRequest(addressString: text) else {
                await MainActor.run {
                    isGeocoding = false
                    searchCenter = nil
                }
                return
            }
            do {
                let items = try await request.mapItems
                await MainActor.run {
                    searchCenter = items.first?.location.coordinate
                    isGeocoding = false
                }
            } catch {
                await MainActor.run {
                    isGeocoding = false
                    searchCenter = nil
                }
            }
        } else {
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(text) { placemarks, _ in
                Task { @MainActor in
                    searchCenter = placemarks?.first?.location?.coordinate
                    isGeocoding = false
                }
            }
        }
    }

    @ViewBuilder
    private func venueRow(_ hall: DanceHall, distanceFrom center: CLLocationCoordinate2D?) -> some View {
        NavigationLink {
            DanceHallDetailView(hall: hall)
        } label: {
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(hall.name).font(.headline)
                    Spacer()
                    if let center {
                        let miles = store.milesFrom(center, to: hall)
                        Text(String(format: "%.0f mi", miles))
                            .font(.caption2.bold())
                            .foregroundStyle(WesternTheme.primary)
                    }
                }
                Text("\(hall.city), \(hall.state) • \(hall.zip)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if !hall.dances.isEmpty {
                    Text(hall.dances.joined(separator: " • "))
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                }
            }
        }
    }
}
