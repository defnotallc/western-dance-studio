import SwiftUI
import StoreKit

/// Sheet presented when the user taps "Remove Ads" in the More section.
/// Shows the StoreKit product info, handles purchase and restore, and
/// automatically dismisses on successful purchase.
struct RemoveAdsSheet: View {
    @Bindable var iap: IAPManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    // Header illustration
                    ZStack {
                        Circle()
                            .fill(WesternTheme.primary.opacity(0.15))
                            .frame(width: 120, height: 120)
                        Image(systemName: "sparkles")
                            .font(.system(size: 56))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [WesternTheme.primary, WesternTheme.primaryDark],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    }
                    .padding(.top, 20)

                    VStack(spacing: 12) {
                        Text("Remove Ads")
                            .font(.system(size: 28, weight: .heavy, design: .serif))
                            .foregroundStyle(WesternTheme.primaryDark)

                        Text("Enjoy Western Dance Studio without banner ads or interstitials — and support a small indie developer while you're at it.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }

                    // Benefits list
                    VStack(alignment: .leading, spacing: 12) {
                        benefit("No banner ads anywhere in the app")
                        benefit("No interstitial ads between screens")
                        benefit("One-time payment — no subscription")
                        benefit("Supports continued development")
                    }
                    .padding(.horizontal, 32)

                    // Purchase button
                    VStack(spacing: 12) {
                        Button {
                            Task { await iap.purchaseRemoveAds() }
                        } label: {
                            HStack {
                                if iap.isPurchasing {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text(purchaseButtonTitle)
                                        .font(.headline)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [WesternTheme.primary, WesternTheme.primaryDark],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                        }
                        .disabled(iap.isPurchasing)

                        Button("Restore Purchase") {
                            Task { await iap.restorePurchases() }
                        }
                        .font(.subheadline)
                        .foregroundStyle(WesternTheme.primary)
                        .disabled(iap.isPurchasing)

                        if let err = iap.lastError {
                            Text(err)
                                .font(.caption)
                                .foregroundStyle(.red)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                        }
                    }
                    .padding(.horizontal, 24)

                    Text("Payment will be charged to your Apple ID. This is a one-time purchase. No subscriptions.")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                }
            }
            .navigationTitle("Upgrade")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .onChange(of: iap.isPremium) { _, newValue in
                if newValue { dismiss() }
            }
        }
    }

    private var purchaseButtonTitle: String {
        if let product = iap.removeAdsProduct {
            return "Buy for \(product.displayPrice)"
        }
        return "Buy Remove Ads"
    }

    private func benefit(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(WesternTheme.primary)
                .font(.body)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.primary)
            Spacer()
        }
    }
}
