//
//  HabitsViewModel.swift
//  Proudly
//
//  Created by Arnolfo Federis on 6/11/26.
//

import Foundation
import Observation

@Observable
final class HabitsViewModel {
  var habits: [Habit] = Habit.samples
  var filter: HabitFilter = .all

  enum HabitFilter: String, CaseIterable {
    case all = "All"
    case active = "Active"
    case completed = "Completed"
  }

  var filteredHabits: [Habit] {
    switch filter {
    case .all: return habits
    case .active: return habits.filter { !$0.isCompletedToday }
    case .completed: return habits.filter { $0.isCompletedToday }
    }
  }

  func toggleCompletion(for habit: Habit) {
    guard let index = habits.firstIndex(where: { $0.id == habit.id }) else { return }
    let key = dateKey(for: .now)
    if habits[index].completedDates.contains(key) {
      habits[index].completedDates.remove(key)
    } else {
      habits[index].completedDates.insert(key)
    }
  }

  private func dateKey(for date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: date)
  }
}
