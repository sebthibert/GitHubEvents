import Foundation
import UserNotifications

extension Array where Element == Event {
  func filtered(text: String, labels: [Event.Label]) -> [Element] {
    let text = text.trimmingCharacters(in: .whitespaces).lowercased()
    let textFilter = filter {
      $0.primaryName.lowercased().contains(text) ||
      $0.secondaryName?.lowercased().contains(text) == true ||
      $0.fullmonth.lowercased().contains(text) ||
      $0.fullDay?.lowercased().contains(text) == true ||
      $0.dateComponents.year.flatMap { String($0).lowercased().contains(text) } == true ||
      $0.labels.map { $0.rawValue }.joined().lowercased().contains(text)
    }
    if text.isEmpty {
      if labels.isEmpty {
        return self
      } else {
        return filter { Set(labels).isSubset(of: Set($0.labels)) }
      }
    } else {
      if labels.isEmpty {
        return textFilter
      } else {
        return textFilter
          .filter { Set(labels).isSubset(of: Set($0.labels)) }
      }
    }
  }

  func sorted() -> [Element] {
    sorted { $0.daysBeforeNextEvent ?? .max < $1.daysBeforeNextEvent ?? .max }
  }

  func split(pendingRequests: [UNNotificationRequest]) -> (Set<String>, [Event]) {
    let requestIDs = Set(pendingRequests.map { $0.identifier })
    let eventIDs = Set(map { $0.id })
    let oldRequestIDs = requestIDs.subtracting(eventIDs)
    let newRequestIDs = eventIDs.subtracting(requestIDs)
    let newEvents = filter { newRequestIDs.contains($0.id) }
    return (oldRequestIDs, newEvents)
  }
}
