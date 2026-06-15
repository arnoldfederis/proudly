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
  var filter: HabitFilter = .all

  enum HabitFilter: String, CaseIterable {
    case all = "All"
    case active = "Active"
    case completed = "Completed"
  }

  func filteredHabits(from habits: [Habit]) -> [Habit] {
    switch filter {
    case .all: return habits
    case .active: return habits.filter { !$0.isCompletedToday }
    case .completed: return habits.filter { $0.isCompletedToday }
    }
  }
}
