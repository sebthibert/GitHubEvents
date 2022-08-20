import Foundation

extension Array where Element == Event.Label {
  mutating func toggle(label: Element) {
    if let index = firstIndex(of: label) {
      remove(at: index)
    } else {
      append(label)
    }
  }
}
