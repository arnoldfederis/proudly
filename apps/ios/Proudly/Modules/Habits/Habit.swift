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
  var note: String
  var reminder: String?

  var isCompletedToday: Bool {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return completedDates.contains(formatter.string(from: Date()))
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
      && lhs.note == rhs.note
      && lhs.reminder == rhs.reminder
      && lhs.completedDates == rhs.completedDates
  }
}

extension Habit {
  var streakLabel: String { streak.proudlyStreakLabel }
  var bestStreakLabel: String { bestStreak.proudlyStreakLabel }

  static let samples: [Habit] = [
    Habit(
      id: UUID(), name: "Drink water", icon: "drop.fill",
      color: ProudlyTheme.blue, streak: 7, bestStreak: 14,
      completedDates: [], note: "Stay hydrated all day"
    ),
    Habit(
      id: UUID(), name: "Walk 10 minutes", icon: "figure.walk",
      color: ProudlyTheme.mint, streak: 12, bestStreak: 18,
      completedDates: [], note: "A short walk clears the mind"
    ),
    Habit(
      id: UUID(), name: "Read 10 pages", icon: "book.fill",
      color: ProudlyTheme.purple, streak: 5, bestStreak: 21,
      completedDates: [], note: "Feed your mind daily"
    ),
  ]
}
