import SwiftUI

extension LinearGradient {
  static let title = LinearGradient(
    gradient: Gradient(colors: [.green, .blue]),
    startPoint: .leading,
    endPoint: .trailing
  )

  static let monthAndDay = LinearGradient(
    gradient: Gradient(colors: [.purple, .red]),
    startPoint: .leading,
    endPoint: .trailing
  )
}
