#if DEBUG
import UIKit
import AVFoundation
import OSLog
import Darwin

/// Collects a plain-text diagnostics snapshot for bug reports.
/// Entirely compiled out in Release builds — no symbols or strings survive.
enum DiagnosticsCollector {

    static func generateReport() -> String {
        var lines: [String] = []

        let fmt = ISO8601DateFormatter()
        fmt.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        lines.append("Generated: \(fmt.string(from: Date()))")
        lines.append("")

        lines += appSection()
        lines += deviceSection()
        lines += displaySection()
        lines += accessibilitySection()
        lines += memorySection()
        lines += storageSection()
        lines += healthSection()
        lines += appStateSection()
        lines += logsSection()

        return lines.joined(separator: "\n")
    }

    // MARK: - App

    private static func appSection() -> [String] {
        let info = Bundle.main.infoDictionary ?? [:]
        let name    = (info["CFBundleDisplayName"] as? String)
                   ?? (info["CFBundleName"] as? String)
                   ?? "—"
        let version = info["CFBundleShortVersionString"] as? String ?? "—"
        let build   = info["CFBundleVersion"] as? String ?? "—"
        let bundle  = Bundle.main.bundleIdentifier ?? "—"
        return [
            "-- App --",
            "Name: \(name)",
            "Version: \(version) (build \(build))",
            "Bundle ID: \(bundle)",
            "Configuration: Debug",
            "",
        ]
    }

    // MARK: - Device

    private static func deviceSection() -> [String] {
        let env = ProcessInfo.processInfo.environment
        let isSimulator = env["SIMULATOR_MODEL_IDENTIFIER"] != nil
        let model: String
        if isSimulator {
            model = env["SIMULATOR_MODEL_IDENTIFIER"] ?? "unknown simulator"
        } else {
            var info = utsname()
            uname(&info)
            model = withUnsafeBytes(of: &info.machine) { rawPtr in
                let ptr = rawPtr.baseAddress!.assumingMemoryBound(to: CChar.self)
                return String(cString: ptr)
            }
        }
        let device = UIDevice.current
        let langs = Locale.preferredLanguages.joined(separator: ", ")
        return [
            "-- Device --",
            "Environment: \(isSimulator ? "Simulator" : "Physical device")",
            "Model: \(model)",
            "System: \(device.systemName) \(device.systemVersion)",
            "Locale: \(Locale.current.identifier)",
            "Preferred languages: \(langs)",
            "Timezone: \(TimeZone.current.identifier)",
            "",
        ]
    }

    // MARK: - Display

    private static func displaySection() -> [String] {
        let bounds = UIScreen.main.bounds
        let scale  = UIScreen.main.scale
        let w = Int(bounds.width)
        let h = Int(bounds.height)
        let pw = Int(bounds.width  * scale)
        let ph = Int(bounds.height * scale)
        let scaleStr = scale == scale.rounded() ? "@\(Int(scale))x" : "@\(scale)x"
        return [
            "-- Display --",
            "Screen (points): \(w)x\(h) pt \(scaleStr)",
            "Screen (pixels): \(pw)x\(ph) px",
            "",
        ]
    }

    // MARK: - Accessibility

    private static func accessibilitySection() -> [String] {
        let cat = UIApplication.shared.preferredContentSizeCategory
        let typeSize = humanReadableContentSize(cat)
        return [
            "-- Accessibility --",
            "Dynamic Type: \(typeSize)",
            "VoiceOver: \(UIAccessibility.isVoiceOverRunning)",
            "Reduce Motion: \(UIAccessibility.isReduceMotionEnabled)",
            "Reduce Transparency: \(UIAccessibility.isReduceTransparencyEnabled)",
            "Bold Text: \(UIAccessibility.isBoldTextEnabled)",
            "",
        ]
    }

    private static func humanReadableContentSize(_ cat: UIContentSizeCategory) -> String {
        switch cat {
        case .extraSmall:                        return "Extra Small (XS)"
        case .small:                             return "Small (S)"
        case .medium:                            return "Medium (M)"
        case .large:                             return "Large (default)"
        case .extraLarge:                        return "Extra Large (XL)"
        case .extraExtraLarge:                   return "Extra Extra Large (XXL)"
        case .extraExtraExtraLarge:              return "Extra Extra Extra Large (XXXL)"
        case .accessibilityMedium:               return "Accessibility Medium"
        case .accessibilityLarge:                return "Accessibility Large"
        case .accessibilityExtraLarge:           return "Accessibility Extra Large"
        case .accessibilityExtraExtraLarge:      return "Accessibility Extra Extra Large"
        case .accessibilityExtraExtraExtraLarge: return "Accessibility Extra Extra Extra Large"
        default:                                 return cat.rawValue
        }
    }

    // MARK: - Memory

    private static func memorySection() -> [String] {
        let resident = residentMemoryMB()
        let physical = ProcessInfo.processInfo.physicalMemory / 1024 / 1024
        let available = availableMemoryLine()
        return [
            "-- Memory --",
            "App resident: \(resident)",
            "Device physical: \(physical) MB",
            "Available to process: \(available)",
            "",
        ]
    }

    private static func residentMemoryMB() -> String {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size / MemoryLayout<integer_t>.size)
        let kr = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { ptr in
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), ptr, &count)
            }
        }
        guard kr == KERN_SUCCESS else { return "unavailable" }
        let mb = Double(info.resident_size) / 1_048_576
        return String(format: "%.1f MB", mb)
    }

    private static func availableMemoryLine() -> String {
        let env = ProcessInfo.processInfo.environment
        if env["SIMULATOR_MODEL_IDENTIFIER"] != nil {
            return "N/A (unreliable in Simulator)"
        }
        let bytes = os_proc_available_memory()
        let mb = Double(bytes) / 1_048_576
        return String(format: "%.1f MB", mb)
    }

    // MARK: - Storage

    private static func storageSection() -> [String] {
        let home = URL(fileURLWithPath: NSHomeDirectory())
        var avail = "unavailable"
        var total = "unavailable"
        if let values = try? home.resourceValues(forKeys: [
            .volumeAvailableCapacityForImportantUsageKey,
            .volumeTotalCapacityKey,
        ]) {
            if let a = values.volumeAvailableCapacityForImportantUsage {
                avail = ByteCountFormatter.string(fromByteCount: a, countStyle: .file)
            }
            if let t = values.volumeTotalCapacity {
                total = ByteCountFormatter.string(fromByteCount: Int64(t), countStyle: .file)
            }
        }
        return [
            "-- Storage --",
            "Available (important): \(avail)",
            "Total: \(total)",
            "",
        ]
    }

    // MARK: - Device Health

    private static func healthSection() -> [String] {
        let device = UIDevice.current
        let wasMonitoring = device.isBatteryMonitoringEnabled
        defer { device.isBatteryMonitoringEnabled = wasMonitoring }
        device.isBatteryMonitoringEnabled = true

        let batteryLine: String
        let state = device.batteryState
        if state == .unknown {
            batteryLine = "N/A (unsupported in Simulator)"
        } else {
            let level = Int(device.batteryLevel * 100)
            let stateName: String
            switch state {
            case .charging:    stateName = "charging"
            case .full:        stateName = "full"
            case .unplugged:   stateName = "unplugged"
            default:           stateName = "unknown"
            }
            batteryLine = "\(level)% (\(stateName))"
        }

        let thermal: String
        switch ProcessInfo.processInfo.thermalState {
        case .nominal:  thermal = "nominal"
        case .fair:     thermal = "fair"
        case .serious:  thermal = "serious"
        case .critical: thermal = "critical"
        @unknown default: thermal = "unknown"
        }

        return [
            "-- Device Health --",
            "Battery: \(batteryLine)",
            "Low Power Mode: \(ProcessInfo.processInfo.isLowPowerModeEnabled)",
            "Thermal state: \(thermal)",
            "",
        ]
    }

    // MARK: - App State / Feature Flags

    private static func appStateSection() -> [String] {
        let ud = UserDefaults.standard
        let iap     = ud.bool(forKey: "IAPManager.isPremium")
        let welcome = ud.bool(forKey: "hasSeenWelcome")
        let splash  = ud.integer(forKey: "lastSplashDay")
        let favCount = (ud.array(forKey: "DanceStore.favorites") as? [String])?.count ?? 0
        let favMod  = (ud.object(forKey: "DanceStore.favoritesModifiedAt") as? Date).map { "\($0)" } ?? "never"
        let modules = (ud.stringArray(forKey: "CurriculumStore.completedModuleIDs") ?? []).count
        let modMod  = (ud.object(forKey: "CurriculumStore.completedModifiedAt") as? Date).map { "\($0)" } ?? "never"
        let engages = ud.integer(forKey: "ReviewManager.engagementCount")
        let revThresh = ud.integer(forKey: "ReviewManager.nextThreshold")
        let revLast = (ud.object(forKey: "ReviewManager.lastRequestDate") as? Date).map { "\($0)" } ?? "never"
        let practiceData = ud.data(forKey: "PracticeStore.log")
        let practiceSize = practiceData.map { "\($0.count) bytes" } ?? "nil"
        return [
            "-- App State / Feature Flags --",
            "isPremium: \(iap)",
            "hasSeenWelcome: \(welcome)",
            "lastSplashDay (era ordinal): \(splash)",
            "Favorites count: \(favCount)",
            "Favorites modified: \(favMod)",
            "Curriculum completed modules: \(modules)",
            "Curriculum modified: \(modMod)",
            "ReviewManager engagement count: \(engages)",
            "ReviewManager next threshold: \(revThresh)",
            "ReviewManager last prompt: \(revLast)",
            "PracticeStore log data: \(practiceSize)",
            "",
        ]
    }

    // MARK: - Recent Logs

    private static func logsSection() -> [String] {
        var entries: [String] = ["-- Recent Logs (last 5 min, this app) --"]
        if #available(iOS 15.0, *) {
            do {
                let store = try OSLogStore(scope: .currentProcessIdentifier)
                let since = store.position(date: Date().addingTimeInterval(-300))
                let subsystem = Bundle.main.bundleIdentifier ?? "com.defnota.WesternDanceStudio"
                let all = try store.getEntries(at: since)
                    .compactMap { $0 as? OSLogEntryLog }
                    .filter { $0.subsystem == subsystem }
                    .suffix(50)
                if all.isEmpty {
                    entries.append("(no log entries in the last 5 minutes)")
                } else {
                    let timeFmt = DateFormatter()
                    timeFmt.dateFormat = "HH:mm:ss"
                    for entry in all {
                        let ts = timeFmt.string(from: entry.date)
                        entries.append("[\(ts)] [\(entry.category)] \(entry.composedMessage)")
                    }
                }
            } catch {
                entries.append("OSLogStore unavailable: \(error.localizedDescription)")
            }
        } else {
            entries.append("(OSLogStore requires iOS 15+)")
        }
        entries.append("")
        return entries
    }
}
#endif
