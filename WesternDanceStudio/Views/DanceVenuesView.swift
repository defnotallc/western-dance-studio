import SwiftUI
import MapKit
import CoreLocation

// MARK: - Shared helpers

/// Opens Apple Maps with directions to the given dance hall.
/// Uses the iOS 26+ MKMapItem(location:address:) API when available,
/// falling back to the deprecated MKPlacemark path on earlier releases.
@MainActor
private func openInMaps(_ hall: DanceHall) {
    let item: MKMapItem
    if #available(iOS 26.0, *) {
        let location = CLLocation(
            latitude: hall.coordinate.latitude,
            longitude: hall.coordinate.longitude
        )
        item = MKMapItem(location: location, address: nil)
    } else {
        let mark = MKPlacemark(coordinate: hall.coordinate)
        item = MKMapItem(placemark: mark)
    }
    item.name = hall.name
    item.openInMaps(launchOptions: nil)
}

// MARK: - Parent with tabs

struct DanceVenuesView: View {
    @State private var selectedTab: Tab = .masterList

    private enum Tab: String, CaseIterable {
        // Order matters — the first case is the left segment in the Picker.
        // Master List comes first so it's the default landing experience.
        case masterList = "Master List"
        case mapSearch = "Map Search"
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Mode", selection: $selectedTab) {
                    ForEach(Tab.allCases, id: \.self) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 8)

                // Banner appears only on the master list (text-based content).
                // Map Search stays banner-free so the map has full real estate.
                switch selectedTab {
                case .masterList:
                    MasterListView()
                        .withBannerAd()
                case .mapSearch:
                    MapSearchView()
                }
            }
            .navigationTitle("Venues")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Map Search (live Apple Maps search, uses master list as source)

private struct MapSearchView: View {
    @State private var position: MapCameraPosition = .automatic
    @State private var addressInput: String = ""
    @State private var searchCenter: CLLocationCoordinate2D?
    @State private var nearbyHalls: [DanceHall] = []
    @State private var selectedID: String?
    @State private var isSearching = false
    @State private var errorMessage: String?

    private let store = DanceHallStore.shared

    private var selectedHall: DanceHall? {
        guard let id = selectedID else { return nil }
        return nearbyHalls.first { $0.id == id }
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Enter zip code or city", text: $addressInput)
                    .textFieldStyle(.plain)
                    .submitLabel(.search)
                    .onSubmit { performSearch() }
                    .autocorrectionDisabled()
                if !addressInput.isEmpty {
                    Button {
                        addressInput = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                Button("Search") {
                    Haptics.impact(.light)
                    performSearch()
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
                .disabled(addressInput.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(10)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)

            if let errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.horizontal)
            }

            Map(position: $position, selection: $selectedID) {
                ForEach(nearbyHalls) { hall in
                    Marker(hall.name, coordinate: hall.coordinate)
                        .tint(.orange)
                        .tag(hall.id)
                }
            }
            .mapStyle(.standard(elevation: .flat))
            .safeAreaInset(edge: .bottom) {
                if let hall = selectedHall {
                    venueCard(hall)
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                }
            }
            .overlay {
                if isSearching {
                    ProgressView()
                        .padding(12)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else if nearbyHalls.isEmpty && searchCenter == nil {
                    ContentUnavailableView(
                        "Search for dance halls",
                        systemImage: "map",
                        description: Text("Enter a zip code or city above. Results show all dance halls within 50 miles.")
                    )
                } else if nearbyHalls.isEmpty {
                    ContentUnavailableView(
                        "No dance halls within 50 miles",
                        systemImage: "map",
                        description: Text("Try a different city or check the Master List tab.")
                    )
                }
            }
        }
    }

    private func venueCard(_ hall: DanceHall) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(hall.name).font(.headline)
            Text("\(hall.city), \(hall.state) \(hall.zip)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            if !hall.description.isEmpty {
                Text(hall.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            }
            if let center = searchCenter {
                let miles = store.milesFrom(center, to: hall)
                Text(String(format: "%.1f miles from search", miles))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            Button("Get Directions in Maps") {
                openInMaps(hall)
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            .font(.caption)
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: Search

    private func performSearch() {
        let text = addressInput.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        errorMessage = nil
        isSearching = true
        Task { await geocode(text) }
    }

    private func geocode(_ text: String) async {
        if #available(iOS 26.0, *) {
            guard let request = MKGeocodingRequest(addressString: text) else {
                await MainActor.run {
                    errorMessage = "Couldn't parse that address."
                    isSearching = false
                }
                return
            }
            do {
                let items = try await request.mapItems
                await MainActor.run {
                    finishGeocode(coord: items.first?.location.coordinate)
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Couldn't find that location: \(error.localizedDescription)"
                    isSearching = false
                }
            }
        } else {
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(text) { placemarks, error in
                Task { @MainActor in
                    if let error {
                        errorMessage = "Couldn't find that location: \(error.localizedDescription)"
                        isSearching = false
                        return
                    }
                    finishGeocode(coord: placemarks?.first?.location?.coordinate)
                }
            }
        }
    }

    @MainActor
    private func finishGeocode(coord: CLLocationCoordinate2D?) {
        guard let coord else {
            errorMessage = "Couldn't find that location."
            isSearching = false
            return
        }
        searchCenter = coord
        nearbyHalls = store.venues(within: 50, of: coord)
        position = .region(
            MKCoordinateRegion(
                center: coord,
                latitudinalMeters: 160_000, // 100-mile window
                longitudinalMeters: 160_000
            )
        )
        selectedID = nil
        isSearching = false
    }
}

// MARK: - Master List

private struct MasterListView: View {
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

        // Case 1: no query → full list grouped by state
        if query.isEmpty {
            return store.venuesByState
        }

        // Case 2: we have a geocoded search center → radius filter within 50 miles
        if let center = searchCenter {
            let nearby = store.venues(within: 50, of: center)
            if nearby.isEmpty {
                return []
            }
            let grouped = Dictionary(grouping: nearby, by: { $0.state })
            return grouped.keys.sorted().map { state in
                (state: state, venues: (grouped[state] ?? []).sorted { $0.city < $1.city })
            }
        }

        // Case 3: fallback plain-text match across name/city/state/zip
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

    /// Flat, sorted list for radius mode — nearest first, regardless of state.
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

                // Radius-mode: flat list sorted by distance
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
                    // Text-match or full-list mode: group by state
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
                // Auto-geocode if user typed a 5-digit zip — no need to press Return
                if trimmed.count == 5, Int(trimmed) != nil {
                    tryGeocode(trimmed)
                }
                // Otherwise keep existing center until user presses Return
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

    /// Attempt to geocode the user's query. On success, store the center so the
    /// list switches to radius mode. On failure, leave center nil — the list
    /// falls back to plain text matching.
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

// MARK: - Dance Hall detail

private struct DanceHallDetailView: View {
    let hall: DanceHall

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(hall.city), \(hall.state) \(hall.zip)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                if !hall.description.isEmpty {
                    GroupBox {
                        Text(hall.description)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                if !hall.dances.isEmpty {
                    GroupBox("Dances") {
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(hall.dances, id: \.self) { d in
                                Label(d, systemImage: "figure.dance")
                                    .font(.subheadline)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                if !hall.lessons.isEmpty {
                    GroupBox("Lessons") {
                        Text(hall.lessons)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                Button {
                    Haptics.impact(.light)
                    openInMaps(hall)
                } label: {
                    Label("Get Directions in Maps", systemImage: "arrow.triangle.turn.up.right.diamond.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
                .padding(.top, 8)
            }
            .padding()
        }
        .navigationTitle(hall.name)
        .navigationBarTitleDisplayMode(.inline)
        .withBannerAd()
        .onDisappear {
            // Count this as a "return" for interstitial frequency gating,
            // matching the behavior on dance detail views.
            AdManager.shared.recordDetailReturn()
        }
    }
}
