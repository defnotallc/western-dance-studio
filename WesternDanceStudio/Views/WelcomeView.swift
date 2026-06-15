import SwiftUI

/// Full-screen welcome shown on the user's first app launch.
/// Redesigned for a polished western aesthetic — layered gradient, serif typography,
/// themed icons with accent ornamentation, and subtle decorative elements.
struct WelcomeView: View {
    @Binding var isPresented: Bool
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome: Bool = false
    @State private var iap = IAPManager.shared
    @State private var page = 0

    private static let pages: [WelcomePage] = [
        WelcomePage(
            icon: "star.fill",
            title: "Howdy, Partner",
            body: "Welcome to Western Dance Studio — your trail guide for country and western partner dances and line dances."
        ),
        WelcomePage(
            icon: "graduationcap.fill",
            title: "A Clear Learning Path",
            body: "Eight progressive modules take you from beat-counting and floor safety all the way through Two-Step, line dances, and swing — at your own pace."
        ),
        WelcomePage(
            icon: "exclamationmark.shield.fill",
            title: "Safety First, Always",
            body: "Country dancing has a code: consent at every step, counterclockwise floor traffic, and technique that communicates — never forces. We cover it all before you step out."
        ),
        WelcomePage(
            icon: "mappin.and.ellipse",
            title: "Find Your Honky Tonk",
            body: "Discover dance halls near you — search by zip code to find the nearest boots on the floor."
        ),
    ]

    /// The paywall page is always last and follows the intro pages.
    /// Total pages = intro pages + 1 paywall page.
    private var totalPages: Int { Self.pages.count + 1 }
    private var isOnPaywallPage: Bool { page == Self.pages.count }

    var body: some View {
        ZStack {
            // Intro pages use the western gradient background.
            // The paywall page manages its own background (white + gradient header).
            if !isOnPaywallPage {
                westernBackground
            }

            VStack(spacing: 0) {
                TabView(selection: $page) {
                    ForEach(Array(Self.pages.enumerated()), id: \.offset) { index, item in
                        welcomePageView(item)
                            .tag(index)
                    }
                    paywallPage
                        .tag(Self.pages.count)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // Footer: indicator + Next button only on intro pages.
                // Paywall page has its own CTAs.
                if !isOnPaywallPage {
                    pageIndicator
                        .padding(.bottom, 24)

                    advanceButton
                        .padding(.horizontal, 32)
                        .padding(.bottom, 40)
                }
            }
        }
        .interactiveDismissDisabled()
        .animation(.easeInOut(duration: 0.3), value: isOnPaywallPage)
        .task {
            // Preload the Remove Ads product so the paywall shows price immediately
            // when the user swipes to the last page.
            await iap.loadProducts()
        }
    }

    // MARK: - Layered western background

    private var westernBackground: some View {
        ZStack {
            // Base sunset gradient — from cream sky to burnt horizon
            LinearGradient(
                colors: [
                    WesternTheme.cream,
                    WesternTheme.cream.opacity(0.85),
                    WesternTheme.accent.opacity(0.35),
                    WesternTheme.primary.opacity(0.55),
                    WesternTheme.primaryDark.opacity(0.70)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Distant rolling-hills silhouette at the bottom
            GeometryReader { geo in
                Path { path in
                    let w = geo.size.width
                    let h = geo.size.height
                    let baseY = h * 0.78
                    path.move(to: CGPoint(x: 0, y: h))
                    path.addLine(to: CGPoint(x: 0, y: baseY))
                    path.addCurve(
                        to: CGPoint(x: w * 0.5, y: baseY - 40),
                        control1: CGPoint(x: w * 0.15, y: baseY - 25),
                        control2: CGPoint(x: w * 0.32, y: baseY - 55)
                    )
                    path.addCurve(
                        to: CGPoint(x: w, y: baseY + 10),
                        control1: CGPoint(x: w * 0.68, y: baseY - 20),
                        control2: CGPoint(x: w * 0.85, y: baseY + 30)
                    )
                    path.addLine(to: CGPoint(x: w, y: h))
                    path.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        colors: [
                            WesternTheme.primaryDark.opacity(0.55),
                            WesternTheme.primaryDark.opacity(0.85)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
            .ignoresSafeArea()

            // Sun halo — soft circle behind the icon area
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            WesternTheme.accent.opacity(0.45),
                            WesternTheme.accent.opacity(0.0)
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 220
                    )
                )
                .frame(width: 440, height: 440)
                .offset(y: -130)
                .blur(radius: 8)
        }
    }

    // MARK: - Page content

    @ViewBuilder
    private func welcomePageView(_ item: WelcomePage) -> some View {
        VStack(spacing: 32) {
            Spacer(minLength: 40)

            themedIcon(symbol: item.icon)

            VStack(spacing: 18) {
                ornamentalDivider
                    .frame(width: 140)

                Text(item.title)
                    .font(.system(size: 38, weight: .heavy, design: .serif))
                    .foregroundStyle(WesternTheme.primaryDark)
                    .multilineTextAlignment(.center)
                    .shadow(color: WesternTheme.cream.opacity(0.5), radius: 2, x: 0, y: 1)
                    .padding(.horizontal, 24)

                Text(item.body)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundStyle(WesternTheme.primaryDark.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .padding(.horizontal, 36)
            }

            Spacer()
            Spacer()
        }
    }

    // Double-ruled ornamental divider — evokes a wanted poster / saloon sign
    private var ornamentalDivider: some View {
        HStack(spacing: 8) {
            Rectangle()
                .fill(WesternTheme.primary.opacity(0.6))
                .frame(height: 1)
            Image(systemName: "diamond.fill")
                .font(.system(size: 8))
                .foregroundStyle(WesternTheme.primary)
            Rectangle()
                .fill(WesternTheme.primary.opacity(0.6))
                .frame(height: 1)
        }
    }

    // Themed icon with ornamental sheriff-badge-esque framing
    private func themedIcon(symbol: String) -> some View {
        ZStack {
            // Outer ring
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [
                            WesternTheme.primary,
                            WesternTheme.primaryDark
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 4
                )
                .frame(width: 170, height: 170)

            // Inner ring
            Circle()
                .stroke(WesternTheme.primary.opacity(0.35), lineWidth: 1)
                .frame(width: 148, height: 148)

            // Filled backing
            Circle()
                .fill(WesternTheme.cream)
                .frame(width: 142, height: 142)
                .shadow(color: WesternTheme.primaryDark.opacity(0.25), radius: 10, x: 0, y: 4)

            // The symbol itself
            Image(systemName: symbol)
                .font(.system(size: 64, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            WesternTheme.primary,
                            WesternTheme.primaryDark
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            // Four star accents at cardinal points — sheriff badge feel
            ForEach(0..<4, id: \.self) { i in
                Image(systemName: "star.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(WesternTheme.primary)
                    .offset(y: -85)
                    .rotationEffect(.degrees(Double(i) * 90))
            }
        }
    }

    // Custom page dots — larger and themed, now covering all pages including paywall
    private var pageIndicator: some View {
        HStack(spacing: 10) {
            ForEach(0..<totalPages, id: \.self) { index in
                Capsule()
                    .fill(index == page ? WesternTheme.primary : WesternTheme.primary.opacity(0.3))
                    .frame(width: index == page ? 24 : 8, height: 8)
                    .animation(.spring(response: 0.3), value: page)
            }
        }
    }

    // Advance / Next button — only shown on intro pages.
    // The paywall page has its own CTAs.
    private var advanceButton: some View {
        Button {
            advance()
        } label: {
            HStack(spacing: 10) {
                Text(page == Self.pages.count - 1 ? "Continue" : "Next")
                    .font(.system(size: 17, weight: .bold, design: .serif))
                Image(systemName: "arrow.right")
                    .font(.system(size: 16, weight: .bold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                LinearGradient(
                    colors: [WesternTheme.primary, WesternTheme.primaryDark],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .clipShape(Capsule())
            .shadow(color: WesternTheme.primaryDark.opacity(0.4), radius: 10, x: 0, y: 4)
            .overlay(
                Capsule()
                    .stroke(WesternTheme.cream.opacity(0.3), lineWidth: 1)
            )
        }
    }

    private func advance() {
        Haptics.selection()
        // Last intro page → swipe to the paywall page. Paywall buttons handle dismiss.
        withAnimation { page += 1 }
    }

    // MARK: - Paywall page (final welcome page)

    /// Final page of the welcome flow. Visually matches the launch screen that
    /// returning non-premium users see — same cowboy art, sunset gradient,
    /// and paywall footer buttons.
    private var paywallPage: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Gradient header — matches LaunchScreenView
                ZStack {
                    WesternSunsetGradient()
                    VStack(spacing: 10) {
                        Spacer(minLength: 40)
                        Image("Cowboy")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 100, maxHeight: 100)
                            .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 5)
                            .accessibilityHidden(true)
                        Text("Western Dance Studio")
                            .font(.system(size: 28, weight: .heavy, design: .serif))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                        Text("Your complete guide to country dancing")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.88))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        Spacer(minLength: 36)
                    }
                }
                .frame(minHeight: 240)

                // Features
                VStack(alignment: .leading, spacing: 20) {
                    paywallFeatureRow(icon: "figure.dance",              color: WesternTheme.primary, title: "20+ Dances",             detail: "Two-Step, Waltz, Line Dancing, West Coast Swing & more")
                    paywallFeatureRow(icon: "list.bullet.clipboard.fill", color: .blue,               title: "Structured Curriculum",  detail: "Progressive modules from first steps to floor-ready confidence")
                    paywallFeatureRow(icon: "exclamationmark.triangle.fill", color: .orange,          title: "Common Mistakes Guide",  detail: "25 beginner errors explained — and exactly how to fix them")
                    paywallFeatureRow(icon: "wifi.slash",                color: .secondary,           title: "100% Offline",           detail: "No account, no internet required — all content ships with the app")
                }
                .padding(.horizontal, 28)
                .padding(.top, 28)

                Divider()
                    .padding(.horizontal, 28)
                    .padding(.top, 24)

                // Support section
                VStack(spacing: 16) {
                    Text("Support Western Dance Studio")
                        .font(.title3.weight(.bold))
                        .multilineTextAlignment(.center)
                    Text("Remove all ads with a one-time purchase. Helps keep the app updated and ad-free forever.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    PremiumPaywallFooter(iap: iap, onContinue: finishWelcome)
                    Text("All content is 100% offline. No account required.")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 28)
                .padding(.top, 24)
                .padding(.bottom, 48)
            }
        }
        .background(Color(.systemBackground))
    }

    private func paywallFeatureRow(icon: String, color: Color, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 30)
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.subheadline.weight(.bold))
                Text(detail).font(.subheadline).foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
    }

    private func finishWelcome() {
        hasSeenWelcome = true
        isPresented = false
    }

    private struct WelcomePage {
        let icon: String
        let title: String
        let body: String
    }
}

#Preview {
    @Previewable @State var presented = true
    return WelcomeView(isPresented: $presented)
}
