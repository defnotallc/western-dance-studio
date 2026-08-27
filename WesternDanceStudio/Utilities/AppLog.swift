@_exported import os

/// Central `os.Logger` catalog for the app. One `Logger` per subsystem area,
/// all sharing the app's bundle ID as the OSLog subsystem so they group
/// together in Console.app / `log stream` filters.
///
/// Standard practice this follows: unified logging (os_log/Logger) instead of
/// `print()`, so output carries level (debug/info/error/fault), is
/// zero-cost when not being observed, redacts interpolated values as
/// `private` by default (opt into `.public` per-argument only for values that
/// are safe to see in a sysdiagnose), and is filterable per-category in
/// Console.app without recompiling.
///
/// Usage: `AppLog.iap.info("Purchase started for \(productID, privacy: .public)")`
enum AppLog {
    // Must match the app's bundle ID so Console.app / `log stream --predicate`
    // filters by subsystem work. Note: the IAP product ID uses "com.defnota"
    // (a different prefix) because it was registered that way in App Store Connect
    // before the bundle was finalized — do not change it.
    private static let subsystem = "com.defnotallc.WesternDanceStudio"

    static let cloudSync = Logger(subsystem: subsystem, category: "CloudSync")
    static let iap = Logger(subsystem: subsystem, category: "IAP")
    static let ads = Logger(subsystem: subsystem, category: "Ads")
    static let consent = Logger(subsystem: subsystem, category: "Consent")
    static let metronome = Logger(subsystem: subsystem, category: "Metronome")
    static let data = Logger(subsystem: subsystem, category: "Data")
    static let media = Logger(subsystem: subsystem, category: "Media")
}
