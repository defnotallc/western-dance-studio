import SwiftUI

// MARK: - Western Theme
// Centralized design system for a subtle, polished western aesthetic.

enum WesternTheme {

    // MARK: Colors (warm leather / saloon palette)

    static let primary = Color(red: 0.78, green: 0.38, blue: 0.14)          // burnt orange / saddle leather
    static let primaryDark = Color(red: 0.55, green: 0.25, blue: 0.08)      // dark leather
    static let accent = Color(red: 0.90, green: 0.72, blue: 0.35)           // vintage gold / brass
    static let cream = Color(red: 0.98, green: 0.94, blue: 0.86)            // aged paper
    static let rustRed = Color(red: 0.60, green: 0.25, blue: 0.20)          // barn red
    static let denimBlue = Color(red: 0.30, green: 0.40, blue: 0.55)        // worn denim
    static let sagebrush = Color(red: 0.55, green: 0.60, blue: 0.45)        // sage / prairie green

    // Backgrounds that auto-adapt to light/dark
    static var cardBackground: Color {
        Color(uiColor: .secondarySystemGroupedBackground)
    }

    // Fonts — use rounded design for warmth; serif for headlines/display
    static func displayFont(size: CGFloat, weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight, design: .serif)
    }

    static func headlineFont(size: CGFloat, weight: Font.Weight = .semibold) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }

    // MARK: - Navigation Bar Appearance

    /// Configures a consistent themed look for navigation bar titles across every tab.
    /// Uses the same serif font + dark leather color as the "Howdy Partner!" banner on
    /// the Start Here tab, so navigation titles feel visually unified.
    /// Call once at app launch.
    static func configureNavigationBarAppearance() {
        let primaryDarkUI = UIColor(red: 0.55, green: 0.25, blue: 0.08, alpha: 1.0)

        // Large title — bold serif
        let largeTitleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 32, weight: .heavy).withSerifDesign(),
            .foregroundColor: primaryDarkUI
        ]
        // Inline title — smaller serif
        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 17, weight: .bold).withSerifDesign(),
            .foregroundColor: primaryDarkUI
        ]

        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.largeTitleTextAttributes = largeTitleAttrs
        appearance.titleTextAttributes = titleAttrs

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }
}

// Helper: apply serif design to UIFont (mirrors SwiftUI's Font.system design: .serif)
private extension UIFont {
    func withSerifDesign() -> UIFont {
        guard let descriptor = self.fontDescriptor.withDesign(.serif) else { return self }
        return UIFont(descriptor: descriptor, size: 0)
    }
}

// MARK: - Reusable Decorative Views

/// A subtle horizontal divider with a star in the middle — classic western poster touch.
struct WesternDivider: View {
    var tint: Color = WesternTheme.primary

    var body: some View {
        HStack(spacing: 8) {
            line
            Image(systemName: "star.fill")
                .font(.caption2)
                .foregroundStyle(tint)
            line
        }
        .padding(.vertical, 4)
    }

    private var line: some View {
        Rectangle()
            .fill(tint.opacity(0.4))
            .frame(height: 1)
    }
}

/// A card container with subtle leather-colored border and warm background.
struct WesternCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(WesternTheme.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(WesternTheme.primary.opacity(0.25), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
    }
}

/// A simple banner with a warm gradient — useful for hero sections.
struct WesternBanner<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(
                LinearGradient(
                    colors: [WesternTheme.primary.opacity(0.20), WesternTheme.accent.opacity(0.15)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

// MARK: - Animated Cowboy

/// Professional hand-illustrated cowboy (from Assets.xcassets) with a subtle
/// "howdy" nodding animation — gentle sway + scale pulse for friendliness.
/// A section header styled like a western poster — serif with decorative rules.
struct WesternSectionHeader: View {
    let title: String
    var subtitle: String? = nil

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(WesternTheme.displayFont(size: 22))
                .foregroundStyle(WesternTheme.primaryDark)
            if let subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            WesternDivider()
        }
        .frame(maxWidth: .infinity)
    }
}

/// A difficulty indicator drawn as 10 filled/empty stars (one per difficulty point).
struct DifficultyStars: View {
    let difficulty: Int   // 1-10
    var size: CGFloat = 10

    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...10, id: \.self) { i in
                Image(systemName: i <= difficulty ? "star.fill" : "star")
                    .font(.system(size: size))
                    .foregroundStyle(i <= difficulty ? WesternTheme.primary : Color.gray.opacity(0.35))
            }
        }
    }
}

// MARK: - Haptics

/// Light wrapper around UIFeedbackGenerator for consistent haptic feedback across the app.
enum Haptics {
    /// A light tap feedback — use for button taps and selections (toggle favorite, tab change, etc.)
    @MainActor
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }

    /// Impact feedback — use for important actions (starting/stopping metronome, submitting search).
    @MainActor
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }

    /// Notification feedback — for success/failure messages.
    @MainActor
    static func notify(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
}

// MARK: - Debounced search helper

extension View {
    /// Debounces `source` into `destination` after `delay`.
    /// The `.task(id:)` cancels the sleep automatically when `source` changes,
    /// so only the final value after the user stops typing is committed.
    func debounced(
        source: Binding<String>,
        into destination: Binding<String>,
        delay: Duration = .milliseconds(250)
    ) -> some View {
        self.task(id: source.wrappedValue) {
            do {
                try await Task.sleep(for: delay)
                destination.wrappedValue = source.wrappedValue
            } catch {}
        }
    }
}
