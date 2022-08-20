import SwiftUI

struct MonthAndDayView: View {
  let day: String?
  let month: String

  var body: some View {
    if let day = day {
      Text("\(month) \(day)")
        .font(.body.monospaced().bold())
        .foregroundStyle(LinearGradient.monthAndDay)
    }
  }
}
