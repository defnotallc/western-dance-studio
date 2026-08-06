import SwiftUI
import GoogleMobileAds

/// Fixed banner height in points — the standard AdMob minimum banner size
/// (`AdSizeBanner` is 320x50). Deliberately NOT using Google's "adaptive"
/// anchored banner sizes here: those are taller by design (50-150pt) to
/// improve fill/revenue, which works against keeping this strip minimal so
/// it never crowds the tab bar or in-page content. Full-width sizing below
/// recovers the fill-rate benefit adaptive sizing would otherwise provide,
/// without growing the height past this minimum.
let bannerAdHeight: CGFloat = 50

struct BannerAdView: UIViewControllerRepresentable {
    /// Called on the main thread when the ad fails to load so the container
    /// can be collapsed and the dead zone removed from the layout.
    var onAdFailed: () -> Void = {}

    func makeCoordinator() -> Coordinator { Coordinator(onAdFailed: onAdFailed) }

    func makeUIViewController(context: Context) -> BannerViewController {
        BannerViewController(delegate: context.coordinator)
    }

    func updateUIViewController(_ uiViewController: BannerViewController, context: Context) {}

    // MARK: - Coordinator

    final class Coordinator: NSObject, BannerViewDelegate {
        var onAdFailed: () -> Void
        init(onAdFailed: @escaping () -> Void) { self.onAdFailed = onAdFailed }

        func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
            // Delegate callbacks are delivered on the main thread by the SDK.
            onAdFailed()
        }
    }
}

// MARK: - BannerViewController

/// Hosts a single AdMob banner sized to exactly fill the available width at
/// a fixed, minimal height. The ad size is computed from the container's
/// actual laid-out width — not a hardcoded 320pt — so it looks correct
/// edge-to-edge on every device, iPad included, rather than appearing as a
/// small centered box with wasted space on either side.
final class BannerViewController: UIViewController {
    private var bannerView: BannerView?
    private var adDelegate: (any BannerViewDelegate)?

    /// The width we last requested an ad for. Reloading on every layout pass
    /// would waste ad requests (and risks AdMob policy issues around
    /// excessive reloading), so a fresh load only triggers when the width
    /// actually changes — e.g. a rotation — not on incidental relayout.
    private var lastRequestedWidth: CGFloat = 0

    init(delegate: (any BannerViewDelegate)? = nil) {
        self.adDelegate = delegate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("use init(delegate:)") }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let width = view.frame.width
        guard width > 0, abs(width - lastRequestedWidth) > 1 else { return }
        lastRequestedWidth = width
        loadOrResizeBanner(forWidth: width)
    }

    private func loadOrResizeBanner(forWidth width: CGFloat) {
        let size = adSizeFor(cgSize: CGSize(width: width, height: bannerAdHeight))

        if let banner = bannerView {
            banner.adSize = size
            banner.load(Request())
            return
        }

        let banner = BannerView(adSize: size)
        banner.adUnitID = AdConfig.bannerID
        banner.rootViewController = self
        banner.delegate = adDelegate
        banner.translatesAutoresizingMaskIntoConstraints = false
        // Defensive: never let ad content render outside its allotted strip,
        // regardless of what size a filled creative reports.
        banner.clipsToBounds = true
        view.addSubview(banner)

        NSLayoutConstraint.activate([
            banner.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            banner.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            banner.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            banner.heightAnchor.constraint(equalToConstant: bannerAdHeight),
        ])

        banner.load(Request())
        bannerView = banner
    }
}
