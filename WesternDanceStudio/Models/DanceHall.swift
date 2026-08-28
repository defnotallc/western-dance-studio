import Foundation
import CoreLocation

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
