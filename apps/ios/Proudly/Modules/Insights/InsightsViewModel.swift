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
  var weeklyData: [DayData] = [
    DayData(day: "Mon", count: 2),
    DayData(day: "Tue", count: 3),
    DayData(day: "Wed", count: 1),
    DayData(day: "Thu", count: 3),
    DayData(day: "Fri", count: 2),
    DayData(day: "Sat", count: 3),
    DayData(day: "Sun", count: 2),
  ]
  var currentStreak: Int = 12
  var topHabit: String = "Walk 10 minutes"

  var totalCompletions: Int { weeklyData.reduce(0) { $0 + $1.count } }
  var maxDailyCount: Int { weeklyData.map(\.count).max() ?? 0 }

  struct DayData: Identifiable {
    let id = UUID()
    let day: String
    let count: Int
  }
}
