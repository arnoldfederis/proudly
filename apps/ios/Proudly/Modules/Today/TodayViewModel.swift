//
//  TodayViewModel.swift
//  Proudly
//
//  Created by Arnolfo Federis on 6/11/26.
//

import Foundation
import Observation
import UIKit

@Observable
final class TodayViewModel {
  var habits: [Habit] = Habit.samples

  var completedCount: Int { habits.filter(\.isCompletedToday).count }
  var totalCount: Int { habits.count }
  var progressRatio: Double {
    guard totalCount > 0 else { return 0 }
    return Double(completedCount) / Double(totalCount)
  }

  func toggleCompletion(for habit: Habit) {
    guard let index = habits.firstIndex(where: { $0.id == habit.id }) else { return }
    let key = dateKey(for: .now)
    if habits[index].completedDates.contains(key) {
      habits[index].completedDates.remove(key)
    } else {
      habits[index].completedDates.insert(key)
      Haptics.notification(.success)
    }
  }

  func addHabit(_ habit: Habit) {
    habits.insert(habit, at: 0)
  }

  func updateHabit(_ habit: Habit) {
    guard let index = habits.firstIndex(where: { $0.id == habit.id }) else { return }
    habits[index] = habit
  }

  private func dateKey(for date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: date)
  }
}
