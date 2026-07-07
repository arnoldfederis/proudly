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

  private(set) var thisWeekTotal: Int = 0
  private(set) var lastWeekTotal: Int = 0
  private(set) var weekdayPattern: [WeekdayBucket] = []
  private(set) var consistencyPercent: Int = 0
  private(set) var heatmapCells: [HeatmapCell] = []

  var totalCompletions: Int { weeklyData.reduce(0) { $0 + $1.count } }
  var maxDailyCount: Int { weeklyData.map(\.count).max() ?? 0 }

  var momentumDelta: Int { thisWeekTotal - lastWeekTotal }
  var momentumPercent: Int {
    guard lastWeekTotal > 0 else { return thisWeekTotal > 0 ? 100 : 0 }
    return Int((Double(momentumDelta) / Double(lastWeekTotal)) * 100)
  }

  func update(habits allHabits: [Habit], selectedHabitID: UUID? = nil) {
    let habits: [Habit]
    if let selectedHabitID, let match = allHabits.first(where: { $0.id == selectedHabitID }) {
      habits = [match]
    } else {
      habits = allHabits
    }
    let cal = Calendar.current
    let fmt = DateFormatter()
    fmt.dateFormat = "yyyy-MM-dd"
    let dayAbbrevs = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    weeklyData = (0..<7).reversed().map { offset in
      let date = cal.date(byAdding: .day, value: -offset, to: .now) ?? .now
      let key = fmt.string(from: date)
      let count = habits.filter { $0.completedDates.contains(key) }.count
      let weekdayIndex = cal.component(.weekday, from: date) - 1
      return DayData(id: key, day: dayAbbrevs[weekdayIndex], count: count)
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

    thisWeekTotal = weeklyData.reduce(0) { $0 + $1.count }

    let priorWeekKeys: [String] = (7..<14).map { offset in
      let date = cal.date(byAdding: .day, value: -offset, to: .now) ?? .now
      return fmt.string(from: date)
    }
    lastWeekTotal = priorWeekKeys.reduce(0) { total, key in
      total + habits.filter { $0.completedDates.contains(key) }.count
    }

    var weekdayCounts = Array(repeating: 0, count: 7)
    let last30Keys: [(String, Int)] = (0..<30).map { offset in
      let date = cal.date(byAdding: .day, value: -offset, to: .now) ?? .now
      let weekdayIndex = cal.component(.weekday, from: date) - 1
      return (fmt.string(from: date), weekdayIndex)
    }
    for (key, weekdayIndex) in last30Keys {
      let count = habits.filter { $0.completedDates.contains(key) }.count
      weekdayCounts[weekdayIndex] += count
    }
    let orderedIndices = (0..<7).map { (cal.firstWeekday - 1 + $0) % 7 }
    weekdayPattern = orderedIndices.map { idx in
      WeekdayBucket(
        id: "wd-\(idx)", day: dayAbbrevs[idx], count: weekdayCounts[idx])
    }

    let habitCount = max(habits.count, 1)
    let daysWithAny = last30Keys.filter { key, _ in
      habits.contains { $0.completedDates.contains(key) }
    }.count
    consistencyPercent = Int(Double(daysWithAny) / 30.0 * 100)

    let today = cal.startOfDay(for: .now)
    var cells: [HeatmapCell] = []
    for offset in (0..<180).reversed() {
      guard let date = cal.date(byAdding: .day, value: -offset, to: today) else { continue }
      let key = fmt.string(from: date)
      let count = habits.filter { $0.completedDates.contains(key) }.count
      let ratio = min(Double(count) / Double(habitCount), 1)
      cells.append(HeatmapCell(id: key, date: date, count: count, ratio: ratio))
    }
    heatmapCells = cells
  }

  struct DayData: Identifiable {
    let id: String
    let day: String
    let count: Int
  }

  struct WeekdayBucket: Identifiable {
    let id: String
    let day: String
    let count: Int
  }

  struct HeatmapCell: Identifiable {
    let id: String
    let date: Date
    let count: Int
    let ratio: Double
  }
}
