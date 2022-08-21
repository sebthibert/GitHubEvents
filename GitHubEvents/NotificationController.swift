import UserNotifications

struct NotificationController {
  static let center = UNUserNotificationCenter.current()

  static func requestAuthorization() async {
    let options: UNAuthorizationOptions = [.alert, .badge, .sound]
    do { try await center.requestAuthorization(options: options) }
    catch { print(error.localizedDescription) }
  }

  static func resetNotifications(events: [Event]) async {
    let pendingRequests = await getPendingNotificationRequests()
    let (oldRequestIDs, newEvents) = events.split(pendingRequests: pendingRequests)
    center.removePendingNotificationRequests(withIdentifiers: Array(oldRequestIDs))
    newEvents.forEach { addNotification(for: $0) }
  }

  static func getPendingNotificationRequests() async ->  [UNNotificationRequest] {
    await withCheckedContinuation { continuation in
      center.getPendingNotificationRequests { requests in
        continuation.resume(returning: requests)
      }
    }
  }

  private static func addNotification(for event: Event) {
    let content = UNMutableNotificationContent()
    content.title = event.title
    content.subtitle = "Today's the day!"
    content.sound = UNNotificationSound.default
    var dateComponents = DateComponents()
    dateComponents.setValue(event.dateComponents.month, for: .month)
    dateComponents.setValue(event.dateComponents.day, for: .day)
    dateComponents.setValue(9, for: .hour)
    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
    let request = UNNotificationRequest(
      identifier: event.id,
      content: content,
      trigger: trigger
    )
    center.add(request)
  }
}
