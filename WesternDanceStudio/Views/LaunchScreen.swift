import SwiftUI
import StoreKit

/// Branded launch screen for returning users. Two modes:
///   - Premium user: auto-dismisses after a short duration (plain splash)
///   - Non-premium: scrollable paywall with feature highlights + Upgrade / Continue buttons
///
/// First-time users NEVER see this screen — they go straight into WelcomeView.
struct LaunchScreenView: View {
    @Bindable var iap: IAPManager
    var onDismiss: () -> Void

    var body: some View {
        if iap.isPremium {
            premiumSplash
        } else {
            paywallSplash
        }
    }

    private var premiumSplash: some View {
        ZStack {
            WesternSunsetGradient()
            VStack(spacing: 10) {
                Image("Cowboy")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 90, maxHeight: 90)
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                    .accessibilityHidden(true)
                Text("Western Dance Studio")
                    .font(.system(size: 28, weight: .heavy, design: .serif))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                Text("Welcome back")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.85))
            }
        }
        .ignoresSafeArea()
    }

    private var paywallSplash: some View {
        ScrollView {
            VStack(spacing: 0) {
                headerSection

                featuresSection
                    .padding(.horizontal, 28)
                    .padding(.top, 20)

                Divider()
                    .padding(.horizontal, 28)
                    .padding(.top, 16)

                supportSection
                    .padding(.horizontal, 28)
                    .padding(.top, 16)
                    .padding(.bottom, 28)
            }
        }
        // Extend the scroll view to fill behind the status bar so the header
        // gradient reaches the top edge. Content inside headerSection uses
        // .safeAreaPadding(.top) to stay below the status bar.
        .ignoresSafeArea(edges: .top)
        .background(Color(.systemBackground))
        .task { await iap.loadProducts() }
    }

    // MARK: - Header

    private var headerSection: some View {
        ZStack {
            WesternSunsetGradient()
            VStack(spacing: 6) {
                Spacer(minLength: 20)

                Image("Cowboy")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 72, maxHeight: 72)
                    .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 4)
                    .accessibilityHidden(true)

                Text("Western Dance Studio")
                    .font(.system(size: 24, weight: .heavy, design: .serif))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)

                Text("Your complete guide to country dancing")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.88))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                Spacer(minLength: 20)
            }
            // Push text content below the status bar while the gradient fills all the way up.
            .safeAreaPadding(.top)
        }
        .frame(minHeight: 180)
    }

    // MARK: - Feature Bullets

    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            featureRow(
                icon: "figure.dance",
                color: WesternTheme.primary,
                title: "20+ Dances",
                detail: "Two-Step, Waltz, Line Dancing, West Coast Swing & more"
            )
            featureRow(
                icon: "list.bullet.clipboard.fill",
                color: .blue,
                title: "Structured Curriculum",
                detail: "Progressive modules from first steps to floor-ready confidence"
            )
            featureRow(
                icon: "exclamationmark.triangle.fill",
                color: .orange,
                title: "Common Mistakes Guide",
                detail: "25 beginner errors explained — and exactly how to fix them"
            )
            featureRow(
                icon: "wifi.slash",
                color: .secondary,
                title: "100% Offline",
                detail: "No account, no internet required — all content ships with the app"
            )
        }
    }

    private func featureRow(icon: String, color: Color, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 30)
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.weight(.bold))
                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
    }

    // MARK: - Support / Paywall

    private var supportSection: some View {
        VStack(spacing: 12) {
            Text("Support Western Dance Studio")
                .font(.title3.weight(.bold))
                .multilineTextAlignment(.center)

            Text("Remove all ads with a one-time purchase. Helps keep the app updated and ad-free forever.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            PremiumPaywallFooter(iap: iap, onContinue: onDismiss)

            Text("All content is 100% offline. No account required.")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
    }
}

/// The shared warm sunset gradient used on the launch screen and on the final
/// welcome-flow page, so both feel like the same visual moment.
struct WesternSunsetGradient: View {
    var body: some View {
        LinearGradient(
            colors: [
                WesternTheme.primary.opacity(0.95),
                WesternTheme.primary.opacity(0.70),
                Color(red: 0.35, green: 0.20, blue: 0.12)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

#Preview("Non-Premium") {
    LaunchScreenView(iap: IAPManager.shared, onDismiss: {})
}
