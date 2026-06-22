//
//  PersistentHabit.swift
//  Proudly
//
//  Created by Arnolfo Federis on 6/15/26.
//

import Foundation
import SwiftData

@Model
final class PersistentHabit {
  var id: UUID
  var name: String
  var icon: String
  var colorHex: String
  var note: String
  var dailyTargetCount: Int
  var remindersEnabled: Bool
  var reminderTimes: String
  var reminderHour: Int?
  var reminderMinute: Int?
  /// Decoupled from `dailyTargetCount`. Optional so legacy rows can fall
  /// back to the count derived from `reminderTimes`.
  var reminderCount: Int?
  /// Optional Focus Timer duration in minutes. `nil` means the habit has
  /// no Focus Timer configured.
  var focusDurationMinutes: Int?
  var createdAt: Date
  var updatedAt: Date
  var isArchived: Bool

  @Relationship(deleteRule: .cascade, inverse: \PersistentHabitCompletion.habit)
  var completions: [PersistentHabitCompletion] = []

  init(
    id: UUID = UUID(),
    name: String,
    icon: String,
    colorHex: String,
    note: String = "",
    dailyTargetCount: Int = 1,
    remindersEnabled: Bool = false,
    reminderTimes: String = "",
    reminderHour: Int? = nil,
    reminderMinute: Int? = nil,
    reminderCount: Int? = nil,
    focusDurationMinutes: Int? = nil,
    createdAt: Date = .now,
    updatedAt: Date = .now,
    isArchived: Bool = false
  ) {
    self.id = id
    self.name = name
    self.icon = icon
    self.colorHex = colorHex
    self.note = note
    self.dailyTargetCount = dailyTargetCount
    self.remindersEnabled = remindersEnabled
    self.reminderTimes = reminderTimes
    self.reminderHour = reminderHour
    self.reminderMinute = reminderMinute
    self.reminderCount = reminderCount
    self.focusDurationMinutes = focusDurationMinutes
    self.createdAt = createdAt
    self.updatedAt = updatedAt
    self.isArchived = isArchived
  }
}
