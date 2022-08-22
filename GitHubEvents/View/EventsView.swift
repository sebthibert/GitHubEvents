import SwiftUI

struct EventsView: View {
  @StateObject var viewModel: EventsViewModel
  @State private var searchableText = ""
  @State private var selectedLabels: [Event.Label] = []
  @State private var selectedEvent: Event?
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize

  var bodyForState: some View {
    Group {
      switch viewModel.state {
      case .loaded(let events):
        List {
          let events = events.filtered(text: searchableText, labels: selectedLabels)
          let text = events.filteredCount(searchableText: searchableText)
          HStack(spacing: 6) {
            Text(text)
              .accessibility(identifier: "Event Count")
              .font(.footnote.monospaced().bold())
              .padding(.vertical, 8)
            Spacer()
            LabelsStack(
              labels: selectedLabels,
              stack: dynamicTypeSize < .accessibility2 ? .horizontal : .vertical(.trailing),
              selectedLabels: $selectedLabels
            )
          }
#if os(iOS)
          .listRowSeparator(.hidden, edges: .top)
#else
          .padding([.horizontal])
#endif
          .animation(.none, value: searchableText)
          .animation(.none, value: selectedLabels)
          ForEach(events) { event in
            EventRow(event: event, selectedLabels: $selectedLabels)
              .onTapGesture { selectedEvent = event }
#if os(macOS)
              .padding([.horizontal])
#endif
          }
        }
        .listStyle(.plain)
        .refreshable(action: viewModel.refreshEvents)
        .searchable(text: $searchableText, prompt: "Search events")
        .font(.subheadline.monospaced().bold())
        .animation(.default, value: searchableText)
        .animation(.default, value: selectedLabels)
        .popover(item: $selectedEvent, content: EventView.init)
        .task { await NotificationController.requestAndSetNotifications(events: events) }
      case .failed:
        Text("Sorry we could not get your events right now")
          .font(.body.monospaced().bold())
      default:
        ProgressView()
      }
    }
  }

  var body: some View {
    bodyForState
#if os(iOS)
      .navigationBarTitle("Events", displayMode: .inline)
#endif
      .task(viewModel.getEvents)
  }
}

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
