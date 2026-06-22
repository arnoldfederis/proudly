//
//  NotificationManager.swift
//  Proudly
//
//  Created by Arnolfo Federis on 6/16/26.
//

import Foundation
import UserNotifications

@MainActor
final class NotificationManager {
  static let shared = NotificationManager()
  private static let reminderDisplayFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "h:mm a"
    return formatter
  }()

  private let center = UNUserNotificationCenter.current()

  private init() {}

  func authorizationStatus() async -> UNAuthorizationStatus {
    let settings = await center.notificationSettings()
    return settings.authorizationStatus
  }

  func requestAuthorizationIfNeeded() async -> Bool {
    let status = await authorizationStatus()

    switch status {
    case .authorized, .ephemeral, .provisional:
      return true
    case .denied:
      return false
    case .notDetermined:
      return (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
    @unknown default:
      return false
    }
  }

  func scheduleReminders(for habit: Habit) async {
    await cancelReminders(for: habit.id)

    guard habit.remindersEnabled else { return }

    for (index, timeString) in habit.reminderTimes.enumerated() {
      guard let components = Self.timeComponents(from: timeString) else { continue }

      let content = UNMutableNotificationContent()
      content.title = habit.name
      content.body =
        habit.dailyTargetCount > 1
        ? "A small step counts. Check in with \(habit.name)."
        : "A small win is waiting for you."
      content.sound = .default
      content.userInfo = ["habitID": habit.id.uuidString]

      let trigger = UNCalendarNotificationTrigger(
        dateMatching: DateComponents(hour: components.hour, minute: components.minute),
        repeats: true
      )

      let request = UNNotificationRequest(
        identifier: Self.identifier(for: habit.id, index: index),
        content: content,
        trigger: trigger
      )

      try? await center.add(request)
    }
  }

  func cancelReminders(for habitID: UUID) async {
    let prefix = Self.identifierPrefix(for: habitID)
    let pending = await center.pendingNotificationRequests()
      .map(\.identifier)
      .filter { $0.hasPrefix(prefix) }

    center.removePendingNotificationRequests(withIdentifiers: pending)
    center.removeDeliveredNotifications(withIdentifiers: pending)
  }

  static func defaultReminderTimes(for dailyTargetCount: Int) -> [String] {
    switch max(dailyTargetCount, 1) {
    case 1:
      return ["09:00"]
    case 2:
      return ["09:00", "18:00"]
    case 3:
      return ["09:00", "14:00", "19:00"]
    case 4:
      return ["08:00", "12:00", "16:00", "20:00"]
    default:
      return evenlyDistributedReminderTimes(for: dailyTargetCount)
    }
  }

  static func generatedReminderTimes(for dailyTargetCount: Int, firstTime: Date) -> [String] {
    let calendar = Calendar.current
    let count = max(dailyTargetCount, 1)
    let firstString = Self.timeString(from: firstTime)

    guard count > 1 else { return [firstString] }

    let intervalsByCount: [Int: Int] = [2: 9, 3: 5, 4: 4]
    let defaultStepMinutes = (intervalsByCount[count] ?? 4) * 60

    let firstHour = calendar.component(.hour, from: firstTime)
    let firstMinute = calendar.component(.minute, from: firstTime)
    let firstMinutes = firstHour * 60 + firstMinute
    let endMinutes = 23 * 60 + 59
    let maxStepMinutes = max((endMinutes - firstMinutes) / (count - 1), 1)
    let stepMinutes = min(defaultStepMinutes, maxStepMinutes)

    return (0..<count).map { index in
      let totalMinutes = min(firstMinutes + stepMinutes * index, endMinutes)
      let hour = totalMinutes / 60
      let minute = totalMinutes % 60
      return String(format: "%02d:%02d", hour, minute)
    }
  }

  static func timeString(from date: Date) -> String {
    let components = Calendar.current.dateComponents([.hour, .minute], from: date)
    return String(format: "%02d:%02d", components.hour ?? 9, components.minute ?? 0)
  }

  static func displayTimeString(from timeString: String) -> String {
    guard
      let date = timeComponents(from: timeString).flatMap({
        Calendar.current.date(from: DateComponents(hour: $0.hour, minute: $0.minute))
      })
    else {
      return timeString
    }

    return reminderDisplayFormatter.string(from: date)
  }

  static func displayTimeStrings(from timeStrings: [String]) -> [String] {
    timeStrings.map(displayTimeString(from:))
  }

  private static func evenlyDistributedReminderTimes(for dailyTargetCount: Int) -> [String] {
    let count = max(dailyTargetCount, 1)
    let startMinutes = 8 * 60
    let endMinutes = 20 * 60

    guard count > 1 else {
      return ["09:00"]
    }

    let step = Double(endMinutes - startMinutes) / Double(count - 1)

    return (0..<count).map { index in
      let totalMinutes = Int((Double(startMinutes) + (step * Double(index))).rounded())
      let hour = totalMinutes / 60
      let minute = totalMinutes % 60
      return String(format: "%02d:%02d", hour, minute)
    }
  }

  static func reminderDate(from timeString: String?) -> Date {
    guard let timeString, let components = timeComponents(from: timeString) else {
      return defaultReminderDate
    }

    var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: .now)
    dateComponents.hour = components.hour
    dateComponents.minute = components.minute
    return Calendar.current.date(from: dateComponents) ?? defaultReminderDate
  }

  static func timeComponents(from timeString: String) -> DateComponents? {
    let parts = timeString.split(separator: ":")
    guard parts.count == 2,
      let hour = Int(parts[0]),
      let minute = Int(parts[1])
    else {
      return nil
    }

    return DateComponents(hour: hour, minute: minute)
  }

  private static func identifier(for habitID: UUID, index: Int) -> String {
    "\(identifierPrefix(for: habitID))-\(index)"
  }

  private static func identifierPrefix(for habitID: UUID) -> String {
    "proudly.habit.\(habitID.uuidString)"
  }

  private static var defaultReminderDate: Date {
    var components = Calendar.current.dateComponents([.year, .month, .day], from: .now)
    components.hour = 9
    components.minute = 0
    return Calendar.current.date(from: components) ?? .now
  }

  // MARK: - Focus Timer notifications

  func scheduleFocusComplete(habitID: UUID, habitName: String, fireAt date: Date) async {
    await cancelFocusComplete(habitID: habitID)

    let granted = await requestAuthorizationIfNeeded()
    guard granted else { return }

    let interval = max(date.timeIntervalSinceNow, 1)
    let content = UNMutableNotificationContent()
    content.title = "Focus complete"
    content.body = "Your \(habitName) session is done. Mark it complete when you're ready."
    content.sound = .default
    content.userInfo = [
      "habitID": habitID.uuidString,
      "kind": "focusComplete",
    ]

    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
    let request = UNNotificationRequest(
      identifier: Self.focusIdentifier(for: habitID),
      content: content,
      trigger: trigger
    )

    try? await center.add(request)
  }

  func cancelFocusComplete(habitID: UUID) async {
    let identifier = Self.focusIdentifier(for: habitID)
    center.removePendingNotificationRequests(withIdentifiers: [identifier])
    center.removeDeliveredNotifications(withIdentifiers: [identifier])
  }

  static func focusIdentifier(for habitID: UUID) -> String {
    "proudly.focus.\(habitID.uuidString)"
  }
}
