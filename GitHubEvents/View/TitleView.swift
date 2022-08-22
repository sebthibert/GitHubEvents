import SwiftUI

struct TitleView: View {
  let title: String
  let font: Font
  let textAlignment: TextAlignment

  init(
    title: String,
    font: Font = .body,
    textAlignment: TextAlignment = .leading
  ) {
    self.title = title
    self.font = font
    self.textAlignment = textAlignment
  }

  var body: some View {
    Text(title)
      .font(font.monospaced().bold())
      .multilineTextAlignment(textAlignment)
      .foregroundStyle(LinearGradient.title)
  }
}
