import Foundation
import CoreLocation

// MARK: - Model

struct DanceHall: Identifiable, Hashable, Codable {
    var id: String { "\(name)-\(city)-\(state)" }
    let name: String
    let city: String
    let state: String
    let zip: String
    let dances: [String]
    let lessons: String
    let description: String
    let latitude: Double
    let longitude: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

struct DanceHallDatabase: Codable {
    let lastUpdated: String
    let venues: [DanceHall]
}

// MARK: - Store

/// Loads and caches the bundled dance hall database.
/// JSON file `DanceHalls.json` must be added to the app target.
final class DanceHallStore {
    static let shared = DanceHallStore()

    let database: DanceHallDatabase

    private init() {
        guard let url = Bundle.main.url(forResource: "DanceHalls", withExtension: "json") else {
            #if DEBUG
            print("❌ DanceHalls.json NOT FOUND in app bundle.")
            print("   Bundle path: \(Bundle.main.bundlePath)")
            print("   Fix: Add DanceHalls.json to the WesternDanceStudio target:")
            print("   1. In Xcode, click DanceHalls.json in the navigator")
            print("   2. Open the File Inspector (right sidebar, top tab)")
            print("   3. Under 'Target Membership', check ✓ WesternDanceStudio")
            #endif
            self.database = DanceHallDatabase(lastUpdated: "", venues: [])
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode(DanceHallDatabase.self, from: data)
            self.database = decoded
            #if DEBUG
            print("✅ Loaded \(decoded.venues.count) dance halls from bundle (updated \(decoded.lastUpdated))")
            Self.warnIfStale(lastUpdated: decoded.lastUpdated)
            #endif
        } catch {
            #if DEBUG
            print("❌ DanceHalls.json found but failed to decode: \(error)")
            #endif
            self.database = DanceHallDatabase(lastUpdated: "", venues: [])
        }
    }

    #if DEBUG
    /// Emits a loud console warning when the venue master list is more than
    /// 6 months old, reminding the dev to audit addresses, descriptions, and
    /// closures. The build-phase script in `check-venues-freshness.sh`
    /// surfaces the same warning in Xcode's issue navigator at compile time.
    private static func warnIfStale(lastUpdated: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "UTC")

        guard let lastDate = formatter.date(from: lastUpdated) else {
            print("⚠️ Could not parse DanceHalls.lastUpdated value '\(lastUpdated)' — expected YYYY-MM-DD format")
            return
        }

        let ageInDays = Calendar.current.dateComponents([.day], from: lastDate, to: Date()).day ?? 0
        let staleThresholdDays = 183  // ~6 months

        if ageInDays > staleThresholdDays {
            print("")
            print("⚠️⚠️⚠️ VENUE MASTER LIST IS STALE ⚠️⚠️⚠️")
            print("   Last updated: \(lastUpdated) (\(ageInDays) days ago)")
            print("   Action: audit venue addresses, descriptions, and closures.")
            print("   After auditing, update the lastUpdated field in DanceHalls.json.")
            print("")
        }
    }
    #endif

    var allVenues: [DanceHall] { database.venues }
    var lastUpdated: String { database.lastUpdated }

    /// Venues grouped by state, state names sorted alphabetically, venues within each state sorted by city then name.
    var venuesByState: [(state: String, venues: [DanceHall])] {
        let grouped = Dictionary(grouping: allVenues, by: { $0.state })
        return grouped.keys.sorted().map { state in
            let sorted = (grouped[state] ?? []).sorted {
                if $0.city == $1.city { return $0.name < $1.name }
                return $0.city < $1.city
            }
            return (state: state, venues: sorted)
        }
    }

    /// Venues within `radiusMiles` of `center`, sorted nearest first.
    func venues(within radiusMiles: Double, of center: CLLocationCoordinate2D) -> [DanceHall] {
        let centerLoc = CLLocation(latitude: center.latitude, longitude: center.longitude)
        let metersPerMile = 1609.34
        let radiusMeters = radiusMiles * metersPerMile

        let nearby: [(hall: DanceHall, distance: CLLocationDistance)] = allVenues.compactMap { hall in
            let hallLoc = CLLocation(latitude: hall.latitude, longitude: hall.longitude)
            let distance = centerLoc.distance(from: hallLoc)
            guard distance <= radiusMeters else { return nil }
            return (hall, distance)
        }
        return nearby
            .sorted { $0.distance < $1.distance }
            .map { $0.hall }
    }

    /// Miles between a coordinate and a venue. For display.
    func milesFrom(_ coord: CLLocationCoordinate2D, to hall: DanceHall) -> Double {
        let a = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
        let b = CLLocation(latitude: hall.latitude, longitude: hall.longitude)
        return a.distance(from: b) / 1609.34
    }
}
