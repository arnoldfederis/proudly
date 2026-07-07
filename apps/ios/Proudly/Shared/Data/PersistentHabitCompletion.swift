//
//  PersistentHabitCompletion.swift
//  Proudly
//
//  Created by Arnolfo Federis on 6/15/26.
//

import Foundation
import SwiftData

@Model
final class PersistentHabitCompletion {
  var id: UUID = UUID()
  var habitId: UUID = UUID()
  /// Format: "yyyy-MM-dd". Repository keeps at most one row per habit per date.
  var dateKey: String = ""
  var count: Int = 1
  var completedAt: Date = Date.now
  var habit: PersistentHabit?

  init(habitId: UUID, dateKey: String, count: Int = 1, completedAt: Date = .now) {
    self.id = UUID()
    self.habitId = habitId
    self.dateKey = dateKey
    self.count = count
    self.completedAt = completedAt
  }
}
