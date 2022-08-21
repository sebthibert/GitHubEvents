@testable import GitHubEvents
import UserNotifications
import XCTest

final class EventArrayTests: XCTestCase {
  private func request(id: String) -> UNNotificationRequest {
    UNNotificationRequest(identifier: id, content: .init(), trigger: nil)
  }

  func test_split_oldRequestIDs() {
    let events: [Event] = .stub
    let count = events.count - 1
    let pendingRequests = events
      .prefix(count)
      .map { $0.id }
      .map { request(id: $0) }
    let sut = Array(events.suffix(count))
    let (oldRequestIDs, _) = sut.split(pendingRequests: pendingRequests)
    XCTAssertEqual(oldRequestIDs, ["RingoMarvin1995-05-09 06:13:20 +0000anniversarylove"])
  }

  func test_split_newEvents() {
    let events: [Event] = .stub
    let count = events.count - 1
    let pendingRequests = events
      .prefix(count)
      .map { $0.id }
      .map { request(id: $0) }
    let sut = Array(events.suffix(count))
    let (_, newEvents) = sut.split(pendingRequests: pendingRequests)
    XCTAssertEqual(newEvents, [.draco])
  }
}
