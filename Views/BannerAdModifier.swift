import SwiftUI

/// A reusable modifier that attaches a compliant AdMob banner to the bottom of
/// a view's content area. Applied per-view (not at the TabView level) so it
/// sits above the tab bar without overlapping the tab buttons, and so
/// individual views (like the map) can opt out entirely.
///
/// The banner appears immediately above the tab bar with a subtle divider
/// separating it from the app content — compliant with AdMob placement rules
/// while staying visually unobtrusive.
///
/// Usage:
/// ```
/// NavigationStack {
///     MyContent()
/// }
/// .withBannerAd()
/// ```
struct BannerAdModifier: ViewModifier {
    /// Direct read of the singleton — `@Observable` SwiftUI integration tracks
    /// this read and re-renders when `isPremium` changes.
    private var iap: IAPManager { IAPManager.shared }

    func body(content: Content) -> some View {
        // Capture the current premium state so we log it consistently within this render
        let premium = iap.isPremium

        #if DEBUG
        let _ = print("📺 BannerAdModifier render — isPremium=\(premium)")
        #endif

        return content
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if !premium {
                    VStack(spacing: 0) {
                        Divider()
                            .opacity(0.35)
                        BannerAdView()
                            .frame(height: 50)
                            .background(Color(.systemBackground))
                    }
                }
            }
    }
}

extension View {
    /// Attach a banner ad strip at the bottom of the view content, above the tab bar.
    func withBannerAd() -> some View {
        modifier(BannerAdModifier())
    }
}
