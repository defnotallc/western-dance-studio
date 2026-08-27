import Foundation
import Observation
import UIKit
import UserMessagingPlatform
import AppTrackingTransparency
import GoogleMobileAds

/// Owns the full UMP → ATT → SDK startup sequence.
///
/// Call `gatherConsentAndInitializeAds()` once at app launch (from a `.task`
/// modifier on the root view). Every ad surface must gate on `adsInitialized`
/// before attempting to load or show an ad.
///
/// Order is mandatory:
///   1. requestConsentInfoUpdate  — fetch latest consent status from Google
///   2. presentConsentFormIfNeeded — show GDPR form to EEA/UK/CH users
///   3. requestATT                — Apple tracking prompt (after UMP)
///   4. startMobileAdsSDK         — MobileAds.shared.start() if canRequestAds
///   5. adsInitialized = true     — unconditional, so the app never hangs
@Observable
@MainActor
final class ConsentManager {
    static let shared = ConsentManager()

    /// True for EEA/UK/CH users — drives visibility of "Ad Preferences" button.
    private(set) var privacyOptionsRequired: Bool = false

    /// True once the UMP + ATT + SDK sequence completes. Gate every ad surface
    /// on this flag to prevent loading ads before the SDK has started.
    private(set) var adsInitialized: Bool = false

    private init() {}

    // MARK: - Main entry point

    func gatherConsentAndInitializeAds() async {
        do {
            try await requestConsentInfoUpdate()
            try await presentConsentFormIfNeeded()
        } catch {
            AppLog.consent.error("Consent flow error: \(error.localizedDescription, privacy: .public)")
        }

        // Set these even if consent errored — app must not hang.
        privacyOptionsRequired = ConsentInformation.shared.privacyOptionsRequirementStatus == .required
        await requestATT()
        startMobileAdsSDK()
        adsInitialized = true
    }

    /// Present the GDPR privacy options form so the user can change their choice.
    /// Only call when `privacyOptionsRequired == true`.
    func presentPrivacyOptionsForm() async {
        guard let rootVC = UIApplication.topViewController() else { return }
        do {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                ConsentForm.presentPrivacyOptionsForm(from: rootVC) { error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume()
                    }
                }
            }
        } catch {
            AppLog.consent.error("Privacy options form error: \(error.localizedDescription, privacy: .public)")
        }
        // Refresh status in case the user changed their preference.
        privacyOptionsRequired = ConsentInformation.shared.privacyOptionsRequirementStatus == .required
    }

    // MARK: - Private steps

    private func requestConsentInfoUpdate() async throws {
        let parameters = RequestParameters()
        #if DEBUG
        let debugSettings = DebugSettings()
        // Set the SIMULATE_EEA=1 environment variable (Scheme → Run → Arguments)
        // to simulate an EEA user and trigger the GDPR consent form locally.
        if ProcessInfo.processInfo.environment["SIMULATE_EEA"] == "1" {
            debugSettings.geography = .EEA
        }
        parameters.debugSettings = debugSettings
        #endif
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            ConsentInformation.shared.requestConsentInfoUpdate(with: parameters) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }

    private func presentConsentFormIfNeeded() async throws {
        guard let rootVC = UIApplication.topViewController() else { return }
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            ConsentForm.loadAndPresentIfRequired(from: rootVC) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }

    /// Must be called AFTER UMP form is dismissed.
    private func requestATT() async {
        _ = await ATTrackingManager.requestTrackingAuthorization()
    }

    /// Starts the GMA SDK. `canRequestAds` is true even when the user declines
    /// personalized ads — the SDK will serve contextual ads instead.
    private func startMobileAdsSDK() {
        guard ConsentInformation.shared.canRequestAds else { return }
        MobileAds.shared.start()
    }

    // MARK: - Debug

    #if DEBUG
    /// Clears all UMP state so the consent form appears again on next launch.
    func resetForTesting() {
        ConsentInformation.shared.reset()
    }
    #endif
}
