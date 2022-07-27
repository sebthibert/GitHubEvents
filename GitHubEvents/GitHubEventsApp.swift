import SwiftUI

@main
struct GitHubEventsApp: App {
  let viewModel = ViewModel()

  var body: some Scene {
    WindowGroup {
#if os(iOS)
      NavigationView {
        ContentView(viewModel: viewModel)
      }
      .navigationViewStyle(.stack)
#else
      ContentView(viewModel: viewModel)
#endif
    }
  }
}

import AppIntents
import SplebbosNetworking

@available(iOS 16, *)
struct ShowNextEvent: AppIntent {
  static var title: LocalizedStringResource = "Show next event"

  func perform() async throws -> some IntentResult {
    let result = await URLSession.getEvents()
    let firstEvent = try? result.get()
      .sorted()
      .first
    if let event = firstEvent {
      let view = EventRow(event: event, selectedLabels: .constant([])).padding()
      return .result(dialog: "Looks like \(event.title) is the next event.", view: view)
    } else {
      return .result(dialog: "Sorry I could not do that.", view: Text("Unlucky"))
    }
  }
}

@available(iOS 16, *)
enum Month: Int, AppEnum {
  case january, february, march, april, may, june, july, august, september, october, november, december

  static let typeDisplayRepresentation: TypeDisplayRepresentation = "Month"

  static let typeDisplayName: LocalizedStringResource = "Month"

  static let caseDisplayRepresentations: [Month: DisplayRepresentation] = [
    .january: "January",
    .february: "February",
    .march: "March",
    .april: "April",
    .may: "May",
    .june: "June",
    .july: "July",
    .august: "August",
    .september: "September",
    .october: "October",
    .november: "November",
    .december: "December",
  ]
}

@available(iOS 16, *)
struct ShowEventsInMonth: AppIntent {
  static var title: LocalizedStringResource = "Show events in month"

  @Parameter(title: "month") var month: Month

  func perform() async throws -> some IntentResult {
    let result = await URLSession.getEvents()
    let monthEvents = try? result.get()
      .sorted()
      .filter { $0.dateComponents.month == (month.rawValue + 1) }
    if let events = monthEvents {
      let view = VStack(spacing: 0) {
        ForEach(events) { event in
          HStack(spacing: 6) {
            TitleView(title: event.title)
            Spacer()
            MonthAndDayView(day: event.day, month: event.shortMonth)
          }
        }
        .padding()
      }
      return .result(dialog: "Here are the first few events for \(month)", view: view)
    } else {
      return .result(dialog: "Sorry I could not do that.", view: Text("Unlucky"))
    }
  }
}

@available(iOS 16, *)
struct ShowNextBirthdayProvider: AppShortcutsProvider {
  static var appShortcuts: [AppShortcut] {
    AppShortcut(intent: ShowNextEvent(), phrases: [
      "What event is next?",
      "Show me the next event in \(.applicationName)",
      "Loads of phrases",
    ])
    AppShortcut(intent: ShowEventsInMonth(), phrases: [
      "Show me this events"
    ])
  }
}
