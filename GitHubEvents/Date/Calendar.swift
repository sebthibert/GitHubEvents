import Foundation

extension Calendar {
  static var event: Calendar {
    var calendar = Calendar.current
    if let gmtTimeZone = TimeZone.gmt {
      calendar.timeZone = gmtTimeZone
    }
    return calendar
  }
}
