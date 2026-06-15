//
//  ProudMoment.swift
//  Proudly
//
//  Created by Arnolfo Federis on 6/11/26.
//

import Foundation
import SwiftUI

struct ProudMoment: Identifiable {
  let id: String
  let habitName: String
  let icon: String
  let color: Color
  let date: Date
  let message: String
  let streak: Int
}

extension ProudMoment {
  static let samples: [ProudMoment] = [
    ProudMoment(
      id: "sample-1", habitName: "Walk 10 minutes", icon: "figure.walk",
      color: ProudlyTheme.mint, date: .now,
      message: "12-day streak! You're unstoppable.", streak: 12
    ),
    ProudMoment(
      id: "sample-2", habitName: "Read 10 pages", icon: "book.fill",
      color: ProudlyTheme.purple, date: .now,
      message: "Finished a chapter. Mind fuel!", streak: 5
    ),
    ProudMoment(
      id: "sample-3", habitName: "Drink water", icon: "drop.fill",
      color: ProudlyTheme.blue,
      date: Calendar.current.date(byAdding: .day, value: -1, to: .now)!,
      message: "Stayed hydrated all day!", streak: 7
    ),
  ]
}
