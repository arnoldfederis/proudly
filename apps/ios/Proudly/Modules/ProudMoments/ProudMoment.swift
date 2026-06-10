//
//  ProudMoment.swift
//  Proudly
//
//  Created by Arnolfo Federis on 6/11/26.
//

import Foundation

struct ProudMoment: Identifiable {
  let id: UUID
  let habitName: String
  let icon: String
  let date: Date
  let message: String
  let streak: Int
}

extension ProudMoment {
  static let samples: [ProudMoment] = [
    ProudMoment(
      id: UUID(), habitName: "Walk 10 minutes", icon: "figure.walk",
      date: .now,
      message: "12-day streak! You're unstoppable.", streak: 12
    ),
    ProudMoment(
      id: UUID(), habitName: "Read 10 pages", icon: "book.fill",
      date: .now,
      message: "Finished a chapter. Mind fuel!", streak: 5
    ),
    ProudMoment(
      id: UUID(), habitName: "Drink water", icon: "drop.fill",
      date: Calendar.current.date(byAdding: .day, value: -1, to: .now)!,
      message: "Stayed hydrated all day!", streak: 7
    ),
    ProudMoment(
      id: UUID(), habitName: "Walk 10 minutes", icon: "figure.walk",
      date: Calendar.current.date(from: DateComponents(year: 2026, month: 5, day: 20))!,
      message: "11 days in a row. Keep going!", streak: 11
    ),
    ProudMoment(
      id: UUID(), habitName: "Read 10 pages", icon: "book.fill",
      date: Calendar.current.date(from: DateComponents(year: 2026, month: 5, day: 19))!,
      message: "You make time for what matters.", streak: 4
    ),
  ]
}
