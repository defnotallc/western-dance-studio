import SwiftUI
import StoreKit

/// Branded launch screen for returning users. Two modes:
///   - Premium user: auto-dismisses after a short duration (plain splash)
///   - Non-premium: shows indefinite paywall with Upgrade / Continue-with-Ads buttons
///
/// First-time users NEVER see this screen — they go straight into WelcomeView,
/// which has its own final page that serves the same paywall role.
///
/// The parent view controls dismiss lifecycle via `onDismiss`.
struct LaunchScreenView: View {
    @Bindable var iap: IAPManager
    var onDismiss: () -> Void

    var body: some View {
        ZStack {
            WesternSunsetGradient()

            VStack(spacing: 28) {
                Spacer()

                Image("Cowboy")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 260, maxHeight: 260)
                    .shadow(color: .black.opacity(0.25), radius: 12, x: 0, y: 6)
                    .accessibilityLabel("Western Dance Studio mascot")

                VStack(spacing: 4) {
                    Text("Western")
                        .font(.system(size: 42, weight: .heavy, design: .serif))
                        .foregroundStyle(.white)
                    Text("Dance Studio")
                        .font(.system(size: 42, weight: .heavy, design: .serif))
                        .foregroundStyle(.white)
                }
                .multilineTextAlignment(.center)
                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)

                Text("Boot-scoot your way through country dances")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                Spacer()

                // Paywall for non-premium users only. Premium users get a
                // plain splash that auto-dismisses via the parent's timer.
                if !iap.isPremium {
                    PremiumPaywallFooter(iap: iap, onContinue: onDismiss)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 36)
                        .transition(.opacity)
                }
            }
            .padding(.horizontal, 24)
        }
        .task {
            await iap.loadProducts()
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
