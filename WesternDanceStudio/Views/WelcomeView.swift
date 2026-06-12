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
            icon: "figure.dance",
            title: "Master Every Step",
            body: "From Texas Two-Step to Tush Push, every dance is broken down beat by beat with tempo and song recommendations."
        ),
        WelcomePage(
            icon: "metronome.fill",
            title: "Practice to the Beat",
            body: "A built-in metronome lets you slow it down and master the rhythm before you hit the dance floor."
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
            // Use different backgrounds for intro pages vs paywall page so the
            // paywall visually matches the launch screen for returning users.
            if isOnPaywallPage {
                WesternSunsetGradient()
            } else {
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
        VStack(spacing: 28) {
            Spacer()

            Image("Cowboy")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 220, maxHeight: 220)
                .shadow(color: .black.opacity(0.25), radius: 12, x: 0, y: 6)
                .accessibilityLabel("Western Dance Studio mascot")

            VStack(spacing: 4) {
                Text("Ready to Dance?")
                    .font(.system(size: 32, weight: .heavy, design: .serif))
                    .foregroundStyle(.white)

                Text("Support the app and get an ad-free experience, or continue with ads.")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.top, 4)
            }
            .multilineTextAlignment(.center)
            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)

            Spacer()

            PremiumPaywallFooter(iap: iap, onContinue: finishWelcome)
                .padding(.horizontal, 24)
                .padding(.bottom, 36)
        }
        .padding(.horizontal, 24)
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
