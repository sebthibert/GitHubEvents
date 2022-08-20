import Foundation
import WidgetKit

@MainActor
final class EventsViewModel: ObservableObject {
  enum State: Equatable {
    case idle
    case loading
    case loaded([Event])
    case failed
  }

  typealias AsyncEvents = () async throws -> [Event]
  private let events: AsyncEvents
  private let widgetEvents: AsyncEvents
  @Published var state: State = .idle

  init(events: @escaping AsyncEvents, widgetEvents: @escaping AsyncEvents) {
    self.events = events
    self.widgetEvents = widgetEvents
  }

  @Sendable func getEvents() async {
    // Need the if else for UI testing
//#if DEBUG
//    state = .loaded(.stub.sorted())
//#else
    state = .loading
    do { state = .loaded(try await events().sorted()) }
    catch { state = .failed }
//#endif
  }

  @Sendable func refreshEvents() async {
    do {
      state = .loaded(try await widgetEvents().sorted())
      WidgetCenter.shared.reloadAllTimelines()
    }
    catch { state = .failed }
  }
}
