//
//  OnboardingViewModel.swift
//  Proudly
//
//  Created by Arnolfo Federis on 6/16/26.
//

import Foundation
import Observation
import SwiftUI

@Observable
@MainActor
final class OnboardingViewModel {
  var currentStep: OnboardingStep = .userName

  var selectedIcon: String = "sparkles"
  var userName: String = UserDefaults.standard.string(forKey: "userName") ?? ""
  var habitName: String = ""
  var habitDescription: String = ""
  var selectedColor: Color = ProudlyTheme.purple
  var selectedFrequency: Int = 1
  var customFrequency: Int = 5
  var reminderOption: OnboardingReminderOption = .none
  var customReminderTimes: [Date] = [NotificationManager.reminderDate(from: "09:00")]

  var isSaving: Bool = false
  var permissionDeniedMessage: String?

  let iconOptions: [String] = [
    "drop.fill",
    "figure.walk",
    "book.fill",
    "moon.stars.fill",
    "heart.fill",
    "flame.fill",
    "sparkles",
    "pencil",
    "leaf.fill",
    "dumbbell.fill",
    "bicycle",
  ]

  let colorOptions: [Color] = [
    ProudlyTheme.purple,
    ProudlyTheme.pink,
    ProudlyTheme.blue,
    ProudlyTheme.mint,
    .orange,
    .teal,
    Color(red: 0.98, green: 0.72, blue: 0.83),
    Color(red: 0.60, green: 0.77, blue: 0.97),
  ]

  var dailyTargetCount: Int {
    selectedFrequency == 0 ? max(customFrequency, 4) : selectedFrequency
  }

  var currentInputStepIndex: Int? {
    OnboardingStep.inputSteps.firstIndex(of: currentStep)
  }

  var progressValue: Double {
    guard let index = currentInputStepIndex else { return 1 }
    return Double(index + 1) / Double(OnboardingStep.inputSteps.count)
  }

  var continueTitle: String {
    switch currentStep {
    case .permission:
      return "Allow Notifications"
    case .reminder where !remindersEnabled:
      return "Create My Habit"
    case .reminder:
      return "Continue"
    default:
      return "Continue"
    }
  }

  var canContinue: Bool {
    switch currentStep {
    case .welcome, .icon, .description, .color, .frequency, .reminder, .permission, .celebration:
      return true
    case .userName:
      return !userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    case .name:
      return !habitName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
  }

  var remindersEnabled: Bool {
    reminderOption != .none
  }

  var resolvedReminderTimes: [String] {
    guard remindersEnabled else { return [] }

    switch reminderOption {
    case .none:
      return []
    case .morning:
      return NotificationManager.generatedReminderTimes(
        for: dailyTargetCount,
        firstTime: NotificationManager.reminderDate(from: morningAnchor(for: dailyTargetCount))
      )
    case .afternoon:
      return NotificationManager.generatedReminderTimes(
        for: dailyTargetCount,
        firstTime: NotificationManager.reminderDate(from: afternoonAnchor(for: dailyTargetCount))
      )
    case .evening:
      return NotificationManager.generatedReminderTimes(
        for: dailyTargetCount,
        firstTime: NotificationManager.reminderDate(from: eveningAnchor(for: dailyTargetCount))
      )
    case .custom:
      return
        customReminderTimes
        .prefix(dailyTargetCount)
        .map(NotificationManager.timeString(from:))
    }
  }

  func synchronizeCustomReminderTimes() {
    let count = max(dailyTargetCount, 1)

    if customReminderTimes.count > count {
      customReminderTimes = Array(customReminderTimes.prefix(count))
      return
    }

    if customReminderTimes.count < count {
      var updated = customReminderTimes
      while updated.count < count {
        updated.append(nextCustomReminderDate(after: updated.last))
      }
      customReminderTimes = updated
    }
  }

  func updateCustomReminderTime(at index: Int, to newValue: Date) {
    guard customReminderTimes.indices.contains(index) else { return }

    var updated = customReminderTimes
    let minDate = minimumCustomReminderDate(for: index, in: updated)
    updated[index] = max(newValue, minDate)

    for followingIndex in (index + 1)..<updated.count {
      let nextMin = minimumCustomReminderDate(for: followingIndex, in: updated)
      if updated[followingIndex] < nextMin {
        updated[followingIndex] = nextMin
      }
    }

    customReminderTimes = updated
  }

  func minimumCustomReminderDate(for index: Int, in times: [Date]) -> Date {
    guard index > 0, times.indices.contains(index - 1) else {
      return NotificationManager.reminderDate(from: "00:00")
    }
    return Calendar.current.date(byAdding: .minute, value: 1, to: times[index - 1])
      ?? times[index - 1]
  }

  private func nextCustomReminderDate(after previousDate: Date?) -> Date {
    let anchor = previousDate ?? NotificationManager.reminderDate(from: "09:00")
    return Calendar.current.date(byAdding: .hour, value: 1, to: anchor) ?? anchor
  }

  func hasReachedStep(_ step: OnboardingStep) -> Bool {
    guard
      let currentIndex = currentInputStepIndex,
      let stepIndex = OnboardingStep.inputSteps.firstIndex(of: step)
    else {
      return false
    }

    return stepIndex <= currentIndex
  }

  func goBack() {
    guard let index = OnboardingStep.inputSteps.firstIndex(of: currentStep), index > 0 else {
      return
    }
    permissionDeniedMessage = nil
    currentStep = OnboardingStep.inputSteps[index - 1]
  }

  func advance(using repository: HabitRepository) async {
    guard canContinue else { return }

    switch currentStep {
    case .reminder where !remindersEnabled:
      await createHabit(using: repository, remindersAuthorized: false)
    case .permission:
      let granted = await NotificationManager.shared.requestAuthorizationIfNeeded()
      if !granted {
        permissionDeniedMessage = "No worries. You can enable reminders later in Settings."
      }
      await createHabit(using: repository, remindersAuthorized: granted)
    case .celebration:
      break
    default:
      moveToNextStep()
    }
  }

  private func moveToNextStep() {
    permissionDeniedMessage = nil

    if currentStep == .reminder && remindersEnabled {
      currentStep = .permission
      return
    }

    guard let index = OnboardingStep.inputSteps.firstIndex(of: currentStep),
      index + 1 < OnboardingStep.inputSteps.count
    else {
      return
    }

    currentStep = OnboardingStep.inputSteps[index + 1]
  }

  private func createHabit(using repository: HabitRepository, remindersAuthorized: Bool) async {
    isSaving = true
    UserDefaults.standard.set(
      userName.trimmingCharacters(in: .whitespacesAndNewlines),
      forKey: "userName"
    )

    let habit = Habit(
      id: UUID(),
      name: habitName.trimmingCharacters(in: .whitespacesAndNewlines),
      icon: selectedIcon,
      color: selectedColor,
      streak: 0,
      bestStreak: 0,
      completedDates: [],
      completionCountsByDate: [:],
      note: habitDescription.trimmingCharacters(in: .whitespacesAndNewlines),
      dailyTargetCount: dailyTargetCount,
      completedCountToday: 0,
      remindersEnabled: remindersEnabled && remindersAuthorized,
      reminderTimes: remindersAuthorized ? resolvedReminderTimes : []
    )

    repository.addHabit(habit, markSeeded: true, showsToast: false)
    isSaving = false
    currentStep = .celebration
  }

  private func morningAnchor(for dailyTargetCount: Int) -> String {
    switch dailyTargetCount {
    case 4:
      return "08:00"
    default:
      return "09:00"
    }
  }

  private func afternoonAnchor(for dailyTargetCount: Int) -> String {
    switch dailyTargetCount {
    case 1:
      return "14:00"
    case 2:
      return "12:00"
    case 3:
      return "12:00"
    default:
      return "11:00"
    }
  }

  private func eveningAnchor(for dailyTargetCount: Int) -> String {
    switch dailyTargetCount {
    case 1:
      return "19:00"
    case 2:
      return "14:00"
    case 3:
      return "13:00"
    default:
      return "12:00"
    }
  }
}
