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
  var reminderHour: Int?
  var reminderMinute: Int?
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
    reminderHour: Int? = nil,
    reminderMinute: Int? = nil,
    createdAt: Date = .now,
    updatedAt: Date = .now,
    isArchived: Bool = false
  ) {
    self.id = id
    self.name = name
    self.icon = icon
    self.colorHex = colorHex
    self.note = note
    self.reminderHour = reminderHour
    self.reminderMinute = reminderMinute
    self.createdAt = createdAt
    self.updatedAt = updatedAt
    self.isArchived = isArchived
  }
}
