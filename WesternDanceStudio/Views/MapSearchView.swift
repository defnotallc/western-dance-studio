import SwiftUI
import MapKit
import CoreLocation

// MARK: - Map Search

/// Shows curated dance halls near a location.
/// When the curated list is thin (< 3 venues), supplements with an
/// MKLocalSearch for nearby "country dance" venues from Apple Maps.
struct MapSearchView: View {
    @State private var position: MapCameraPosition = .automatic
    @State private var addressInput: String = ""
    @State private var searchCenter: CLLocationCoordinate2D?
    @State private var nearbyHalls: [DanceHall] = []
    @State private var supplementResults: [MKMapItem] = []
    @State private var selectedID: String?
    @State private var selectedSupplementID: String?
    @State private var isSearching = false
    @State private var errorMessage: String?
    @State private var locationManager = LocationManager.shared

    private let store = DanceHallStore.shared

    private var selectedHall: DanceHall? {
        guard let id = selectedID else { return nil }
        return nearbyHalls.first { $0.id == id }
    }

    private var selectedSupplement: MKMapItem? {
        guard let id = selectedSupplementID else { return nil }
        return supplementResults.first { $0.identifier?.rawValue == id }
    }

    var body: some View {
        VStack(spacing: 12) {
            // Search bar
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
                        clearResults()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                // Near Me
                Button {
                    Haptics.impact(.light)
                    locationManager.requestLocation()
                } label: {
                    if locationManager.isLocating {
                        ProgressView().scaleEffect(0.75)
                            .frame(width: 24)
                    } else {
                        Image(systemName: "location.fill")
                            .foregroundStyle(WesternTheme.primary)
                    }
                }
                .buttonStyle(.plain)
                .disabled(locationManager.isLocating)

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

            if let err = errorMessage ?? locationManager.errorMessage {
                Text(err)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.horizontal)
            }

            Map(position: $position, selection: $selectedID) {
                // Curated venues — orange
                ForEach(nearbyHalls) { hall in
                    Marker(hall.name, coordinate: hall.coordinate)
                        .tint(.orange)
                        .tag(hall.id)
                }
                // Apple Maps supplement — teal, only when curated list is thin
                if nearbyHalls.count < 3 {
                    ForEach(supplementResults, id: \.identifier) { item in
                        if let coord = item.placemark.location?.coordinate {
                            Marker(item.name ?? "Dance Venue", coordinate: coord)
                                .tint(.teal)
                                .tag(item.identifier?.rawValue ?? "")
                        }
                    }
                }
            }
            .mapStyle(.standard(elevation: .flat))
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 6) {
                    // Thin coverage note
                    if let center = searchCenter, nearbyHalls.count < 3 {
                        thinCoverageNote(curatedCount: nearbyHalls.count,
                                         supplementCount: supplementResults.count,
                                         hasCenter: true)
                            .padding(.horizontal)
                    }
                    if let hall = selectedHall {
                        venueCard(hall: hall)
                            .padding(.horizontal)
                    } else if let item = selectedSupplement {
                        supplementCard(item: item)
                            .padding(.horizontal)
                    }
                }
                .padding(.bottom, 8)
            }
            .overlay {
                if isSearching {
                    ProgressView()
                        .padding(12)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else if nearbyHalls.isEmpty && supplementResults.isEmpty && searchCenter == nil {
                    ContentUnavailableView(
                        "Search for dance halls",
                        systemImage: "map",
                        description: Text("Enter a zip code or city, or tap the location icon to search near you.")
                    )
                } else if nearbyHalls.isEmpty && supplementResults.isEmpty && searchCenter != nil {
                    ContentUnavailableView(
                        "No dance halls found",
                        systemImage: "map",
                        description: Text("Try a different city or check the Master List tab.")
                    )
                }
            }
        }
        .onChange(of: locationManager.lastCoordinate?.latitude) { _, _ in
            guard let coord = locationManager.lastCoordinate else { return }
            addressInput = "Near Me"
            finishGeocode(coord: coord)
        }
    }

    // MARK: - Cards

    private func venueCard(hall: DanceHall) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(hall.name).font(.headline)
                Spacer()
                Label("Verified", systemImage: "checkmark.seal.fill")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.orange)
            }
            Text("\(hall.city), \(hall.state) \(hall.zip)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            if !hall.description.isEmpty {
                Text(hall.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
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

    private func supplementCard(item: MKMapItem) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(item.name ?? "Dance Venue").font(.headline)
                Spacer()
                Label("Apple Maps", systemImage: "apple.logo")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.teal)
            }
            if let addr = item.placemark.title {
                Text(addr)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            Text("From Apple Maps — not verified by Western Dance Studio.")
                .font(.caption2)
                .foregroundStyle(.tertiary)
            if let url = item.url {
                Link("Open in Maps", destination: url)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.teal)
            } else {
                Button("Open in Maps") {
                    item.openInMaps()
                }
                .buttonStyle(.borderedProminent)
                .tint(.teal)
                .font(.caption)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Thin coverage note

    private func thinCoverageNote(curatedCount: Int, supplementCount: Int, hasCenter: Bool) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "exclamationmark.triangle")
                .font(.caption)
                .foregroundStyle(.orange)
            VStack(alignment: .leading, spacing: 2) {
                Text(curatedCount == 0 ? "No verified venues nearby." : "\(curatedCount) verified venue\(curatedCount == 1 ? "" : "s") found.")
                    .font(.caption.weight(.semibold))
                if supplementCount > 0 {
                    Text("Showing \(supplementCount) additional result\(supplementCount == 1 ? "" : "s") from Apple Maps (teal pins, unverified).")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Coverage is thin here — suggest a venue in the Master List tab.")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(8)
        .background(Color.orange.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    // MARK: - Search

    private func performSearch() {
        let text = addressInput.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        errorMessage = nil
        isSearching = true
        Task { await geocode(text) }
    }

    private func clearResults() {
        nearbyHalls = []
        supplementResults = []
        searchCenter = nil
        selectedID = nil
        selectedSupplementID = nil
    }

    private func geocode(_ text: String) async {
        if #available(iOS 26.0, *) {
            guard let request = MKGeocodingRequest(addressString: text) else {
                await MainActor.run { errorMessage = "Couldn't parse that address."; isSearching = false }
                return
            }
            do {
                let items = try await request.mapItems
                await MainActor.run { finishGeocode(coord: items.first?.location.coordinate) }
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
                        self.errorMessage = "Couldn't find that location: \(error.localizedDescription)"
                        self.isSearching = false
                        return
                    }
                    self.finishGeocode(coord: placemarks?.first?.location?.coordinate)
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
        selectedID = nil
        selectedSupplementID = nil
        position = .region(
            MKCoordinateRegion(
                center: coord,
                latitudinalMeters: 160_000,
                longitudinalMeters: 160_000
            )
        )
        isSearching = false

        // When coverage is thin, run an Apple Maps local search to supplement.
        if nearbyHalls.count < 3 {
            Task { await runLocalSearch(near: coord) }
        } else {
            supplementResults = []
        }
    }

    // MARK: - MKLocalSearch supplement

    private func runLocalSearch(near coord: CLLocationCoordinate2D) async {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "country dance bar dance hall"
        request.region = MKCoordinateRegion(
            center: coord,
            latitudinalMeters: 80_000,
            longitudinalMeters: 80_000
        )
        request.resultTypes = .pointOfInterest

        do {
            let search = MKLocalSearch(request: request)
            let response = try await search.start()
            let items = response.mapItems.prefix(8)
            await MainActor.run {
                supplementResults = Array(items)
            }
        } catch {
            // Local search failure is non-fatal — curated results still show.
            await MainActor.run { supplementResults = [] }
        }
    }
}
