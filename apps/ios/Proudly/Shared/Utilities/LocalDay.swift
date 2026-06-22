//
//  LocalDay.swift
//  Proudly
//

import Foundation

/// Authoritative source of "today" for habit tracking. Uses the device's
/// auto-updating local timezone and Gregorian calendar so checklist state
/// rolls over at local midnight regardless of how the underlying APIs
/// would otherwise behave (e.g. UTC for an unconfigured DateFormatter).
enum LocalDay {
  static var calendar: Calendar {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = .autoupdatingCurrent
    calendar.locale = Locale(identifier: "en_US_POSIX")
    return calendar
  }

  private static let keyFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: .gregorian)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = .autoupdatingCurrent
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter
  }()

  static func key(for date: Date = .now) -> String {
    keyFormatter.string(from: startOfDay(for: date))
  }

  static func date(fromKey key: String) -> Date? {
    guard let parsed = keyFormatter.date(from: key) else { return nil }
    return startOfDay(for: parsed)
  }

  static func startOfDay(for date: Date = .now) -> Date {
    calendar.startOfDay(for: date)
  }

  static func nextMidnight(after date: Date = .now) -> Date {
    calendar.date(byAdding: .day, value: 1, to: startOfDay(for: date))
      ?? date.addingTimeInterval(86_400)
  }

  static func timeUntilNextMidnight(from date: Date = .now) -> TimeInterval {
    max(nextMidnight(after: date).timeIntervalSince(date), 0)
  }

  static func date(byAddingDays days: Int, to date: Date = .now) -> Date {
    calendar.date(byAdding: .day, value: days, to: date) ?? date
  }

  static func daysBetween(_ start: Date, _ end: Date) -> Int {
    calendar.dateComponents([.day], from: startOfDay(for: start), to: startOfDay(for: end)).day ?? 0
  }
}
