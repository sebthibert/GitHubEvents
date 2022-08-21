import UserNotifications

struct NotificationController {
  static let center = UNUserNotificationCenter.current()

  static func requestAndSetNotifications(events: [Event]) async {
    do {
      if try await requestAuthorization() {
        await setNotifications(events: events)
      }
    }
    catch { print(error.localizedDescription) }
  }

  private static func requestAuthorization() async throws -> Bool {
    let settings = await settings()
    guard settings.authorizationStatus == .notDetermined else { return false }
    let options: UNAuthorizationOptions = [.alert, .badge, .sound]
    return try await center.requestAuthorization(options: options)
  }

  static func setNotifications(events: [Event]) async {
    let settings = await settings()
    guard settings.authorizationStatus == .authorized else { return }
    let pendingRequests = await pendingRequests()
    let (oldRequestIDs, newEvents) = events.split(pendingRequests: pendingRequests)
    center.removePendingNotificationRequests(withIdentifiers: Array(oldRequestIDs))
    newEvents.forEach { addNotification(for: $0) }
  }

  private static func settings() async -> UNNotificationSettings {
    await withCheckedContinuation { continuation in
      center.getNotificationSettings { settings in
        continuation.resume(returning: settings)
      }
    }
  }

  private static func pendingRequests() async ->  [UNNotificationRequest] {
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
