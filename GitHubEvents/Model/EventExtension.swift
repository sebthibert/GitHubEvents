import Foundation

extension Event {
  var id: String {
    primaryName +
    (secondaryName ?? "") +
    timestamp.description +
    category.rawValue +
    labels.map { $0.rawValue }.joined()
  }

  var title: String {
    switch category {
    case .birthday:
      return "\(primaryName)'s Birthday"
    case .anniversary:
      if let secondaryName = secondaryName {
        return "\(primaryName) & \(secondaryName)'s Anniversary"
      } else {
        return "\(primaryName)'s Anniversary"
      }
    }
  }

  private var timestampDateComponents: DateComponents {
    Calendar.event.dateComponents([.day, .month], from: timestamp)
  }

  var day: String? {
    guard let day = timestampDateComponents.day else {
      return nil
    }
    return String(format: "%02d", day)
  }

  var fullDay: String? {
    guard let day = timestampDateComponents.day else {
      return nil
    }
    switch day {
    case 1, 21, 31:
      return "\(day)st"
    case 2, 22:
      return "\(day)nd"
    case 3, 23:
      return "\(day)rd"
    default:
      return "\(day)th"
    }
  }

  private func gmt(dateFormat: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = .gmt
    dateFormatter.dateFormat = dateFormat
    return dateFormatter.string(from: timestamp)
  }

  var shortMonth: String {
    gmt(dateFormat: "MMM")
  }

  var fullmonth: String {
    gmt(dateFormat: "MMMM")
  }

  var dateComponents: DateComponents {
    Calendar.event.dateComponents([.day, .month, .year], from: timestamp)
  }


  private var yearsSinceTimestamp: Int? {
    Calendar.event.dateComponents([.year], from: timestamp, to: Date()).year
  }

  private var monthsSinceTimestamp: Int? {
    Calendar.event.dateComponents([.month], from: timestamp, to: Date()).month
  }

  var yearsSince: String? {
    guard let year = dateComponents.year, let yearsSinceTimestamp = yearsSinceTimestamp else {
      return nil
    }
    switch yearsSinceTimestamp {
    case 0...1:
      guard let monthsSince = monthsSince else {
        return "\(year): \(yearsSinceTimestamp == 0 ? "0 years" : "1 year")"
      }
      return "\(year): \(monthsSince)"
    default:
      return "\(year): \(yearsSinceTimestamp) years"
    }
  }

  var monthsSince: String? {
    guard let monthsSinceTimestamp = monthsSinceTimestamp else {
      return nil
    }
    switch monthsSinceTimestamp {
    case 0:
      return "0 months"
    case 1:
      return "1 month"
    default:
      return "\(monthsSinceTimestamp) months"
    }
  }

  var daysBefore: String? {
    guard let daysBeforeNextEvent = daysBeforeNextEvent else {
      return nil
    }
    switch daysBeforeNextEvent {
    case 0:
      return "Today"
    case 1:
      return "1 day"
    default:
      return "\(daysBeforeNextEvent) days"
    }
  }

  func currentYear(currentDate: Date) -> Int? {
    Calendar.event.dateComponents([.year], from: currentDate).year
  }

  func daysBeforeEventThisYear(currentDate: Date) -> Int? {
    guard let currentYear = currentYear(currentDate: currentDate) else {
      return nil
    }
    var timestampDateComponents = self.timestampDateComponents
    timestampDateComponents.year = currentYear
    guard let eventDateThisYear = Calendar.event.date(from: timestampDateComponents) else {
      return nil
    }
    return Calendar.event.dateComponents([.day], from: currentDate, to: eventDateThisYear).day
  }

  var daysBeforeNextEvent: Int? {
    let currentDate = Date()
    guard let currentYear = currentYear(currentDate: currentDate) else {
      return nil
    }
    var timestampDateComponents = self.timestampDateComponents
    timestampDateComponents.year = currentYear
    guard let daysBeforeEventThisYear = daysBeforeEventThisYear(currentDate: currentDate) else {
      return nil
    }
    if daysBeforeEventThisYear >= 0 {
      return daysBeforeEventThisYear
    } else {
      let nextYear = currentYear + 1
      timestampDateComponents.year = nextYear
      guard let eventDateNextYear = Calendar.event.date(from: timestampDateComponents) else {
        return nil
      }
      return Calendar.event.dateComponents([.day], from: currentDate, to: eventDateNextYear).day
    }
  }
}
