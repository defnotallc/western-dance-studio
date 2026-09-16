import AppIntents
import SwiftUI
import WidgetKit

// MARK: - Configuration

/// Lets the user pick which part of the catalogue the widget features, edited
/// directly on the Home Screen via App Intents widget configuration.
struct FeaturedCategory: AppEntity {
    let id: String
    let name: String

    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Category"
    static let defaultQuery = FeaturedCategoryQuery()

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }

    /// The pseudo-entry meaning "draw from the whole catalogue".
    static let anyCategory = FeaturedCategory(id: "all", name: "Any Dance")

    static var allCases: [FeaturedCategory] {
        [anyCategory] + Dance.DanceCategory.allCases.map {
            FeaturedCategory(id: $0.rawValue, name: $0.rawValue)
        }
    }

    /// Resolves to a model category, or nil for "Any Dance".
    var category: Dance.DanceCategory? {
        Dance.DanceCategory(rawValue: id)
    }
}

struct FeaturedCategoryQuery: EntityQuery {
    func entities(for identifiers: [String]) async throws -> [FeaturedCategory] {
        let wanted = Set(identifiers)
        return FeaturedCategory.allCases.filter { wanted.contains($0.id) }
    }

    func suggestedEntities() async throws -> [FeaturedCategory] {
        FeaturedCategory.allCases
    }

    func defaultResult() async -> FeaturedCategory? {
        .anyCategory
    }
}

struct SelectDanceCategoryIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Choose Category"
    static let description = IntentDescription("Pick which kind of dance the widget features.")

    @Parameter(title: "Category", default: FeaturedCategory.anyCategory)
    var category: FeaturedCategory
}

// MARK: - Timeline

struct DanceEntry: TimelineEntry {
    let date: Date
    let dance: Dance
    let categoryName: String
}

struct FeaturedDanceProvider: AppIntentTimelineProvider {
    /// Deterministic pick so the widget, its preview and its snapshot agree,
    /// and so the featured dance is stable for a whole day.
    private func dance(for configuration: SelectDanceCategoryIntent, on date: Date) -> Dance {
        let pool: [Dance]
        if let category = configuration.category.category {
            pool = Dance.sampleDances.filter { $0.category == category }
        } else {
            pool = Dance.sampleDances
        }
        let candidates = pool.isEmpty ? Dance.sampleDances : pool
        let day = Calendar.current.ordinality(of: .day, in: .era, for: date) ?? 0
        return candidates[day % candidates.count]
    }

    func placeholder(in context: Context) -> DanceEntry {
        DanceEntry(date: Date(),
                   dance: Dance.sampleDances[0],
                   categoryName: FeaturedCategory.anyCategory.name)
    }

    func snapshot(for configuration: SelectDanceCategoryIntent, in context: Context) async -> DanceEntry {
        let now = Date()
        return DanceEntry(date: now,
                          dance: dance(for: configuration, on: now),
                          categoryName: configuration.category.name)
    }

    func timeline(for configuration: SelectDanceCategoryIntent, in context: Context) async -> Timeline<DanceEntry> {
        let calendar = Calendar.current
        let now = Date()
        // One entry per day for a week, refreshed at midnight.
        let entries = (0..<7).compactMap { offset -> DanceEntry? in
            guard let date = calendar.date(byAdding: .day, value: offset, to: calendar.startOfDay(for: now)) else {
                return nil
            }
            return DanceEntry(date: date,
                              dance: dance(for: configuration, on: date),
                              categoryName: configuration.category.name)
        }
        return Timeline(entries: entries, policy: .atEnd)
    }
}

// MARK: - View

struct WesternDanceWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: DanceEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(entry.categoryName.uppercased())
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
                .lineLimit(1)

            Text(entry.dance.name)
                .font(.headline)
                .minimumScaleFactor(0.7)
                .lineLimit(2)

            if family != .systemSmall {
                Text(entry.dance.summary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            }

            Spacer(minLength: 0)

            Label("\(entry.dance.bpm) BPM", systemImage: "metronome")
                .font(.caption2)
                .foregroundStyle(.tint)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        // Starts the metronome at this dance's tempo straight from the widget.
        .widgetURL(nil)
    }
}

// MARK: - Widget

struct FeaturedDanceWidget: Widget {
    static let kind = "FeaturedDanceWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: Self.kind,
                               intent: SelectDanceCategoryIntent.self,
                               provider: FeaturedDanceProvider()) { entry in
            WesternDanceWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
                .tint(Color(red: 0.62, green: 0.32, blue: 0.09))
        }
        .configurationDisplayName("Featured Dance")
        .description("A dance to try today, from the category you choose.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@main
struct WesternDanceWidgetsBundle: WidgetBundle {
    var body: some Widget {
        FeaturedDanceWidget()
    }
}
