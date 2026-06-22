//
//  OnboardingStep.swift
//  Proudly
//
//  Created by Arnolfo Federis on 6/16/26.
//

import Foundation

enum OnboardingStep: Int, CaseIterable {
  case welcome
  case icon
  case userName
  case name
  case description
  case color
  case frequency
  case reminder
  case focusTimer
  case permission
  case celebration

  static let inputSteps: [OnboardingStep] = [
    .userName,
    .icon,
    .name,
    .description,
    .color,
    .frequency,
    .reminder,
    .focusTimer,
    .permission,
  ]

  var title: String {
    switch self {
    case .welcome:
      return "Welcome"
    case .icon:
      return "Pick an icon"
    case .userName:
      return "Your name"
    case .name:
      return "Name your habit"
    case .description:
      return "Why it matters"
    case .color:
      return "Choose a color"
    case .frequency:
      return "Set a daily goal"
    case .reminder:
      return "Choose reminders"
    case .focusTimer:
      return "Focus Timer"
    case .permission:
      return "Stay reminded"
    case .celebration:
      return "You're ready"
    }
  }
}

enum OnboardingReminderOption: String, CaseIterable, Identifiable {
  case none
  case morning
  case afternoon
  case evening
  case custom

  var id: String { rawValue }

  var title: String {
    switch self {
    case .none:
      return "No reminder"
    case .morning:
      return "Morning"
    case .afternoon:
      return "Afternoon"
    case .evening:
      return "Evening"
    case .custom:
      return "Custom time"
    }
  }

  var subtitle: String {
    switch self {
    case .none:
      return "Keep things simple for now."
    case .morning:
      return "A soft start around 9:00 AM."
    case .afternoon:
      return "A gentle nudge later in the day."
    case .evening:
      return "A quiet wrap-up reminder."
    case .custom:
      return "Choose a time that fits your rhythm."
    }
  }
}
