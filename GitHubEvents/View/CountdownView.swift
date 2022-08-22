import SwiftUI

struct CountdownView: View {
  let title: String
  let dateComponents: DateComponents

  private var components: [(String, Int?)] {
    [
      ("Y", dateComponents.year),
      ("M", dateComponents.month),
      ("D", dateComponents.day),
      ("h", dateComponents.hour),
      ("m", dateComponents.minute),
      ("s", dateComponents.second),
    ].filter { $0.1 != nil }
  }

  var body: some View {
    VStack(spacing: 32) {
      Text(title)
        .font(.body.monospaced().bold())
      LazyVGrid(columns: Array(repeating: GridItem(spacing: 0), count: components.count)) {
        ForEach(components, id: \.0) {
          if let value = $0.1 {
            CountdownStack(title: $0.0, value: value)
          }
        }
      }
    }
  }
}
