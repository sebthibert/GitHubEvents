import SwiftUI
import WidgetKit

struct ContentView: View {
  @ObservedObject var viewModel: ViewModel
  @State var searchableText = ""
  @State var selectedLabels: [Event.EventLabel] = []
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass

  var bodyForState: some View {
    Group {
      switch viewModel.state {
      case .loaded(let events):
        List {
          let events = events.filtered(text: searchableText, labels: selectedLabels)
          let text = events.count >= 1 ? "\(events.count) \(events.count > 1 ? "events" : "event")" : "No events found for \(searchableText)"
          HStack(spacing: 6) {
            Text(text)
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
          ForEach(events) {
            EventRow(event: $0, selectedLabels: $selectedLabels)
#if os(macOS)
              .padding([.horizontal])
#endif
          }
        }
        .listStyle(.plain)
        .refreshable(action: viewModel.refreshEvents)
        .searchable(text: $searchableText)
        .animation(.default, value: searchableText)
        .animation(.default, value: selectedLabels)
      case .failed(let error):
        Text(error.localizedDescription)
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
      .onAppear(perform: viewModel.getEvents)
  }
}

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

struct EventRow: View {
  let event: Event
  @Binding var selectedLabels: [Event.EventLabel]
  @Environment(\.dynamicTypeSize) var dynamicTypeSize

  var image: some View {
    AsyncImage(url: event.imageURL) { image in
      image
        .resizable()
        .frame(width: 44, height: 44)
        .clipShape(Circle())
    } placeholder: {
      ProgressView()
    }
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack(alignment: .top, spacing: 12) {
        if event.imageURL != nil {
          //        image
        }
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
  }
}

struct TitleView: View {
  let title: String

  var body: some View {
    Text(title)
      .font(.title3.monospaced().bold())
      .foregroundStyle(LinearGradient.title)
  }
}

struct MonthAndDayView: View {
  let day: String?
  let month: String

  var body: some View {
    if let day = day {
      Text("\(month) \(day)")
        .font(.body.monospaced().bold())
        .foregroundStyle(LinearGradient.monthAndDay)
    }
  }
}

struct LabelsStack: View {
  enum Stack {
    case vertical(HorizontalAlignment)
    case horizontal
  }

  let labels: [Event.EventLabel]
  let stack: Stack
  @Binding var selectedLabels: [Event.EventLabel]
  @ScaledMetric var horizontalPadding = 8
  @ScaledMetric var verticalPadding = 4

  func content() -> some View {
    ForEach(labels, id: \.self) { label in
      Text(label.rawValue)
        .lineLimit(1)
        .font(.caption.monospaced().bold())
        .foregroundColor(.white)
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, verticalPadding)
        .background(
          Capsule(style: .continuous)
            .foregroundColor(label.color)
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
      HStack(spacing: 12) {
        content()
      }
    case .vertical(let alignment):
      VStack(alignment: alignment, spacing: 12) {
        content()
      }
    }
  }
}

import Combine
import SplebbosNetworking

final class ViewModel: ObservableObject {
  enum State {
    case idle
    case loading
    case loaded([Event])
    case failed(Error)
  }
  private let session = URLSession.shared
  private let loadResource = Resource(host: Resource.host, path: Resource.path)
  private let refreshResource = Resource(host: Resource.host, path: Resource.path, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
  private var cancellable: AnyCancellable?
  @Published var state: State = .idle

  func getEvents() {
    cancellable = session.decodablePublisher(for: loadResource, decoder: .events)
      .handleEvents(receiveSubscription: { _ in self.state = .loading })
      .map { (events: [Event]) in State.loaded(events.sorted()) }
      .catch { Just(.failed($0)) }
      .assign(to: \.state, on: self)
  }

  @Sendable func refreshEvents() {
    cancellable = session.decodablePublisher(for: refreshResource, decoder: .events)
      .handleEvents(receiveOutput: { _ in WidgetCenter.shared.reloadAllTimelines() })
      .map { (events: [Event]) in State.loaded(events.sorted()) }
      .catch { Just(.failed($0)) }
      .assign(to: \.state, on: self)
  }
}



extension Array where Element == Event {
  func filtered(text: String, labels: [Event.EventLabel]) -> [Element] {
    let text = text.trimmingCharacters(in: .whitespaces).lowercased()
    let textFilter = filter {
      $0.primaryName.lowercased().contains(text) ||
      $0.secondaryName?.lowercased().contains(text) == true ||
      $0.fullmonth.lowercased().contains(text) ||
      $0.fullDay?.lowercased().contains(text) == true ||
      $0.dateComponents.year.flatMap { String($0).lowercased().contains(text) } == true ||
      $0.labels.map { $0.rawValue }.joined().lowercased().contains(text)
    }
    if text.isEmpty {
      if labels.isEmpty {
        return self
      } else {
        return filter { Set(labels).isSubset(of: Set($0.labels)) }
      }
    } else {
      if labels.isEmpty {
        return textFilter
      } else {
        return textFilter
          .filter { Set(labels).isSubset(of: Set($0.labels)) }
      }
    }
  }

  func sorted() -> [Element] {
    sorted { $0.daysBeforeNextEvent ?? .max < $1.daysBeforeNextEvent ?? .max }
  }
}

extension Calendar {
  static var event: Calendar {
    var calendar = Calendar.current
    if let gmtTimeZone = TimeZone.gmt {
      calendar.timeZone = gmtTimeZone
    }
    return calendar
  }
}

extension TimeZone {
  static let gmt = TimeZone(secondsFromGMT: 0)
}

extension Resource {
  static let host = "sebthibert.github.io"
  static let path = "/api/events.json"
}

extension JSONDecoder {
  static let events = decoderWith(.useDefaultKeys, .secondsSince1970)
}


extension URLSession {
  static func getEvents() async -> Result<[Event], Error> {
    let resource = Resource(host: Resource.host, path: Resource.path, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
    return await shared.decodable(for: resource, decoder: .events)
  }

  static func getWidgetEvents(completion: @escaping (Result<[Event], Error>) -> Void) {
    let resource = Resource(host: Resource.host, path: Resource.path, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
    shared.decodableTask(for: resource, decoder: .events, completion: completion)
  }
}

struct Event: Decodable, Identifiable {
  let primaryName: String
  let secondaryName: String?
  let timestamp: Date
  let type: EventType
  let imageURL: URL?
  let labels: [EventLabel]

  var id: String {
    primaryName + timestamp.description + type.rawValue
  }
}

extension Event {
  enum EventType: String, Decodable {
    case birthday
    case anniversary
  }

  enum EventLabel: String, Decodable {
    case family
    case friends
    case love
    case rgm

    var color: Color {
      switch self {
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
  }
}

extension Event {
  private func gmt(dateFormat: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = .gmt
    dateFormatter.dateFormat = dateFormat
    return dateFormatter.string(from: timestamp)
  }
}

extension Event {
  var title: String {
    switch type {
    case .birthday:
      return "\(primaryName)'s Birthday"
    case .anniversary:
      if let secondaryName = secondaryName {
        return "\(primaryName) & \(secondaryName)'s Anniversary"
      } else {
        return "\(primaryName)'s Anniversary"
      }
    }
  }

  private var timestampDateComponents: DateComponents {
    Calendar.event.dateComponents([.day, .month], from: timestamp)
  }

  var day: String? {
    guard let day = timestampDateComponents.day else {
      return nil
    }
    return String(format: "%02d", day)
  }

  var fullDay: String? {
    guard let day = timestampDateComponents.day else {
      return nil
    }
    switch day {
    case 1, 21, 31:
      return "\(day)st"
    case 2, 22:
      return "\(day)nd"
    case 3, 23:
      return "\(day)rd"
    default:
      return "\(day)th"
    }
  }

  var shortMonth: String {
    gmt(dateFormat: "MMM")
  }

  var fullmonth: String {
    gmt(dateFormat: "MMMM")
  }

  var dateComponents: DateComponents {
    Calendar.event.dateComponents([.day, .month, .year], from: timestamp)
  }
  

  private var yearsSinceTimestamp: Int? {
    Calendar.event.dateComponents([.year], from: timestamp, to: Date()).year
  }

  var yearsSince: String? {
    guard let year = dateComponents.year, let yearsSinceTimestamp = yearsSinceTimestamp else {
      return nil
    }
    switch yearsSinceTimestamp {
    case 0:
      return "\(year): 0 years"
    case 1:
      return "\(year): 1 year"
    default:
      return "\(year): \(yearsSinceTimestamp) years"
    }
  }

  var daysBefore: String? {
    guard let daysBeforeNextEvent = daysBeforeNextEvent else {
      return nil
    }
    switch daysBeforeNextEvent {
    case 0:
      return "Today"
    case 1:
      return "1 day"
    default:
      return "\(daysBeforeNextEvent) days"
    }
  }

  func currentYear(currentDate: Date) -> Int? {
    Calendar.event.dateComponents([.year], from: currentDate).year
  }

  func daysBeforeEventThisYear(currentDate: Date) -> Int? {
    guard let currentYear = currentYear(currentDate: currentDate) else {
      return nil
    }
    var timestampDateComponents = self.timestampDateComponents
    timestampDateComponents.year = currentYear
    guard let eventDateThisYear = Calendar.event.date(from: timestampDateComponents) else {
      return nil
    }
    return Calendar.event.dateComponents([.day], from: currentDate, to: eventDateThisYear).day
  }

  var daysBeforeNextEvent: Int? {
    let currentDate = Date()
    guard let currentYear = currentYear(currentDate: currentDate) else {
      return nil
    }
    var timestampDateComponents = self.timestampDateComponents
    timestampDateComponents.year = currentYear
    guard let daysBeforeEventThisYear = daysBeforeEventThisYear(currentDate: currentDate) else {
      return nil
    }
    if daysBeforeEventThisYear >= 0 {
      return daysBeforeEventThisYear
    } else {
      let nextYear = currentYear + 1
      timestampDateComponents.year = nextYear
      guard let eventDateNextYear = Calendar.event.date(from: timestampDateComponents) else {
        return nil
      }
      return Calendar.event.dateComponents([.day], from: currentDate, to: eventDateNextYear).day
    }
  }
}
