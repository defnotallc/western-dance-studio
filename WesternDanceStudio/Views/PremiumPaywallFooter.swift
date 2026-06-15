import SwiftUI
import StoreKit

/// Reusable paywall footer: Upgrade button + Continue button + Restore link.
/// Used on the launch screen (returning non-premium users) and on the final
/// page of the welcome screen (first-time users). Designed for white backgrounds.
struct PremiumPaywallFooter: View {
    @Bindable var iap: IAPManager
    /// Called when the user taps "Continue with Ads" or after a successful purchase.
    var onContinue: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            // Primary CTA — brown fill
            Button {
                Task { await iap.purchaseRemoveAds() }
            } label: {
                HStack(spacing: 8) {
                    if iap.isPurchasing {
                        ProgressView().tint(.white)
                    } else {
                        Text(upgradeButtonTitle)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                    }
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(WesternTheme.primary, in: RoundedRectangle(cornerRadius: 14))
            }
            .disabled(iap.isPurchasing)

            // Secondary — light gray fill
            Button {
                onContinue()
            } label: {
                Text("Continue with Ads")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(.systemGray5), in: RoundedRectangle(cornerRadius: 14))
            }

            // Error
            if let err = iap.lastError {
                Text(err)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 8))
            }

            // Restore — required by App Store review
            Button {
                Task { await iap.restorePurchases() }
            } label: {
                Text("Restore Previous Purchase")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 2)
        }
        .onChange(of: iap.isPremium) { _, newValue in
            if newValue { onContinue() }
        }
    }

    private var upgradeButtonTitle: String {
        if let product = iap.removeAdsProduct {
            return "Remove Ads — \(product.displayPrice)"
        }
        return "Remove Ads"
    }
}
