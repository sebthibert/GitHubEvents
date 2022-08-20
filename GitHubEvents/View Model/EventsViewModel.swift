import Foundation
import WidgetKit

@MainActor
final class EventsViewModel: ObservableObject {
  enum State {
    case idle
    case loading
    case loaded([Event])
    case failed(Error)
  }
  @Published var state: State = .idle

  @Sendable func getEvents() async {
    // Need the if else for UI testing
//#if DEBUG
//    state = .loaded(.stub.sorted())
//#else
    state = .loading
    do { state = .loaded(try await URLSession.events().sorted()) }
    catch { state = .failed(error) }
//#endif
  }

  @Sendable func refreshEvents() async {
    do {
      state = .loaded(try await URLSession.widgetEvents().sorted())
      WidgetCenter.shared.reloadAllTimelines()
    }
    catch { state = .failed(error) }
  }
}
