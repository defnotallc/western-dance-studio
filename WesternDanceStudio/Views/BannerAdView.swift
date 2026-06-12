import SwiftUI
import GoogleMobileAds

struct BannerAdView: UIViewControllerRepresentable {
    /// Called on the main thread when the ad fails to load so the container
    /// can be collapsed and the 50 pt dead zone removed from the layout.
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

final class BannerViewController: UIViewController {
    private var bannerView: BannerView?
    private var adDelegate: (any BannerViewDelegate)?

    init(delegate: (any BannerViewDelegate)? = nil) {
        self.adDelegate = delegate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("use init(delegate:)") }

    override func viewDidLoad() {
        super.viewDidLoad()
        let banner = BannerView(adSize: AdSizeBanner)
        banner.adUnitID = AdConfig.bannerID
        banner.rootViewController = self
        banner.delegate = adDelegate
        banner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(banner)
        NSLayoutConstraint.activate([
            banner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            banner.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        banner.load(Request())
        bannerView = banner
    }
}
