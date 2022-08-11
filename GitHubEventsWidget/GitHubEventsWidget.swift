import Intents
import SwiftUI
import WidgetKit

struct Provider: IntentTimelineProvider {
  func placeholder(in context: Context) -> SimpleEntry {
    SimpleEntry(date: Date(), events: [])
  }

  private func events() async throws -> [Event] {
    try await URLSession.widgetEvents().sorted()
  }

  func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
    Task {
      let entry = SimpleEntry(date: Date(), events: try await events())
      completion(entry)
    }
  }

  func getTimeline(
    for configuration: ConfigurationIntent,
    in context: Context,
    completion: @escaping (Timeline<Entry>) -> ()
  ) {
    Task {
      let entry = SimpleEntry(date: Date(), events: try await events())
      let timeline = Timeline(entries: [entry], policy: .atEnd)
      completion(timeline)
    }
  }
}

struct SimpleEntry: TimelineEntry {
  let date: Date
  let events: [Event]
}

struct GitHubEventsWidgetEntryView : View {
  @Environment(\.widgetFamily) var widgetFamily
  var entry: Provider.Entry

  var body: some View {
    switch widgetFamily {
    case .systemSmall:
      SmallWidget(events: entry.events)
    case .systemMedium:
      MediumWidget(events: entry.events)
    case .systemLarge:
      LargeWidget(events: entry.events, prefix: 3)
    case .systemExtraLarge:
      LargeWidget(events: entry.events, prefix: 6)
    default:
      EmptyView()
    }
  }
}

struct SmallWidget: View {
  let events: [Event]

  var body: some View {
    if let event = events.first {
      VStack(alignment: .leading, spacing: 12) {
        TitleView(title: event.title)
        MonthAndDayView(day: event.day, month: event.shortMonth)
      }
      .padding()
    } else {
      Text("No events")
    }
  }
}

struct MediumWidget: View {
  let events: [Event]

  var body: some View {
    if let event = events.first {
      EventRow(event: event, selectedLabels: .constant([]))
        .padding()
    } else {
      Text("No events")
    }
  }
}

struct LargeWidget: View {
  let events: [Event]
  let prefix: Int

  var body: some View {
    let events = events.prefix(prefix)
    if !events.isEmpty {
      VStack(alignment: .leading, spacing: 12) {
        ForEach(events) { event in
          EventRow(event: event, selectedLabels: .constant([]))
        }
      }
      .padding()
    } else {
      Text("No events")
    }
  }
}

@main
struct GitHubEventsWidget: Widget {
  let kind: String = "GitHubEventsWidget"

  var body: some WidgetConfiguration {
    IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
      GitHubEventsWidgetEntryView(entry: entry)
    }
    .configurationDisplayName("My Widget")
    .description("This is an example widget.")
  }
}
