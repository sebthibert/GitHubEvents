import Foundation
import WidgetKit

final class EventsViewModel: ObservableObject {
  enum State: Equatable {
    case idle
    case loading
    case loaded([Event])
    case failed
  }

  typealias AsyncEvents = () async throws -> [Event]
  private let events: AsyncEvents
  private let refreshEvents: AsyncEvents
  @Published var state: State = .idle {
    didSet {
      if case .loaded(let events) = state {
        Task { await NotificationController.setNotifications(events: events) }
      }
    }
  }

  init(events: @escaping AsyncEvents, refreshEvents: @escaping AsyncEvents) {
    self.events = events
    self.refreshEvents = refreshEvents
  }

  @MainActor @Sendable func getEvents() async {
    state = .loading
    do { state = .loaded(try await events().sorted()) }
    catch { state = .failed }
  }

  @MainActor @Sendable func refreshEvents() async {
    do {
      state = .loaded(try await refreshEvents().sorted())
      WidgetCenter.shared.reloadAllTimelines()
    }
    catch { state = .failed }
  }
}
