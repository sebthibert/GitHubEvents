import SwiftUI

struct EventView: View {
  let event: Event
  @State private var currentDate = Date()
  private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

  var body: some View {
    ScrollView {
      VStack(spacing: 48) {
        VStack(spacing: 16) {
          TitleView(
            title: event.title,
            font: .title,
            textAlignment: .center
          )
          DateView(
            day: event.day,
            month: event.fullmonth,
            year: event.year,
            font: .title3,
            textAlignment: .center
          )
        }
        if let dateComponentsTillNextEvent = event.dateComponentsTillNextEvent(date: currentDate) {
          CountdownView(
            title: "Till next event",
            dateComponents: dateComponentsTillNextEvent
          )
        }
        CountdownView(
          title: "Since first event",
          dateComponents: event.dateComponentsSinceFirstEvent(date: currentDate)
        )
      }
      .padding(.vertical, 32)
      .padding(.horizontal, 16)
    }
    .onReceive(timer) { date in
      currentDate = date
    }
  }
}
