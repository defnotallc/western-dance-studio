import SwiftUI
import StoreKit

@main
struct WesternDanceStudioApp: App {
    @State private var store = DanceStore.shared
    @State private var iap = IAPManager.shared
    @State private var reviews = ReviewManager.shared
    @State private var consent = ConsentManager.shared
    @State private var practice = PracticeRequest.shared
    @State private var selectedTab: Int = AppTab.startHere.rawValue
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome: Bool = false
    @AppStorage("theme") private var theme: String = "system"
    @State private var showWelcome: Bool
    @State private var showSplash: Bool
    @Environment(\.requestReview) private var requestReview

    init() {
        // Apply themed serif fonts + leather color to every navigation bar title.
        WesternTheme.configureNavigationBarAppearance()

        // First-time users go straight into the welcome flow (which includes
        // the paywall on its final page). Returning users see the splash/paywall
        // at most once per calendar day to avoid repetitive friction.
        let firstLaunch = !UserDefaults.standard.bool(forKey: "hasSeenWelcome")
        let today = Calendar.current.ordinality(of: .day, in: .era, for: Date()) ?? 0
        let lastSplashDay = UserDefaults.standard.integer(forKey: "lastSplashDay")
        let showSplash = !firstLaunch && lastSplashDay != today
        if showSplash {
            UserDefaults.standard.set(today, forKey: "lastSplashDay")
        }
        // TN3211: @State is a macro in the iOS 27 SDK. Assign the property
        // directly; neither property declares an inline initial value, which
        // would otherwise take precedence and silently discard these values.
        self.showWelcome = firstLaunch
        self.showSplash = showSplash
    }

    var body: some Scene {
        WindowGroup {
            mainContent
                .preferredColorScheme(resolvedColorScheme)
            .task(id: iap.isPremium) {
                // Premium users get a plain 2s splash with no paywall.
                // Non-premium users see an indefinite paywall and dismiss manually.
                if iap.isPremium {
                    try? await Task.sleep(for: .milliseconds(2000))
                    if showSplash {
                        dismissSplash()
                    }
                }
            }
            .task {
                // Preload the Remove Ads product so the paywall shows the price immediately.
                await iap.loadProducts()
            }
            .task {
                // UMP consent → ATT → SDK start (order is mandatory).
                // adsInitialized is set true unconditionally so the app never hangs.
                await ConsentManager.shared.gatherConsentAndInitializeAds()
                await AdManager.shared.loadInterstitial()
            }
            .onChange(of: reviews.shouldPrompt) { _, prompt in
                if prompt {
                    requestReview()
                    reviews.didPrompt()
                }
            }
            // Routing is stored state, not a notification, so a request made
            // before this view existed (App Intent cold launch, widget tap) is
            // still honoured. Checked once at launch and on every change.
            .task { consumePendingTab() }
            .onChange(of: practice.pendingTab) { _, _ in consumePendingTab() }
            .onOpenURL { url in handleDeepLink(url) }
        }
    }

    private var resolvedColorScheme: ColorScheme? {
        WesternTheme.resolvedColorScheme(for: theme)
    }

    private func consumePendingTab() {
        guard let tab = practice.pendingTab else { return }
        selectedTab = tab.rawValue
        practice.pendingTab = nil
    }

    /// Handles `westerndance://practice?dance=<id>` from the Featured Dance
    /// widget. An unrecognised link, or one naming a dance no longer in the
    /// catalogue, is ignored rather than leaving the app half-routed.
    private func handleDeepLink(_ url: URL) {
        guard case .practice(let danceID)? = DeepLink(url: url),
              let dance = Dance.sampleDances.first(where: { $0.id == danceID })
        else {
            AppLog.data.error("Ignoring unrecognised deep link")
            return
        }
        practice.requestPractice(bpm: dance.bpm,
                                 pattern: dance.suggestedPattern,
                                 autoStart: false)
    }

    private func dismissSplash() {
        withAnimation(.easeOut(duration: 0.45)) {
            showSplash = false
        }
    }

    private var mainContent: some View {
        TabView(selection: $selectedTab) {
            BeginnerBootcampView(store: store, onOpenGlossary: { selectedTab = 4 })
                .withBannerAd()
                .tabItem { Label("Start Here", systemImage: "book") }
                .tag(0)

            DanceListView(store: store)
                .withBannerAd()
                .tabItem { Label("Dances", systemImage: "figure.dance") }
                .tag(1)

            FavoritesView(store: store)
                .withBannerAd()
                .tabItem { Label("Favorites", systemImage: "star.fill") }
                .tag(2)

            // Venues intentionally omits the banner — the map needs full-screen
            // real estate and the venue card at the bottom would conflict.
            DanceVenuesView()
                .tabItem { Label("Venues", systemImage: "map.fill") }
                .tag(3)

            GlossaryView()
                .withBannerAd()
                .tabItem { Label("Glossary", systemImage: "book.closed") }
                .tag(4)
        }
        .tabViewStyle(.sidebarAdaptable)
        // Reclaims vertical space in the long scrolling content views.
        .tabBarMinimizeBehavior(.onScrollDown)
        .tint(WesternTheme.primary)
        .fullScreenCover(isPresented: $showWelcome) {
            WelcomeView(isPresented: $showWelcome)
        }
        .fullScreenCover(isPresented: $showSplash) {
            LaunchScreenView(iap: iap, onDismiss: dismissSplash)
        }
    }
}
