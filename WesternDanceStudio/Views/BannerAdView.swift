import SwiftUI
import GoogleMobileAds

struct BannerAdView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> BannerViewController {
        BannerViewController()
    }

    func updateUIViewController(_ uiViewController: BannerViewController, context: Context) {}
}

final class BannerViewController: UIViewController {
    private var bannerView: BannerView?

    override func viewDidLoad() {
        super.viewDidLoad()
        let banner = BannerView(adSize: AdSizeBanner)
        // Test ID in Debug, real production ID in Release — see AdConfig.
        banner.adUnitID = AdConfig.bannerID
        banner.rootViewController = self
        banner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(banner)

        // ✅ FIX #15: Use Auto Layout and center the 320x50 banner instead of stretching.
        NSLayoutConstraint.activate([
            banner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            banner.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        banner.load(Request())
        bannerView = banner
    }
}
