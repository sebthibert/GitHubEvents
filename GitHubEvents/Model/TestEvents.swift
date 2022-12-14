import Foundation

extension Event {
  static let draco = Event(
    primaryName: "Draco",
    secondaryName: nil,
    timestamp: Date(timeIntervalSince1970: 200000000),
    category: .birthday,
    labels: [.love]
  )
}

extension Array where Element == Event {
  static let stub: [Event] = [
    Event(
      primaryName: "Ringo",
      secondaryName: "Marvin",
      timestamp: Date(timeIntervalSince1970: 800000000),
      category: .anniversary,
      labels: [.love]
    ),
    Event(
      primaryName: "Hugo",
      secondaryName: nil,
      timestamp: Date(timeIntervalSince1970: 700000000),
      category: .birthday,
      labels: [.friends]
    ),
    Event(
      primaryName: "Hagrid",
      secondaryName: nil,
      timestamp: Date(timeIntervalSince1970: 600000000),
      category: .birthday,
      labels: [.family]
    ),
    Event(
      primaryName: "Harry",
      secondaryName: nil,
      timestamp: Date(timeIntervalSince1970: 500000000),
      category: .birthday,
      labels: [.family]
    ),
    Event(
      primaryName: "Ron",
      secondaryName: nil,
      timestamp: Date(timeIntervalSince1970: 400000000),
      category: .birthday,
      labels: [.family]
    ),
    Event(
      primaryName: "Hermione",
      secondaryName: nil,
      timestamp: Date(timeIntervalSince1970: 300000000),
      category: .birthday,
      labels: [.friends]
    ),
    .draco,
  ]
}
