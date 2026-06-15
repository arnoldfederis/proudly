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
  var id: UUID
  var habitId: UUID
  /// Format: "yyyy-MM-dd". One completion per habit per date.
  var dateKey: String
  var completedAt: Date
  var habit: PersistentHabit?

  init(habitId: UUID, dateKey: String, completedAt: Date = .now) {
    self.id = UUID()
    self.habitId = habitId
    self.dateKey = dateKey
    self.completedAt = completedAt
  }
}
