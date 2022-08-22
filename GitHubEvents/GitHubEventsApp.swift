import FirebaseCore
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
  ) -> Bool {
    setNavigationBarAppearance()
    FirebaseApp.configure()
    return true
  }

  private let barButtonTextAttributes: [NSAttributedString.Key: Any] = [
    .font: UIFontMetrics(forTextStyle: .subheadline).scaledFont(for: .monospacedSystemFont(ofSize: 15, weight: .semibold)),
  ]

  private let barLargeTextAttributes: [NSAttributedString.Key: Any] = [
    .font: UIFontMetrics(forTextStyle: .largeTitle).scaledFont(for: .monospacedSystemFont(ofSize: 34, weight: .bold)),
  ]

  private let barTextAttributes: [NSAttributedString.Key: Any] = [
    .font: UIFontMetrics(forTextStyle: .body).scaledFont(for: .monospacedSystemFont(ofSize: 17, weight: .bold)),
  ]

  private func setNavigationBarAppearance() {
    UIBarButtonItem.appearance().setTitleTextAttributes(barButtonTextAttributes, for: .normal)
    UINavigationBar.appearance().titleTextAttributes = barTextAttributes
    UINavigationBar.appearance().largeTitleTextAttributes = barLargeTextAttributes
  }
}

import FirebaseFirestore
import FirebaseFirestoreCombineSwift

struct FirebaseController {
  static let database = Firestore.firestore()
  static let collection = database.collection("splebbo-events")

  static func addEvent(_ event: Event) {
    var ref: DocumentReference? = nil
    do {
      ref = try collection.addDocument(from: event)
      print("Document added with ID: \(ref!.documentID)")
    } catch {
      print("Error adding document: \(error)")
    }
  }

  static func getEvents(completion: @escaping ([Event]) -> Void) {
    collection.getDocuments { snapshot, error in
      if let documents = snapshot?.documents, error == nil {
        let events = documents.compactMap { try? $0.data(as: Event.self) }
        completion(events)
      } else if let error = error {
        print("Error getting documents: \(error)")
      }
    }
  }
}

@main
struct GitHubEventsApp: App {
  private let viewModel = EventsViewModel(
    events: URLSession.events,
    refreshEvents: URLSession.widgetEvents
  )
  @State var events: [Event] = []
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

  var body: some Scene {
    WindowGroup {
#if os(iOS)
      NavigationView {
        EventsView(viewModel: viewModel)
//        VStack {
//          Button("Add event") {
//            FirebaseController.addEvent(Event(
//              primaryName: "Test",
//              secondaryName: nil,
//              timestamp: Date(),
//              type: .birthday,
//              imageURL: nil,
//              labels: [.friends, .family]))
//          }
//          .onAppear {
//            FirebaseController.getEvents { events in
//              self.events = events
//            }
//          }
//          ForEach(events) {
//            EventRow(event: $0, selectedLabels: .constant([]))
//          }
//        }
      }
      .navigationViewStyle(.stack)
#else
      EventsView(viewModel: viewModel)
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
    let firstEvent = try? await URLSession.widgetEvents()
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
    let monthEvents = try? await URLSession.widgetEvents()
      .sorted()
      .filter { $0.dateComponents.month == (month.rawValue + 1) }
    if let events = monthEvents {
      let view = VStack(spacing: 0) {
        ForEach(events) { event in
          HStack(spacing: 6) {
            TitleView(title: event.title)
            Spacer()
            DateView(day: event.day, month: event.shortMonth)
          }
        }
        .padding()
      }
      return .result(dialog: "Here are the events for \(month)", view: view)
    } else {
      return .result(dialog: "Sorry I could not do that.", view: Text("Unlucky"))
    }
  }
}

@available(iOS 16, *)
struct ShowNextBirthdayProvider: AppShortcutsProvider {
  static var appShortcuts: [AppShortcut] {
    AppShortcut(intent: ShowNextEvent(), phrases: [
      "What \(.applicationName) is next?",
      "What \(.applicationName) is coming up?",
    ])
    AppShortcut(intent: ShowEventsInMonth(), phrases: [
      "Show me \(.applicationName)s for a month.",
    ])
  }
}
