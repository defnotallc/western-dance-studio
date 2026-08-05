import Foundation
import CoreLocation

// MARK: - Model

struct DanceHall: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let city: String
    let state: String
    let zip: String
    let dances: [String]
    let lessons: String
    let description: String
    let latitude: Double
    let longitude: Double

    // Optional contact & metadata fields — absent in older JSON records (decoded as nil).
    let website: String?
    let phone: String?
    let hours: String?
    let verifiedDate: String?   // YYYY-MM-DD of last human verification

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var websiteURL: URL? {
        guard let s = website, !s.isEmpty else { return nil }
        if s.hasPrefix("http") { return URL(string: s) }
        return URL(string: "https://\(s)")
    }

    var phoneURL: URL? {
        guard let p = phone, !p.isEmpty else { return nil }
        let digits = p.filter { $0.isNumber || $0 == "+" }
        return URL(string: "tel://\(digits)")
    }
}

struct DanceHallDatabase: Codable {
    let lastUpdated: String
    let venues: [DanceHall]
}

// MARK: - Store

/// Loads and caches the bundled dance hall database.
/// JSON file `DanceHalls.json` must be added to the app target.
@MainActor
final class DanceHallStore {
    static let shared = DanceHallStore()

    let database: DanceHallDatabase

    private init() {
        guard let url = Bundle.main.url(forResource: "DanceHalls", withExtension: "json") else {
            AppLog.data.fault("""
                DanceHalls.json NOT FOUND in app bundle (bundle path: \(Bundle.main.bundlePath, privacy: .public)). \
                Fix: select DanceHalls.json in Xcode's navigator, open the File Inspector, and check \
                Target Membership → WesternDanceStudio.
                """)
            self.database = DanceHallDatabase(lastUpdated: "", venues: [])
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode(DanceHallDatabase.self, from: data)
            self.database = decoded
            AppLog.data.info("Loaded \(decoded.venues.count, privacy: .public) dance halls from bundle (updated \(decoded.lastUpdated, privacy: .public))")
            #if DEBUG
            Self.warnIfStale(lastUpdated: decoded.lastUpdated)
            #endif
        } catch {
            AppLog.data.error("DanceHalls.json found but failed to decode: \(error.localizedDescription, privacy: .public)")
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
            AppLog.data.error("Could not parse DanceHalls.lastUpdated value '\(lastUpdated, privacy: .public)' — expected YYYY-MM-DD format")
            return
        }

        let ageInDays = Calendar.current.dateComponents([.day], from: lastDate, to: Date()).day ?? 0
        let staleThresholdDays = 183  // ~6 months

        if ageInDays > staleThresholdDays {
            AppLog.data.fault("""
                VENUE MASTER LIST IS STALE — last updated \(lastUpdated, privacy: .public) \
                (\(ageInDays, privacy: .public) days ago). Audit venue addresses, descriptions, and \
                closures, then update the lastUpdated field in DanceHalls.json.
                """)
        }
    }
    #endif

    var allVenues: [DanceHall] { database.venues }
    var lastUpdated: String { database.lastUpdated }

    /// Venues grouped by state, sorted alphabetically by state then city then name.
    /// Computed once on first access — the bundle JSON is static at runtime.
    lazy var venuesByState: [(state: String, venues: [DanceHall])] = {
        let grouped = Dictionary(grouping: allVenues, by: { $0.state })
        return grouped.keys.sorted().map { state in
            let sorted = (grouped[state] ?? []).sorted {
                if $0.city == $1.city { return $0.name < $1.name }
                return $0.city < $1.city
            }
            return (state: state, venues: sorted)
        }
    }()

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
