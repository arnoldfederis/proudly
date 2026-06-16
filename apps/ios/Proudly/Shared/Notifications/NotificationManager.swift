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
    default:
      return ["08:00", "12:00", "16:00", "20:00"]
    }
  }

  static func generatedReminderTimes(for dailyTargetCount: Int, firstTime: Date) -> [String] {
    let calendar = Calendar.current
    let count = max(dailyTargetCount, 1)
    let intervalsByCount: [Int: Int] = [2: 9, 3: 5, 4: 4]
    let intervalHours = intervalsByCount[count] ?? 4

    return (0..<count).compactMap { index in
      let date = calendar.date(byAdding: .hour, value: intervalHours * index, to: firstTime)
      return date.map(Self.timeString(from:))
    }
  }

  static func timeString(from date: Date) -> String {
    let components = Calendar.current.dateComponents([.hour, .minute], from: date)
    return String(format: "%02d:%02d", components.hour ?? 9, components.minute ?? 0)
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
}
