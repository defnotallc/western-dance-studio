import UIKit

extension UIApplication {
    /// Returns the topmost presented view controller in the active foreground
    /// scene. Used by ConsentManager and AdManager to find a valid presenter
    /// for modal UMP forms and interstitial ads.
    @MainActor
    static func topViewController() -> UIViewController? {
        guard
            let scene = UIApplication.shared.connectedScenes
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
