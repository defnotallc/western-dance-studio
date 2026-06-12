import SwiftUI
import MapKit
import CoreLocation

// MARK: - Shared helpers

/// Opens Apple Maps with directions to the given dance hall.
/// Uses the iOS 26+ MKMapItem(location:address:) API when available,
/// falling back to the deprecated MKPlacemark path on earlier releases.
@MainActor
func openInMaps(_ hall: DanceHall) {
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
        case masterList = "Master List"
        case mapSearch  = "Map Search"
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
