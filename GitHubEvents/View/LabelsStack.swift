import SwiftUI

struct LabelsStack: View {
  enum Stack {
    case vertical(HorizontalAlignment)
    case horizontal
  }

  let labels: [Event.Label]
  let stack: Stack
  @Binding var selectedLabels: [Event.Label]
  @ScaledMetric var horizontalPadding = 8
  @ScaledMetric var verticalPadding = 4
  @ScaledMetric var stackSpacing = 12

  private func color(for label: Event.Label) -> Color {
    switch label {
    case .family:
      return .green
    case .friends:
      return .blue
    case .love:
      return .red
    case .rgm:
      return .orange
    }
  }

  func content() -> some View {
    ForEach(labels, id: \.self) { label in
      Text(label.rawValue)
        .accessibilityLabel("123")
        .lineLimit(1)
        .font(.caption.monospaced().bold())
        .foregroundColor(.white)
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, verticalPadding)
        .background(
          Capsule(style: .continuous)
            .foregroundColor(color(for: label))
        )
        .contentShape(Rectangle())
        .onTapGesture {
          if let index = selectedLabels.firstIndex(of: label) {
            selectedLabels.remove(at: index)
          } else {
            selectedLabels.append(label)
          }
        }
    }
  }

  var body: some View {
    switch stack {
    case .horizontal:
      HStack(spacing: stackSpacing) {
        content()
      }
    case .vertical(let alignment):
      VStack(alignment: alignment, spacing: stackSpacing) {
        content()
      }
    }
  }
}
