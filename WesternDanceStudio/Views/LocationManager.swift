import SwiftUI
import CoreLocation

/// One-shot location manager. Requests WhenInUse authorization on first use,
/// then fires a single location update. Results are published as `lastCoordinate`.
///
/// Reuse the singleton — multiple views observe it without competing requests.
@Observable
@MainActor
final class LocationManager: NSObject, CLLocationManagerDelegate {

    static let shared = LocationManager()

    var lastCoordinate: CLLocationCoordinate2D?
    var isLocating: Bool = false
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var errorMessage: String?

    private let manager = CLLocationManager()
    private var pendingRequest = false

    private override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        authorizationStatus = manager.authorizationStatus
    }

    /// Request the user's current location. Asks for authorization if needed.
    func requestLocation() {
        errorMessage = nil
        switch manager.authorizationStatus {
        case .notDetermined:
            pendingRequest = true
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            startLocating()
        case .denied, .restricted:
            errorMessage = "Location access is off. Enable it in Settings → Privacy → Location Services."
        @unknown default:
            errorMessage = "Location unavailable."
        }
    }

    private func startLocating() {
        guard !isLocating else { return }
        isLocating = true
        manager.requestLocation()
    }

    // MARK: CLLocationManagerDelegate

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            authorizationStatus = manager.authorizationStatus
            if pendingRequest &&
               (manager.authorizationStatus == .authorizedWhenInUse ||
                manager.authorizationStatus == .authorizedAlways) {
                pendingRequest = false
                startLocating()
            } else if manager.authorizationStatus == .denied ||
                      manager.authorizationStatus == .restricted {
                pendingRequest = false
                isLocating = false
                errorMessage = "Location access is off. Enable it in Settings → Privacy → Location Services."
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager,
                                     didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        Task { @MainActor in
            lastCoordinate = loc.coordinate
            isLocating = false
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager,
                                     didFailWithError error: Error) {
        Task { @MainActor in
            isLocating = false
            if (error as? CLError)?.code == .denied {
                errorMessage = "Location access denied."
            } else {
                errorMessage = "Couldn't get location."
            }
        }
    }
}
