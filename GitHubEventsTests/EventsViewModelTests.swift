import Combine
@testable import GitHubEvents
import XCTest

class EventsViewModelTests: XCTestCase {
  private var cancellable: AnyCancellable?

  func test_stateChain_for_getEvents_whenNoError() async {
    let sut = EventsViewModel(
      events: { .stub },
      refreshEvents: { .stub }
    )
    var states: [EventsViewModel.State] = []
    cancellable = sut.$state.sink(receiveValue: { states.append($0) })
    await sut.getEvents()
    XCTAssertEqual(states, [.idle, .loading, .loaded(.stub.sorted())])
  }

  func test_stateChain_for_getEvents_whenError() async {
    let sut = EventsViewModel(
      events: { throw URLError(.appTransportSecurityRequiresSecureConnection) },
      refreshEvents: { .stub }
    )
    var states: [EventsViewModel.State] = []
    cancellable = sut.$state.sink(receiveValue: { states.append($0) })
    await sut.getEvents()
    XCTAssertEqual(states, [.idle, .loading, .failed])
  }

  func test_stateChain_for_refreshEvents_whenNoError() async {
    let sut = EventsViewModel(
      events: { .stub },
      refreshEvents: { .stub }
    )
    var states: [EventsViewModel.State] = []
    cancellable = sut.$state.sink(receiveValue: { states.append($0) })
    await sut.refreshEvents()
    XCTAssertEqual(states, [.idle, .loaded(.stub.sorted())])
  }

  func test_stateChain_for_refreshEvents_whenError() async {
    let sut = EventsViewModel(
      events: { .stub },
      refreshEvents: { throw URLError(.appTransportSecurityRequiresSecureConnection) }
    )
    var states: [EventsViewModel.State] = []
    cancellable = sut.$state.sink(receiveValue: { states.append($0) })
    await sut.refreshEvents()
    XCTAssertEqual(states, [.idle, .failed])
  }
}
