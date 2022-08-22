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

  var body: some View {
    ScrollView {
      VStack(spacing: 32) {
        TitleView(
          title: event.title,
          font: .title,
          textAlignment: .center
        )
      }
      .padding(32)
    }
  }
}
