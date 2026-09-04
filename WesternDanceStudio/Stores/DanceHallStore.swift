import Foundation
import CoreLocation
import Combine

/// URL of the canonical hosted venue database.
/// Updating this file deploys venue changes instantly — no App Store release required.
/// The app always starts from the bundled JSON (fast, works offline) and then
/// silently upgrades in the background if a newer version is available remotely.
private let remoteVenueURL = URL(
    string: "https://raw.githubusercontent.com/defnotallc/WesternDanceStudio/main/WesternDanceStudio/DanceHalls.json"
)!

/// Local cache path — persists between launches so the remote data survives restarts.
private let cachedVenueURL: URL = {
    let dir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    return dir.appendingPathComponent("DanceHalls_remote.json")
}()

/// Loads and caches the venue database.
///
/// **Start-up order (fastest + most-reliable first):**
/// 1. Bundled `DanceHalls.json` — always available, loads synchronously.
/// 2. Locally-cached remote copy (from a prior background refresh) — replaces
///    bundled data if its `lastUpdated` is newer.
/// 3. Background remote fetch — silently fetches the latest from GitHub on each
///    launch; if newer than what's loaded, swaps the live `database` property
///    and notifies observers via `venuesDidUpdate`.
///
/// This means venue additions, corrections, and closures ship the moment the
/// JSON is pushed to `main` — no App Store review needed.
@MainActor
final class DanceHallStore {
    static let shared = DanceHallStore()

    /// Published so views can react when a background refresh brings in new data.
    @Published private(set) var database: DanceHallDatabase

    private init() {
        // 1. Load bundled JSON (synchronous, always succeeds).
        let bundled = Self.loadBundled()

        // 2. Prefer a cached remote copy if it's newer.
        let cached = Self.loadCached()
        if let cached, Self.isNewer(cached, than: bundled) {
            self.database = cached
            AppLog.data.info("Using cached remote venue data (updated \(cached.lastUpdated, privacy: .public))")
        } else {
            self.database = bundled
        }

        #if DEBUG
        Self.warnIfStale(lastUpdated: database.lastUpdated)
        #endif

        // 3. Kick off a background fetch; swap if the remote is newer.
        Task { await self.fetchRemoteIfNewer() }
    }

    // MARK: - Load helpers

    private static func loadBundled() -> DanceHallDatabase {
        guard let url = Bundle.main.url(forResource: "DanceHalls", withExtension: "json") else {
            AppLog.data.fault("""
                DanceHalls.json NOT FOUND in app bundle (bundle path: \(Bundle.main.bundlePath, privacy: .public)). \
                Fix: select DanceHalls.json in Xcode's navigator, open the File Inspector, and check \
                Target Membership → WesternDanceStudio.
                """)
            return DanceHallDatabase(lastUpdated: "", venues: [])
        }
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode(DanceHallDatabase.self, from: data)
            AppLog.data.info("Loaded \(decoded.venues.count, privacy: .public) venues from bundle (updated \(decoded.lastUpdated, privacy: .public))")
            return decoded
        } catch {
            AppLog.data.error("DanceHalls.json decode failed: \(error.localizedDescription, privacy: .public)")
            return DanceHallDatabase(lastUpdated: "", venues: [])
        }
    }

    private static func loadCached() -> DanceHallDatabase? {
        guard FileManager.default.fileExists(atPath: cachedVenueURL.path),
              let data = try? Data(contentsOf: cachedVenueURL),
              let decoded = try? JSONDecoder().decode(DanceHallDatabase.self, from: data)
        else { return nil }
        return decoded
    }

    /// Returns true when `candidate` has a strictly later lastUpdated date than `current`.
    private static func isNewer(_ candidate: DanceHallDatabase, than current: DanceHallDatabase) -> Bool {
        candidate.lastUpdated > current.lastUpdated  // ISO-8601 string compare works for YYYY-MM-DD
    }

    // MARK: - Background remote fetch

    private func fetchRemoteIfNewer() async {
        do {
            let (data, response) = try await URLSession.shared.data(from: remoteVenueURL)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { return }
            let remote = try JSONDecoder().decode(DanceHallDatabase.self, from: data)
            guard Self.isNewer(remote, than: database) else {
                AppLog.data.info("Remote venue data is not newer (\(remote.lastUpdated, privacy: .public)) — keeping current")
                return
            }
            // Persist the cache and swap the live database.
            try? data.write(to: cachedVenueURL, options: .atomic)
            database = remote
            // Reset the lazy venuesByState so it's recomputed from the new data.
            _venuesByState = nil
            AppLog.data.info("Remote venue refresh: \(remote.venues.count, privacy: .public) venues (updated \(remote.lastUpdated, privacy: .public))")
        } catch {
            AppLog.data.debug("Remote venue fetch skipped: \(error.localizedDescription, privacy: .public)")
        }
    }

    #if DEBUG
    private static func warnIfStale(lastUpdated: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "UTC")
        guard let lastDate = formatter.date(from: lastUpdated) else {
            AppLog.data.error("Could not parse DanceHalls.lastUpdated '\(lastUpdated, privacy: .public)'")
            return
        }
        let ageInDays = Calendar.current.dateComponents([.day], from: lastDate, to: Date()).day ?? 0
        if ageInDays > 183 {
            AppLog.data.fault("""
                VENUE MASTER LIST IS STALE — last updated \(lastUpdated, privacy: .public) \
                (\(ageInDays, privacy: .public) days ago). Run scripts/audit_venues.py and update DanceHalls.json.
                """)
        }
    }
    #endif

    // MARK: - Accessors

    var allVenues: [DanceHall] { database.venues }
    var lastUpdated: String { database.lastUpdated }

    /// Venues grouped by state. Backed by a resettable cache so a remote refresh
    /// causes the next access to recompute rather than serving stale grouped data.
    private var _venuesByState: [(state: String, venues: [DanceHall])]?
    var venuesByState: [(state: String, venues: [DanceHall])] {
        if let cached = _venuesByState { return cached }
        let grouped = Dictionary(grouping: allVenues, by: { $0.state })
        let result = grouped.keys.sorted().map { state in
            let sorted = (grouped[state] ?? []).sorted {
                if $0.city == $1.city { return $0.name < $1.name }
                return $0.city < $1.city
            }
            return (state: state, venues: sorted)
        }
        _venuesByState = result
        return result
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
