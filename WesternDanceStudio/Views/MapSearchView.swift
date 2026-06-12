import SwiftUI
import MapKit
import CoreLocation

// MARK: - Map Search (live Apple Maps search, uses master list as source)

struct MapSearchView: View {
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
                latitudinalMeters: 160_000,
                longitudinalMeters: 160_000
            )
        )
        selectedID = nil
        isSearching = false
    }
}
