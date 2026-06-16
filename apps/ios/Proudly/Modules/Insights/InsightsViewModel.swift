//
//  InsightsViewModel.swift
//  Proudly
//
//  Created by Arnolfo Federis on 6/11/26.
//

import Foundation
import Observation

@Observable
final class InsightsViewModel {
  private(set) var weeklyData: [DayData] = []
  private(set) var currentStreak: Int = 0
  private(set) var topHabit: String = "—"

  var totalCompletions: Int { weeklyData.reduce(0) { $0 + $1.count } }
  var maxDailyCount: Int { weeklyData.map(\.count).max() ?? 0 }

  func update(habits: [Habit]) {
    let cal = Calendar.current
    let fmt = DateFormatter()
    fmt.dateFormat = "yyyy-MM-dd"
    let dayAbbrevs = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    weeklyData = (0..<7).reversed().map { offset in
      let date = cal.date(byAdding: .day, value: -offset, to: .now) ?? .now
      let key = fmt.string(from: date)
      let count = habits.filter { $0.completedDates.contains(key) }.count
      let weekdayIndex = cal.component(.weekday, from: date) - 1
      return DayData(day: dayAbbrevs[weekdayIndex], count: count)
    }

    currentStreak = habits.map(\.streak).max() ?? 0

    let last7Keys: Set<String> = Set(
      (0..<7).map { offset in
        let date = cal.date(byAdding: .day, value: -offset, to: .now) ?? .now
        return fmt.string(from: date)
      })

    topHabit =
      habits
      .max {
        $0.completedDates.intersection(last7Keys).count
          < $1.completedDates.intersection(last7Keys).count
      }
      .map(\.name) ?? "—"
  }

  struct DayData: Identifiable {
    let id = UUID()
    let day: String
    let count: Int
  }
}
