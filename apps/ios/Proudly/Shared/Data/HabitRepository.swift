//
//  HabitRepository.swift
//  Proudly
//
//  Created by Arnolfo Federis on 6/16/26.
//

import Foundation
import Observation
import SwiftData
import SwiftUI

@MainActor
@Observable
final class HabitRepository {
  /// Weak reference exposed for App Intents (Siri/Shortcuts) so they can
  /// drive the same repository the UI uses. Wired up in the app's init.
  static weak var sharedForIntents: HabitRepository?

  private let modelContext: ModelContext
  private let notificationManager: NotificationManager
  private let toastCenter: ToastCenter?

  private(set) var activeHabits: [Habit] = []

  private var hasSeeded: Bool {
    get { UserDefaults.standard.bool(forKey: Self.seededKey) }
    set { UserDefaults.standard.set(newValue, forKey: Self.seededKey) }
  }

  init(
    modelContext: ModelContext,
    notificationManager: NotificationManager? = nil,
    toastCenter: ToastCenter? = nil
  ) {
    self.modelContext = modelContext
    self.notificationManager = notificationManager ?? .shared
    self.toastCenter = toastCenter
    refresh()
    seedIfNeeded()
    Self.sharedForIntents = self
  }

  // MARK: - Read

  func refresh() {
    let descriptor = FetchDescriptor<PersistentHabit>(
      predicate: #Predicate { !$0.isArchived },
      sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
    )
    let persistent = (try? modelContext.fetch(descriptor)) ?? []
    activeHabits = persistent.map(map(_:))
  }

  func seedIfNeeded() {
    guard UserDefaults.standard.bool(forKey: Self.onboardingKey) else { return }
    guard !hasSeeded else { return }

    if !activeHabits.isEmpty {
      hasSeeded = true
      return
    }

    let now = Date.now
    let seeds: [(name: String, icon: String, color: Color, note: String, offset: TimeInterval)] = [
      ("Read 10 pages", "book.fill", ProudlyTheme.purple, "Feed your mind daily", -2),
      ("Walk 10 minutes", "figure.walk", ProudlyTheme.mint, "A short walk clears the mind", -1),
      ("Drink water", "drop.fill", ProudlyTheme.blue, "Stay hydrated all day", 0),
    ]

    for seed in seeds {
      let persistentHabit = PersistentHabit(
        name: seed.name,
        icon: seed.icon,
        colorHex: seed.color.toHex(),
        note: seed.note,
        dailyTargetCount: 1,
        remindersEnabled: false,
        reminderTimes: "",
        createdAt: now.addingTimeInterval(seed.offset)
      )
      modelContext.insert(persistentHabit)
    }

    save()
    hasSeeded = true
    refresh()
  }

  func completedCount(for habit: Habit, on dateKey: String) -> Int {
    if let persistentHabit = fetchPersistent(id: habit.id),
      let completion = completion(for: persistentHabit, dateKey: dateKey)
    {
      return max(completion.count, 0)
    }

    return habit.completionCountsByDate[dateKey] ?? 0
  }

  func completionProgress(for habit: Habit, on dateKey: String) -> Double {
    let count = completedCount(for: habit, on: dateKey)
    return min(Double(count) / Double(max(habit.dailyTargetCount, 1)), 1)
  }

  // MARK: - Write

  func addHabit(_ habit: Habit, markSeeded: Bool = false, showsToast: Bool = true) {
    let reminderString = Self.normalizedReminderTimesString(from: habit.reminderTimes)
    let legacyReminder = habit.reminderTimes.first
    let (hour, minute) = Self.parseReminder(legacyReminder)
    let persistentHabit = PersistentHabit(
      id: habit.id,
      name: habit.name,
      icon: habit.icon,
      colorHex: habit.color.toHex(),
      note: habit.note,
      dailyTargetCount: max(habit.dailyTargetCount, 1),
      remindersEnabled: habit.remindersEnabled && !habit.reminderTimes.isEmpty,
      reminderTimes: reminderString,
      reminderHour: hour,
      reminderMinute: minute,
      reminderCount: max(habit.reminderCount, 1),
      focusDurationMinutes: habit.focusDurationMinutes
    )
    modelContext.insert(persistentHabit)
    save()

    if markSeeded {
      hasSeeded = true
    }

    refresh()
    syncReminders(for: habit)

    if showsToast {
      toastCenter?.show(message: "Added \(habit.name)", symbol: "plus.circle.fill")
    }
  }

  func updateHabit(_ habit: Habit) {
    guard let persistentHabit = fetchPersistent(id: habit.id) else { return }
    let reminderString = Self.normalizedReminderTimesString(from: habit.reminderTimes)
    let legacyReminder = habit.reminderTimes.first
    let (hour, minute) = Self.parseReminder(legacyReminder)

    persistentHabit.name = habit.name
    persistentHabit.icon = habit.icon
    persistentHabit.colorHex = habit.color.toHex()
    persistentHabit.note = habit.note
    persistentHabit.dailyTargetCount = max(habit.dailyTargetCount, 1)
    persistentHabit.remindersEnabled = habit.remindersEnabled && !habit.reminderTimes.isEmpty
    persistentHabit.reminderTimes = reminderString
    persistentHabit.reminderHour = hour
    persistentHabit.reminderMinute = minute
    persistentHabit.reminderCount = max(habit.reminderCount, 1)
    persistentHabit.focusDurationMinutes = habit.focusDurationMinutes
    persistentHabit.updatedAt = .now

    save()
    refresh()
    syncReminders(for: habit)
    toastCenter?.show(message: "Updated \(habit.name)", symbol: "pencil.circle.fill")
  }

  func incrementCompletion(for habit: Habit) {
    guard let persistentHabit = fetchPersistent(id: habit.id) else { return }
    let today = LocalDay.key()
    let target = max(persistentHabit.dailyTargetCount, 1)

    if let existing = completion(for: persistentHabit, dateKey: today) {
      guard existing.count < target else { return }
      existing.count += 1
      existing.completedAt = .now
    } else {
      let completion = PersistentHabitCompletion(habitId: habit.id, dateKey: today, count: 1)
      if persistentHabit.completions == nil {
        persistentHabit.completions = [completion]
      } else {
        persistentHabit.completions?.append(completion)
      }
    }

    persistentHabit.updatedAt = .now
    save()
    refresh()
    let updatedCount = min(habit.completedCountToday + 1, target)
    if updatedCount >= target {
      toastCenter?.show(message: "\(habit.name) completed", symbol: "checkmark.circle.fill")
    } else {
      toastCenter?.show(
        message: "\(habit.name): \(updatedCount) of \(target)",
        symbol: "plus.circle.fill"
      )
    }
  }

  func decrementCompletion(for habit: Habit) {
    guard let persistentHabit = fetchPersistent(id: habit.id) else { return }
    let today = LocalDay.key()
    guard let existing = completion(for: persistentHabit, dateKey: today) else { return }

    if existing.count > 1 {
      existing.count -= 1
      existing.completedAt = .now
    } else {
      modelContext.delete(existing)
    }

    persistentHabit.updatedAt = .now
    save()
    refresh()
    let updatedCount = max(habit.completedCountToday - 1, 0)
    toastCenter?.show(
      message: "\(habit.name): \(updatedCount) of \(max(habit.dailyTargetCount, 1))",
      symbol: "minus.circle.fill"
    )
  }

  func toggleCompletion(for habit: Habit) {
    let target = max(habit.dailyTargetCount, 1)
    let today = LocalDay.key()
    let count = completedCount(for: habit, on: today)

    if target == 1 {
      count > 0 ? decrementCompletion(for: habit) : incrementCompletion(for: habit)
      return
    }

    if count >= target {
      decrementCompletion(for: habit)
    } else {
      incrementCompletion(for: habit)
    }
  }

  func archiveHabit(_ habit: Habit) {
    guard let persistentHabit = fetchPersistent(id: habit.id) else { return }
    persistentHabit.isArchived = true
    persistentHabit.updatedAt = .now
    save()
    refresh()
    toastCenter?.show(message: "Archived \(habit.name)", symbol: "archivebox.fill")

    Task {
      await notificationManager.cancelReminders(for: habit.id)
    }
  }

  // MARK: - Proud Moments

  var proudMoments: [ProudMoment] {
    var moments: [ProudMoment] = []

    for habit in activeHabits {
      let sorted = habit.completedDates
        .compactMap { key -> (String, Date)? in
          guard let date = LocalDay.date(fromKey: key) else { return nil }
          return (key, date)
        }
        .sorted { $0.1 > $1.1 }
        .prefix(10)

      for (key, date) in sorted {
        moments.append(
          ProudMoment(
            id: "\(habit.id)-\(key)",
            habitName: habit.name,
            icon: habit.icon,
            color: habit.color,
            date: date,
            message: streakMessage(habit.streak),
            streak: habit.streak
          ))
      }
    }

    return moments.sorted { $0.date > $1.date }
  }

  private func streakMessage(_ streak: Int) -> String {
    switch streak {
    case 0: return "Every start counts. Keep going!"
    case 1: return "Day 1 done. The journey begins!"
    case 2...6: return "\(streak.proudlyDayPhrase) strong - you're building a habit!"
    case 7...13: return "\(streak.proudlyStreakLabel)! You're on fire."
    case 14...29: return "\(streak.proudlyDayPhrase) in a row - incredible!"
    default: return "\(streak.proudlyStreakLabel)! You're unstoppable."
    }
  }

  // MARK: - Streak helpers

  static func currentStreak(completedKeys: Set<String>) -> Int {
    let calendar = LocalDay.calendar
    var date = LocalDay.startOfDay()
    var streak = 0

    if !completedKeys.contains(LocalDay.key(for: date)) {
      guard let yesterday = calendar.date(byAdding: .day, value: -1, to: date) else { return 0 }
      date = yesterday
    }

    while completedKeys.contains(LocalDay.key(for: date)) {
      streak += 1
      guard let previous = calendar.date(byAdding: .day, value: -1, to: date) else { break }
      date = previous
    }

    return streak
  }

  static func bestStreak(completedKeys: Set<String>) -> Int {
    guard !completedKeys.isEmpty else { return 0 }
    let calendar = LocalDay.calendar
    let sorted = completedKeys.compactMap { LocalDay.date(fromKey: $0) }.sorted()
    guard sorted.count > 1 else { return 1 }

    var best = 1
    var current = 1

    for index in 1..<sorted.count {
      let diff =
        calendar.dateComponents([.day], from: sorted[index - 1], to: sorted[index]).day ?? 0
      if diff == 1 {
        current += 1
        best = max(best, current)
      } else {
        current = 1
      }
    }

    return best
  }

  static func dateKey(for date: Date) -> String {
    LocalDay.key(for: date)
  }

  // MARK: - Private helpers

  private func map(_ persistentHabit: PersistentHabit) -> Habit {
    let target = max(persistentHabit.dailyTargetCount, 1)
    let countsByDate = (persistentHabit.completions ?? []).reduce(into: [String: Int]()) {
      partialResult, completion in
      partialResult[completion.dateKey] = max(completion.count, 0)
    }

    let completedDates = Set(
      countsByDate.compactMap { key, count in
        count >= target ? key : nil
      })

    let reminders = Self.reminderTimes(
      from: persistentHabit.reminderTimes,
      fallbackHour: persistentHabit.reminderHour,
      fallbackMinute: persistentHabit.reminderMinute
    )

    let derivedReminderCount = max(persistentHabit.reminderCount ?? reminders.count, 1)

    return Habit(
      id: persistentHabit.id,
      name: persistentHabit.name,
      icon: persistentHabit.icon,
      color: Color(hex: persistentHabit.colorHex),
      streak: Self.currentStreak(completedKeys: completedDates),
      bestStreak: Self.bestStreak(completedKeys: completedDates),
      completedDates: completedDates,
      completionCountsByDate: countsByDate,
      note: persistentHabit.note,
      dailyTargetCount: target,
      completedCountToday: countsByDate[LocalDay.key()] ?? 0,
      remindersEnabled: persistentHabit.remindersEnabled || !reminders.isEmpty,
      reminderTimes: reminders,
      reminderCount: derivedReminderCount,
      focusDurationMinutes: persistentHabit.focusDurationMinutes
    )
  }

  private func fetchPersistent(id: UUID) -> PersistentHabit? {
    let descriptor = FetchDescriptor<PersistentHabit>(
      predicate: #Predicate { $0.id == id }
    )
    return try? modelContext.fetch(descriptor).first
  }

  private func completion(for habit: PersistentHabit, dateKey: String) -> PersistentHabitCompletion?
  {
    habit.completions?.first(where: { $0.dateKey == dateKey })
  }

  private func syncReminders(for habit: Habit) {
    Task {
      if habit.remindersEnabled && !habit.reminderTimes.isEmpty {
        await notificationManager.scheduleReminders(for: habit)
      } else {
        await notificationManager.cancelReminders(for: habit.id)
      }
    }
  }

  func refreshRemindersForAllHabits() {
    for habit in activeHabits {
      syncReminders(for: habit)
    }
  }

  private func save() {
    try? modelContext.save()
  }

  private static func reminderTimes(
    from reminderTimes: String,
    fallbackHour: Int?,
    fallbackMinute: Int?
  ) -> [String] {
    let normalized =
      reminderTimes
      .split(separator: ",")
      .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
      .filter { !$0.isEmpty }

    if !normalized.isEmpty {
      return normalized
    }

    guard let fallbackHour, let fallbackMinute else { return [] }
    return [String(format: "%02d:%02d", fallbackHour, fallbackMinute)]
  }

  private static func normalizedReminderTimesString(from reminderTimes: [String]) -> String {
    reminderTimes
      .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
      .filter { !$0.isEmpty }
      .joined(separator: ",")
  }

  private static func parseReminder(_ reminder: String?) -> (Int?, Int?) {
    guard let reminder else { return (nil, nil) }
    let parts = reminder.split(separator: ":")
    guard parts.count == 2,
      let hour = Int(parts[0]),
      let minute = Int(parts[1])
    else {
      return (nil, nil)
    }

    return (hour, minute)
  }

  private static let onboardingKey = "hasCompletedOnboarding"
  private static let seededKey = "hasSeededDefaultHabits"
}

extension HabitRepository {
  static var preview: HabitRepository {
    let schema = Schema([PersistentHabit.self, PersistentHabitCompletion.self])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])
    UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    let repository = HabitRepository(modelContext: container.mainContext)

    if repository.activeHabits.isEmpty {
      repository.addHabit(Habit.samples[0], markSeeded: true, showsToast: false)
      repository.addHabit(Habit.samples[1], markSeeded: true, showsToast: false)
      repository.addHabit(Habit.samples[2], markSeeded: true, showsToast: false)
    }

    return repository
  }
}
