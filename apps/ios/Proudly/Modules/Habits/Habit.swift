//
//  Habit.swift
//  Proudly
//
//  Created by Arnolfo Federis on 6/11/26.
//

import Foundation
import SwiftUI

struct Habit: Identifiable {
  let id: UUID
  var name: String
  var icon: String
  var color: Color
  var streak: Int
  var bestStreak: Int
  var completedDates: Set<String>
  var completionCountsByDate: [String: Int]
  var note: String
  var dailyTargetCount: Int
  var completedCountToday: Int
  var remindersEnabled: Bool
  var reminderTimes: [String]
  var reminderCount: Int
  var focusDurationMinutes: Int?

  var isCompletedToday: Bool {
    completedCountToday >= max(dailyTargetCount, 1)
  }

  var completionProgressToday: Double {
    min(Double(completedCountToday) / Double(max(dailyTargetCount, 1)), 1)
  }

  var todayProgressLabel: String {
    "\(completedCountToday)/\(max(dailyTargetCount, 1))"
  }

  var todayProgressPercentText: String {
    "\(Int((completionProgressToday * 100).rounded()))%"
  }

  var reminder: String? {
    reminderTimes.first
  }

  var hasFocusTimer: Bool {
    (focusDurationMinutes ?? 0) > 0
  }
}

extension Int {
  var proudlyDayUnit: String { self == 1 ? "day" : "days" }
  var proudlyDayPhrase: String { "\(self) \(proudlyDayUnit)" }
  var proudlyStreakLabel: String { "\(proudlyDayPhrase) streak" }
}

extension Habit: Hashable {
  func hash(into hasher: inout Hasher) { hasher.combine(id) }
  static func == (lhs: Habit, rhs: Habit) -> Bool {
    lhs.id == rhs.id
      && lhs.name == rhs.name
      && lhs.icon == rhs.icon
      && lhs.color == rhs.color
      && lhs.streak == rhs.streak
      && lhs.bestStreak == rhs.bestStreak
      && lhs.note == rhs.note
      && lhs.dailyTargetCount == rhs.dailyTargetCount
      && lhs.completedCountToday == rhs.completedCountToday
      && lhs.remindersEnabled == rhs.remindersEnabled
      && lhs.reminderTimes == rhs.reminderTimes
      && lhs.reminderCount == rhs.reminderCount
      && lhs.focusDurationMinutes == rhs.focusDurationMinutes
      && lhs.completedDates == rhs.completedDates
      && lhs.completionCountsByDate == rhs.completionCountsByDate
  }
}

extension Habit {
  var streakLabel: String { streak.proudlyStreakLabel }
  var bestStreakLabel: String { bestStreak.proudlyStreakLabel }

  static let samples: [Habit] = [
    Habit(
      id: UUID(), name: "Drink water", icon: "drop.fill",
      color: ProudlyTheme.blue, streak: 7, bestStreak: 14,
      completedDates: [],
      completionCountsByDate: [:],
      note: "Stay hydrated all day",
      dailyTargetCount: 1,
      completedCountToday: 0,
      remindersEnabled: false,
      reminderTimes: [],
      reminderCount: 1,
      focusDurationMinutes: nil
    ),
    Habit(
      id: UUID(), name: "Walk 10 minutes", icon: "figure.walk",
      color: ProudlyTheme.mint, streak: 12, bestStreak: 18,
      completedDates: [],
      completionCountsByDate: [:],
      note: "A short walk clears the mind",
      dailyTargetCount: 1,
      completedCountToday: 0,
      remindersEnabled: false,
      reminderTimes: [],
      reminderCount: 1,
      focusDurationMinutes: nil
    ),
    Habit(
      id: UUID(), name: "Read 10 pages", icon: "book.fill",
      color: ProudlyTheme.purple, streak: 5, bestStreak: 21,
      completedDates: [],
      completionCountsByDate: [:],
      note: "Feed your mind daily",
      dailyTargetCount: 1,
      completedCountToday: 0,
      remindersEnabled: false,
      reminderTimes: [],
      reminderCount: 1,
      focusDurationMinutes: 25
    ),
  ]
}
