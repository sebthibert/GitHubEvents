import Foundation

struct Event: Codable, Equatable, Identifiable {
  let primaryName: String
  let secondaryName: String?
  let timestamp: Date
  let type: Category
  let labels: [Label]

  enum Category: String, Codable {
    case birthday
    case anniversary
  }

  enum Label: String, Codable {
    case family
    case friends
    case love
    case rgm
  }
}
