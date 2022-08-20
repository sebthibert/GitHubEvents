import SwiftUI

struct TitleView: View {
  let title: String

  var body: some View {
    Text(title)
      .font(.title3.monospaced().bold())
      .foregroundStyle(LinearGradient.title)
  }
}
