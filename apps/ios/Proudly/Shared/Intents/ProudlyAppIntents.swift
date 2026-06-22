//
//  ProudlyAppIntents.swift
//  Proudly
//

import AppIntents
import Foundation

// MARK: - Habit entity

struct HabitEntity: AppEntity, Identifiable, Hashable {
  let id: UUID
  let name: String

  static var typeDisplayRepresentation: TypeDisplayRepresentation = "Habit"

  var displayRepresentation: DisplayRepresentation {
    DisplayRepresentation(title: "\(name)")
  }

  static var defaultQuery = HabitEntityQuery()
}

struct HabitEntityQuery: EntityQuery, EntityStringQuery {
  func entities(for identifiers: [HabitEntity.ID]) async throws -> [HabitEntity] {
    await MainActor.run {
      guard let repo = HabitRepository.sharedForIntents else { return [] }
      return repo.activeHabits
        .filter { identifiers.contains($0.id) }
        .map { HabitEntity(id: $0.id, name: $0.name) }
    }
  }

  func suggestedEntities() async throws -> [HabitEntity] {
    await MainActor.run {
      guard let repo = HabitRepository.sharedForIntents else { return [] }
      return repo.activeHabits.map { HabitEntity(id: $0.id, name: $0.name) }
    }
  }

  func entities(matching string: String) async throws -> [HabitEntity] {
    let needle = string.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
    return await MainActor.run {
      guard let repo = HabitRepository.sharedForIntents else { return [] }
      return repo.activeHabits
        .filter { $0.name.lowercased().contains(needle) }
        .map { HabitEntity(id: $0.id, name: $0.name) }
    }
  }
}

// MARK: - Intents

struct OpenTodayInProudlyIntent: AppIntent {
  static var title: LocalizedStringResource = "Open Today in Proudly"
  static var description = IntentDescription("Open today's habit checklist in Proudly.")
  static var openAppWhenRun: Bool = true

  func perform() async throws -> some IntentResult {
    await MainActor.run {
      AppNavigationStore.shared.consumePendingHabitID()
    }
    return .result()
  }
}

struct OpenHabitIntent: AppIntent {
  static var title: LocalizedStringResource = "Open Habit"
  static var description = IntentDescription("Open a specific habit in Proudly.")
  static var openAppWhenRun: Bool = true

  @Parameter(title: "Habit") var habit: HabitEntity

  func perform() async throws -> some IntentResult {
    await MainActor.run {
      AppNavigationStore.shared.openHabit(id: habit.id)
    }
    return .result()
  }
}

struct CompleteHabitIntent: AppIntent {
  static var title: LocalizedStringResource = "Complete Habit"
  static var description = IntentDescription("Log a completion for one of your habits.")
  static var openAppWhenRun: Bool = false

  @Parameter(title: "Habit") var habit: HabitEntity

  func perform() async throws -> some IntentResult & ProvidesDialog {
    let name = habit.name
    let outcome: IntentOutcome = await MainActor.run {
      guard let repo = HabitRepository.sharedForIntents else {
        return .notReady
      }
      guard let match = repo.activeHabits.first(where: { $0.id == habit.id }) else {
        return .notFound
      }
      if match.isCompletedToday {
        return .alreadyDone
      }
      repo.incrementCompletion(for: match)
      return .logged
    }

    switch outcome {
    case .logged:
      return .result(dialog: "Logged \(name). Proud of you.")
    case .alreadyDone:
      return .result(dialog: "\(name) is already done for today.")
    case .notFound:
      return .result(dialog: "I couldn't find \(name).")
    case .notReady:
      return .result(dialog: "Open Proudly once, then try again.")
    }
  }

  private enum IntentOutcome { case logged, alreadyDone, notFound, notReady }
}

struct StartHabitFocusTimerIntent: AppIntent {
  static var title: LocalizedStringResource = "Start Habit Focus Timer"
  static var description = IntentDescription(
    "Start a Focus Timer for a habit using its saved duration.")
  static var openAppWhenRun: Bool = true

  @Parameter(title: "Habit") var habit: HabitEntity
  @Parameter(title: "Minutes", default: nil) var minutes: Int?

  func perform() async throws -> some IntentResult & ProvidesDialog {
    let name = habit.name
    let started: Bool = await MainActor.run {
      guard let repo = HabitRepository.sharedForIntents,
        let match = repo.activeHabits.first(where: { $0.id == habit.id })
      else { return false }
      let duration = TimeInterval(
        max(minutes ?? match.focusDurationMinutes ?? 25, 1) * 60)
      FocusTimerStore.shared.start(habit: match, duration: duration)
      AppNavigationStore.shared.openHabit(id: match.id)
      return true
    }

    if started {
      return .result(dialog: "Focus timer started for \(name).")
    }
    return .result(dialog: "I couldn't find \(name).")
  }
}

// MARK: - Shortcuts provider

struct ProudlyShortcuts: AppShortcutsProvider {
  static var appShortcuts: [AppShortcut] {
    AppShortcut(
      intent: OpenTodayInProudlyIntent(),
      phrases: [
        "Open Today in \(.applicationName)",
        "Show today in \(.applicationName)",
      ],
      shortTitle: "Open Today",
      systemImageName: "checkmark.circle"
    )

    AppShortcut(
      intent: CompleteHabitIntent(),
      phrases: [
        "Complete \(\.$habit) in \(.applicationName)",
        "Mark \(\.$habit) done in \(.applicationName)",
      ],
      shortTitle: "Complete Habit",
      systemImageName: "checkmark.seal.fill"
    )

    AppShortcut(
      intent: StartHabitFocusTimerIntent(),
      phrases: [
        "Start \(\.$habit) focus timer in \(.applicationName)",
        "Start a focus timer for \(\.$habit) in \(.applicationName)",
        "Start my \(\.$habit) habit in \(.applicationName)",
      ],
      shortTitle: "Start Focus Timer",
      systemImageName: "timer"
    )

    AppShortcut(
      intent: OpenHabitIntent(),
      phrases: [
        "Open \(\.$habit) in \(.applicationName)"
      ],
      shortTitle: "Open Habit",
      systemImageName: "list.bullet.circle"
    )
  }
}
