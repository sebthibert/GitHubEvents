import SwiftUI

struct DateView: View {
  let day: String
  let month: String
  let year: String?
  let font: Font
  let textAlignment: TextAlignment

  init(
    day: String,
    month: String,
    year: String? = nil,
    font: Font = .body,
    textAlignment: TextAlignment
  ) {
    self.day = day
    self.month = month
    self.year = year
    self.font = font
    self.textAlignment = textAlignment
  }

  var text: String {
    var text = "\(month) \(day)"
    if let year = year {
      text += " \(year)"
    }
    return text
  }

  var body: some View {
    Text(text)
      .font(font.monospaced().bold())
      .multilineTextAlignment(textAlignment)
      .foregroundStyle(LinearGradient.monthAndDay)
  }
}
