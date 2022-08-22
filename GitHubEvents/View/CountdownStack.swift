import SwiftUI

struct CountdownStack: View {
  let title: String
  let value: Int

  var body: some View {
    VStack(spacing: 8) {
      Text(title)
        .font(.footnote.monospaced().bold())
        .foregroundColor(.secondary)
      Text(String(value))
        .font(.title3.monospaced().bold())
    }
  }
}
