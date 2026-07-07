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
  var id: UUID = UUID()
  var name: String = ""
  var icon: String = ""
  var colorHex: String = ""
  var note: String = ""
  var dailyTargetCount: Int = 1
  var remindersEnabled: Bool = false
  var reminderTimes: String = ""
  var reminderHour: Int?
  var reminderMinute: Int?
  var reminderCount: Int?
  var focusDurationMinutes: Int?
  var createdAt: Date = Date.now
  var updatedAt: Date = Date.now
  var isArchived: Bool = false

  @Relationship(deleteRule: .nullify, inverse: \PersistentHabitCompletion.habit)
  var completions: [PersistentHabitCompletion]? = []

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
