import SwiftUI
import StoreKit

/// Reusable paywall footer: Upgrade button + Continue button + Restore link.
/// Used on the launch screen (for returning non-premium users) and on the
/// final page of the welcome screen (for first-time users).
///
/// Appearance is designed for placement over the warm sunset gradient — text
/// and buttons use white/cream tones for contrast.
struct PremiumPaywallFooter: View {
    @Bindable var iap: IAPManager
    /// Called when the user taps "Continue with Ads" or after a successful purchase.
    var onContinue: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            // "Upgrade to Premium" primary CTA
            Button {
                Task { await iap.purchaseRemoveAds() }
            } label: {
                HStack(spacing: 10) {
                    if iap.isPurchasing {
                        ProgressView()
                            .tint(WesternTheme.primaryDark)
                    } else {
                        Image(systemName: "sparkles")
                        Text(upgradeButtonTitle)
                    }
                }
                .font(.system(size: 16, weight: .bold, design: .serif))
                .foregroundStyle(WesternTheme.primaryDark)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(WesternTheme.cream)
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 3)
            }
            .disabled(iap.isPurchasing)

            // Secondary "no thanks" action
            Button {
                onContinue()
            } label: {
                Text("Continue with Ads")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.85))
                    .underline()
            }

            // Show error if purchase failed
            if let err = iap.lastError {
                Text(err)
                    .font(.caption)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.black.opacity(0.25))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            // Restore link — required by App Store review
            Button {
                Task { await iap.restorePurchases() }
            } label: {
                Text("Restore Purchase")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .onChange(of: iap.isPremium) { _, newValue in
            // Auto-dismiss once a purchase completes.
            if newValue { onContinue() }
        }
    }

    private var upgradeButtonTitle: String {
        if let product = iap.removeAdsProduct {
            return "Upgrade to Premium — \(product.displayPrice)"
        }
        return "Upgrade to Premium"
    }
}
