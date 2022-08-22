import SwiftUI

struct TitleView: View {
  let title: String

  var body: some View {
    Text(title)
      .font(.body.monospaced().bold())
      .foregroundStyle(LinearGradient.title)
  }
}
