import WidgetKit
import SwiftUI

private func sharedDefaults() -> UserDefaults? {
    UserDefaults(suiteName: "group.com.yourname.dailyline")
}

struct QuoteEntry: TimelineEntry {
    let date: Date
    let quote: String
    let author: String
    let book: String
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> QuoteEntry {
        QuoteEntry(date: Date(), quote: "You have power over your mind.", author: "Marcus Aurelius", book: "Meditations")
    }
    func getSnapshot(in context: Context, completion: @escaping (QuoteEntry) -> Void) {
        completion(makeEntry())
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<QuoteEntry>) -> Void) {
        let midnight = Calendar.current.startOfDay(for: Date().addingTimeInterval(86400))
        completion(Timeline(entries: [makeEntry()], policy: .after(midnight)))
    }
    private func makeEntry() -> QuoteEntry {
        let d = sharedDefaults()
        return QuoteEntry(
            date: Date(),
            quote:  d?.string(forKey: "widget_quote")  ?? "Open DailyLine to load your quote",
            author: d?.string(forKey: "widget_author") ?? "",
            book:   d?.string(forKey: "widget_book")   ?? ""
        )
    }
}

struct QuoteWidgetEntryView: View {
    var entry: QuoteEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color(red: 0.05, green: 0.05, blue: 0.07)
            VStack(alignment: .leading, spacing: 0) {
                Text("\u{201C}")
                    .font(.system(size: family == .systemSmall ? 28 : 40, weight: .bold, design: .serif))
                    .foregroundColor(Color(red: 0.83, green: 0.69, blue: 0.42).opacity(0.35))
                    .padding(.bottom, -8)
                Text(entry.quote)
                    .font(.system(size: family == .systemSmall ? 12 : 14, weight: .medium, design: .serif))
                    .italic()
                    .foregroundColor(.white.opacity(0.88))
                    .lineLimit(family == .systemSmall ? 4 : 6)
                Spacer(minLength: 8)
                HStack(spacing: 6) {
                    Rectangle()
                        .frame(width: 16, height: 1)
                        .foregroundColor(Color(red: 0.83, green: 0.69, blue: 0.42).opacity(0.6))
                    VStack(alignment: .leading, spacing: 1) {
                        Text(entry.author)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(Color(red: 0.83, green: 0.69, blue: 0.42))
                        if !entry.book.isEmpty {
                            Text(entry.book)
                                .font(.system(size: 9))
                                .foregroundColor(.white.opacity(0.3))
                        }
                    }
                }
            }
            .padding(family == .systemSmall ? 14 : 18)
        }
    }
}

@main
struct QuoteWidget: Widget {
    let kind = "QuoteWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            QuoteWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("DailyLine")
        .description("Your quote for the day.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
