import SwiftUI

struct MonthAndDayView: View {
  let day: String
  let month: String

  var body: some View {
    Text("\(month) \(day)")
      .font(.body.monospaced().bold())
      .foregroundStyle(LinearGradient.monthAndDay)
  }
}
