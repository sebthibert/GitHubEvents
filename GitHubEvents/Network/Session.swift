import Foundation
import SplebbosNetworking

extension URLSession {
  static func events() async throws -> [Event] {
    try await shared.decodable(for: .load, decoder: .events)
  }

  static func widgetEvents() async throws -> [Event] {
    try await shared.decodable(for: .refresh, decoder: .events)
  }
}
