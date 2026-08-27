import SwiftUI
import StoreKit

struct SettingsView: View {
    @State private var iap = IAPManager.shared
    @State private var consent = ConsentManager.shared
    @State private var showRemoveAds = false
    @AppStorage("theme") private var theme: String = "system"
    @Environment(\.dismiss) private var dismiss
    @Environment(\.requestReview) private var requestReview

    private static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
    private static let appBuild   = Bundle.main.infoDictionary?["CFBundleVersion"]             as? String ?? "—"

    var body: some View {
        NavigationStack {
            List {
                // 1. Go Premium — entire section vanishes after purchase
                if !iap.isPremium {
                    Section {
                        Button { showRemoveAds = true } label: { premiumRow }
                            .buttonStyle(.plain)
                    }
                }

                // 2. Appearance
                Section {
                    Picker("Theme", selection: $theme) {
                        Text("Automatic").tag("system")
                        Text("Light").tag("light")
                        Text("Dark").tag("dark")
                    }
                    .pickerStyle(.segmented)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                } header: {
                    Text("Appearance")
                } footer: {
                    Text("Controls app-wide light/dark mode independently of system settings.")
                }

                // 3. Support
                Section("Support") {
                    feedbackRateRow
                }

                // 4. Ad Preferences (EEA/UK/CH only — GDPR)
                if consent.privacyOptionsRequired {
                    Section("Privacy") {
                        Button {
                            Task { await ConsentManager.shared.presentPrivacyOptionsForm() }
                        } label: {
                            adPreferencesRow
                        }
                        .buttonStyle(.plain)
                    }
                }

                // 5. App Info
                Section("App Info") {
                    LabeledContent("Version", value: "\(Self.appVersion) (Build \(Self.appBuild))")
                }

                // 6. Legal footer
                Section {
                    footerContent
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }

                // 7. Developer tools — compiled out entirely in Release
                #if DEBUG
                Section {
                    diagnosticsButton
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }
                #endif
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $showRemoveAds) {
                RemoveAdsSheet(iap: iap)
            }
        }
        .preferredColorScheme(resolvedColorScheme)
    }

    // MARK: - Theme resolution

    private var resolvedColorScheme: ColorScheme? {
        WesternTheme.resolvedColorScheme(for: theme)
    }

    // MARK: - Go Premium row

    private var premiumRow: some View {
        HStack(spacing: 14) {
            Image(systemName: "crown.fill")
                .font(.title3)
                .foregroundStyle(WesternTheme.accent)
            VStack(alignment: .leading, spacing: 2) {
                Text("Go Premium")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                if let product = iap.removeAdsProduct {
                    Text("Remove ads · \(product.displayPrice) one-time")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Remove all ads · one-time purchase")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
    }

    // MARK: - Feedback + Rate Us

    private var feedbackRateRow: some View {
        HStack(spacing: 12) {
            Link(
                destination: URL(string: "mailto:Defnota.official@gmail.com?subject=Western%20Dance%20Studio%20Feedback")!
            ) {
                Text("Feedback")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(WesternTheme.primaryDark)
                    .clipShape(Capsule())
            }
            Button {
                requestReview()
            } label: {
                Text("Rate Us ★")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(WesternTheme.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(WesternTheme.primary.opacity(0.12))
                    .clipShape(Capsule())
            }
        }
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
    }

    // MARK: - Ad Preferences row

    private var adPreferencesRow: some View {
        HStack(spacing: 14) {
            Image(systemName: "hand.raised.fill")
                .font(.title3)
                .foregroundStyle(WesternTheme.primary)
            VStack(alignment: .leading, spacing: 2) {
                Text("Ad Preferences")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                Text("Manage your advertising consent (GDPR)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
    }

    // MARK: - Footer

    private var footerContent: some View {
        VStack(spacing: 6) {
            Text("Western Dance Studio")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Text("Version \(Self.appVersion) · © 2025 DefNotA")
                .font(.caption2)
                .foregroundStyle(.tertiary)
            Text("As an Amazon Associate, we earn from qualifying purchases.")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }

    // MARK: - Diagnostics button (#if DEBUG)

    #if DEBUG
    @State private var diagnosticsCopied = false

    private var diagnosticsButton: some View {
        Button {
            let report = DiagnosticsCollector.generateReport()
            UIPasteboard.general.string = report
            withAnimation(.easeInOut(duration: 0.2)) { diagnosticsCopied = true }
            Task {
                try? await Task.sleep(for: .seconds(2))
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.2)) { diagnosticsCopied = false }
                }
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(diagnosticsCopied ? Color.green : Color.orange)
                HStack(spacing: 8) {
                    Image(systemName: diagnosticsCopied ? "checkmark.circle.fill" : "doc.on.clipboard")
                        .font(.subheadline.weight(.semibold))
                    Text(diagnosticsCopied ? "Copied!" : "Copy Diagnostics (DEBUG)")
                        .font(.headline)
                }
                .foregroundStyle(.white)
                .padding(.vertical, 14)
            }
            .frame(height: 50)
        }
        .animation(.easeInOut(duration: 0.2), value: diagnosticsCopied)
        .accessibilityLabel("Copy diagnostics report to clipboard")
    }
    #endif
}

#Preview {
    SettingsView()
}
