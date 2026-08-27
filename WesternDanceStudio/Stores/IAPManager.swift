import SwiftUI
import StoreKit

/// Handles the one-time "Remove Ads" non-consumable in-app purchase.
///
/// Setup required in App Store Connect:
///   1. After Developer Program enrollment, create the app record
///   2. Features → In-App Purchases → +
///   3. Type: Non-Consumable
///   4. Reference Name: "Remove Ads"
///   5. Product ID: exactly `com.defnota.WesternDanceStudio.removeAds`
///   6. Price: Tier 5 ($4.99 USD)
///   7. Display Name: "Remove Ads"
///   8. Description: "Permanently removes all banner and interstitial ads."
///
/// Once created, StoreKit will serve this product via the code below.
@Observable
@MainActor
final class IAPManager {
    static let shared = IAPManager()

    /// Single StoreKit product identifier. Keep in sync with App Store Connect.
    ///
    /// Note: the prefix here is "com.defnota" while the app bundle ID uses
    /// "com.defnotallc". This is intentional — the product was registered in
    /// App Store Connect before the bundle ID was finalised. Do NOT change it;
    /// existing purchasers' entitlements are bound to this exact string.
    static let removeAdsProductID = "com.defnota.WesternDanceStudio.removeAds"

    /// True once the user has purchased Remove Ads (or restored on a new device).
    /// Persists across launches via UserDefaults + verified transaction replay.
    private(set) var isPremium: Bool = false

    /// Loaded product for display (title, localized price, etc.). Nil until loadProducts() succeeds.
    private(set) var removeAdsProduct: Product?

    /// True while a purchase or restore is in flight — use for button spinners.
    private(set) var isPurchasing: Bool = false

    /// The last user-visible error from a purchase or restore attempt.
    private(set) var lastError: String?

    private enum Keys {
        static let isPremium = "IAPManager.isPremium"
    }

    private init() {
        // Read cached purchased state optimistically so UI updates fast on cold launch.
        isPremium = UserDefaults.standard.bool(forKey: Keys.isPremium)

        #if DEBUG
        if ProcessInfo.processInfo.environment["DISABLE_ADS"] == "1" {
            isPremium = true
            Task { await loadProducts() }
            return
        }
        #endif

        // Start listening for transaction updates (e.g. cross-device purchase, refund,
        // family sharing). Task is detached from this instance's lifecycle on purpose;
        // IAPManager is a singleton that lives for the whole app, so no cleanup needed.
        Task { [weak self] in
            for await update in StoreKit.Transaction.updates {
                await self?.handle(transaction: update)
            }
        }

        // Verify purchase state against StoreKit on launch (in case UserDefaults is stale).
        Task { await refreshPurchaseState() }
    }

    // MARK: - Product loading

    /// Loads the Remove Ads product from the App Store.
    /// Returns true if the product is available afterwards. Safe to call repeatedly
    /// (e.g. as a retry when the user taps Upgrade before the initial preload finished
    /// or when a transient network/sandbox failure left the product unavailable).
    @discardableResult
    func loadProducts() async -> Bool {
        AppLog.iap.debug("loadProducts() requesting [\(Self.removeAdsProductID, privacy: .public)]")
        do {
            let products = try await Product.products(for: [Self.removeAdsProductID])
            if let product = products.first {
                removeAdsProduct = product
                AppLog.iap.info("Loaded product \(product.id, privacy: .public) at \(product.displayPrice, privacy: .public)")
                return true
            } else {
                AppLog.iap.error("Product list returned empty — check Paid Applications Agreement is active and the IAP was submitted with this app version")
                return false
            }
        } catch {
            AppLog.iap.error("Failed to load products: \(error.localizedDescription, privacy: .public)")
            return false
        }
    }

    // MARK: - Purchase

    func purchaseRemoveAds() async {
        AppLog.iap.debug("purchaseRemoveAds() called — product nil? \(self.removeAdsProduct == nil, privacy: .public)")
        isPurchasing = true
        lastError = nil
        defer { isPurchasing = false }

        // The button is always tappable. If the initial preload hasn't completed
        // or failed (e.g. transient network/sandbox issue), retry the fetch here
        // so the user gets either a real purchase sheet or a clear error — never
        // a silent, dead button.
        if removeAdsProduct == nil {
            await loadProducts()
        }
        guard let product = removeAdsProduct else {
            lastError = "We couldn’t reach the App Store to load the upgrade. Please check your connection and try again in a moment."
            return
        }

        do {
            AppLog.iap.debug("Calling product.purchase()")
            let result = try await product.purchase()
            AppLog.iap.info("product.purchase() returned")
            switch result {
            case .success(let verification):
                await handle(transaction: verification)
            case .userCancelled:
                break
            case .pending:
                lastError = "Your purchase is pending approval and will be completed shortly."
            @unknown default:
                break
            }
        } catch {
            AppLog.iap.error("Purchase threw: \(error.localizedDescription, privacy: .public)")
            lastError = "Purchase failed: \(error.localizedDescription)"
        }
    }

    // MARK: - Restore

    func restorePurchases() async {
        isPurchasing = true
        lastError = nil
        defer { isPurchasing = false }
        do {
            try await AppStore.sync()
            await refreshPurchaseState()
            if !isPremium {
                lastError = "No previous purchases were found on this Apple ID."
            }
        } catch StoreKitError.userCancelled {
            // User dismissed the authentication dialog — not an error.
        } catch {
            lastError = "Restore failed: \(error.localizedDescription)"
        }
    }

    // MARK: - Internal verification

    private func refreshPurchaseState() async {
        var purchased = false
        for await result in StoreKit.Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == Self.removeAdsProductID,
               transaction.revocationDate == nil {
                purchased = true
            }
        }
        setPremium(purchased)
    }

    private func handle(transaction verification: VerificationResult<StoreKit.Transaction>) async {
        switch verification {
        case .verified(let transaction):
            if transaction.productID == Self.removeAdsProductID,
               transaction.revocationDate == nil {
                setPremium(true)
            } else if transaction.revocationDate != nil {
                // Refunded or family-sharing revoked — turn ads back on
                setPremium(false)
            }
            await transaction.finish()
        case .unverified(let transaction, _):
            // Finishing an unverified transaction is irreversible — StoreKit removes
            // it from the queue permanently. This matches Apple's recommended sample
            // code: if verification genuinely failed (fraud/malformed JWS), leaving
            // it in the queue provides no recovery path. For transient failures the
            // user can recover via restorePurchases() → AppStore.sync().
            lastError = "This purchase could not be verified."
            await transaction.finish()
        }
    }

    private func setPremium(_ value: Bool) {
        isPremium = value
        UserDefaults.standard.set(value, forKey: Keys.isPremium)
    }
}
