import Foundation

/// Centralized AdMob configuration. Flip `useTestAds` to swap all IDs at once,
/// so TestFlight/Debug builds don't accidentally serve real ads (which can get
/// your AdMob account flagged for invalid traffic).
enum AdConfig {
    /// TEST IDs — safe to use in development without risking account flags.
    /// These are Google's official public test IDs documented at
    /// https://developers.google.com/admob/ios/test-ads
    private enum Test {
        static let banner       = "ca-app-pub-3940256099942544/2934735716"
        static let interstitial = "ca-app-pub-3940256099942544/4411468910"
    }

    /// PRODUCTION IDs — real ad unit IDs created in AdMob Console.
    /// Note the slash (/) — these are ad unit IDs, not the app ID (which uses a tilde ~).
    private enum Prod {
        static let banner       = "ca-app-pub-1306237465756584/2991494021"
        static let interstitial = "ca-app-pub-1306237465756584/8746698213"
    }

    /// Automatically uses test ads in Debug builds, production ads in Release.
    /// Override by setting to `true` or `false` explicitly if needed.
    static var useTestAds: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }

    static var bannerID:       String { useTestAds ? Test.banner       : Prod.banner }
    static var interstitialID: String { useTestAds ? Test.interstitial : Prod.interstitial }
}
