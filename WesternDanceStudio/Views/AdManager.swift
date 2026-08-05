import GoogleMobileAds
import SwiftUI

/// Centralized AdMob lifecycle.
/// - Banners are rendered inline by `BannerAdView`
/// - Interstitials are triggered after every N dance-detail "returns"
/// - Ad unit IDs come from `AdConfig` (test IDs in Debug, production in Release)
/// - All ad surfaces silently disable themselves when `IAPManager.isPremium` is true
@MainActor
final class AdManager {
    static let shared = AdManager()

    // MARK: - State

    private var interstitial: InterstitialAd?

    /// How many detail-view "returns" have happened in this session.
    /// An interstitial shows every `returnsPerInterstitial` returns.
    private var returnCount: Int = 0

    /// Minimum returns between interstitials. Tuned to 3 to increase impression
    /// volume without becoming disruptive (the 60s cooldown backs this up).
    private let returnsPerInterstitial: Int = 3

    /// Timestamp of the last interstitial presentation. We add a minimum
    /// cooldown so rapid navigation doesn't trigger back-to-back ads even
    /// if the counter hits the threshold twice quickly.
    private var lastInterstitialShownAt: Date?
    private let minimumInterstitialCooldown: TimeInterval = 60

    private init() {}

    // MARK: - Interstitial lifecycle

    /// Pre-loads an interstitial. Call once after ConsentManager.adsInitialized
    /// becomes true; subsequent loads are triggered internally after each show.
    func loadInterstitial() async {
        guard ConsentManager.shared.adsInitialized else { return }
        guard !IAPManager.shared.isPremium else { return }
        do {
            interstitial = try await InterstitialAd.load(
                with: AdConfig.interstitialID,
                request: Request()
            )
        } catch {
            AppLog.ads.error("Interstitial ad failed to load: \(error.localizedDescription, privacy: .public)")
        }
    }

    /// Call this when the user returns from any detail view (a dance detail,
    /// a venue detail, etc). After every `returnsPerInterstitial` returns
    /// (and respecting the cooldown), an interstitial is presented if one is
    /// ready.
    func recordDetailReturn() {
        guard ConsentManager.shared.adsInitialized else { return }
        guard !IAPManager.shared.isPremium else { return }
        returnCount += 1

        guard returnCount % returnsPerInterstitial == 0 else { return }

        // Respect cooldown
        if let last = lastInterstitialShownAt,
           Date().timeIntervalSince(last) < minimumInterstitialCooldown {
            return
        }

        showInterstitialIfReady()
    }

    private func showInterstitialIfReady() {
        guard !IAPManager.shared.isPremium else { return }
        guard let interstitial else {
            // Not ready yet — try again next cycle and preload
            Task { await loadInterstitial() }
            return
        }

        guard let rootVC = Self.currentRootViewController() else { return }

        interstitial.present(from: rootVC)
        lastInterstitialShownAt = Date()
        self.interstitial = nil

        // Preload the next one for later
        Task { await loadInterstitial() }
    }

    // MARK: - Root VC helper

    /// Finds the topmost view controller so the interstitial has a valid
    /// presenter. Works with SwiftUI-hosted UIKit scenes.
    private static func currentRootViewController() -> UIViewController? {
        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }),
              let window = scene.windows.first(where: { $0.isKeyWindow }) ?? scene.windows.first
        else { return nil }

        var vc = window.rootViewController
        while let presented = vc?.presentedViewController {
            vc = presented
        }
        return vc
    }
}
