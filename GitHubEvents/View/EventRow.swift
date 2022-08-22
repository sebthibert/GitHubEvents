import SwiftUI

struct EventRow: View {
  let event: Event
  @Binding var selectedLabels: [Event.Label]
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack(alignment: .top, spacing: 12) {
        VStack(alignment: .leading, spacing: 12) {
          TitleView(title: event.title)
          if let yearsSince = event.yearsSince {
            Text(yearsSince)
              .font(.footnote.monospaced().bold())
          }
        }
        Spacer()
        VStack(alignment: .trailing, spacing: 12) {
          MonthAndDayView(day: event.day, month: event.shortMonth)
          if let daysBefore = event.daysBefore {
            Text(daysBefore)
              .multilineTextAlignment(.trailing)
              .font(.footnote.monospaced().bold())
          }
        }
      }
      LabelsStack(
        labels: event.labels,
        stack: dynamicTypeSize < .accessibility2 ? .horizontal : .vertical(.leading),
        selectedLabels: $selectedLabels
      )
    }
    .padding(.vertical, 8)
    .contentShape(Rectangle())
  }
}
