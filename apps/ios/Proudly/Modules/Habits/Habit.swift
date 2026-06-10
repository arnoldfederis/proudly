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

extension Habit: Hashable {
  func hash(into hasher: inout Hasher) { hasher.combine(id) }
  // completedDates is included so SwiftUI detects the visual state change and re-renders rows
  static func == (lhs: Habit, rhs: Habit) -> Bool {
    lhs.id == rhs.id && lhs.completedDates == rhs.completedDates
  }
}

extension Habit {
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
