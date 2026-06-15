//
//  HabitRepository.swift
//  Proudly
//
//  Created by Arnolfo Federis on 6/15/26.
//

import Foundation
import Observation
import SwiftData
import SwiftUI

@Observable
final class HabitRepository {
  private let modelContext: ModelContext
  private(set) var activeHabits: [Habit] = []

  private var hasSeeded: Bool {
    get { UserDefaults.standard.bool(forKey: "hasSeededDefaultHabits") }
    set { UserDefaults.standard.set(newValue, forKey: "hasSeededDefaultHabits") }
  }

  init(modelContext: ModelContext) {
    self.modelContext = modelContext
    refresh()
    seedIfNeeded()
  }

  // MARK: - Read

  func refresh() {
    let descriptor = FetchDescriptor<PersistentHabit>(
      predicate: #Predicate { !$0.isArchived },
      sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
    )
    let persistent = (try? modelContext.fetch(descriptor)) ?? []
    activeHabits = persistent.map { map($0) }
  }

  // MARK: - Write

  func addHabit(_ habit: Habit) {
    let (hour, minute) = parseReminder(habit.reminder)
    let p = PersistentHabit(
      id: habit.id,
      name: habit.name,
      icon: habit.icon,
      colorHex: habit.color.toHex(),
      note: habit.note,
      reminderHour: hour,
      reminderMinute: minute
    )
    modelContext.insert(p)
    save()
    refresh()
  }

  func updateHabit(_ habit: Habit) {
    guard let p = fetchPersistent(id: habit.id) else { return }
    let (hour, minute) = parseReminder(habit.reminder)
    p.name = habit.name
    p.icon = habit.icon
    p.colorHex = habit.color.toHex()
    p.note = habit.note
    p.reminderHour = hour
    p.reminderMinute = minute
    p.updatedAt = .now
    save()
    refresh()
  }

  func toggleCompletion(for habit: Habit) {
    guard let p = fetchPersistent(id: habit.id) else { return }
    let today = Self.dateKey(for: .now)
    if let existing = p.completions.first(where: { $0.dateKey == today }) {
      modelContext.delete(existing)
    } else {
      let completion = PersistentHabitCompletion(habitId: habit.id, dateKey: today)
      p.completions.append(completion)
    }
    save()
    refresh()
  }

  func archiveHabit(_ habit: Habit) {
    guard let p = fetchPersistent(id: habit.id) else { return }
    p.isArchived = true
    p.updatedAt = .now
    save()
    refresh()
  }

  // MARK: - Proud Moments

  var proudMoments: [ProudMoment] {
    let fmt = Self.dateFormatter
    var moments: [ProudMoment] = []
    for habit in activeHabits {
      let sorted = habit.completedDates
        .compactMap { key -> (String, Date)? in
          guard let date = fmt.date(from: key) else { return nil }
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
    case 2...6: return "\(streak.proudlyDayPhrase) strong — you're building a habit!"
    case 7...13: return "\(streak.proudlyStreakLabel)! You're on fire."
    case 14...29: return "\(streak.proudlyDayPhrase) in a row — incredible!"
    default: return "\(streak.proudlyStreakLabel)! You're unstoppable."
    }
  }

  // MARK: - Seed

  private func seedIfNeeded() {
    guard !hasSeeded else { return }
    let now = Date.now
    // Inserted oldest-first so sort-by-createdAt-descending gives the desired display order.
    let seeds: [(name: String, icon: String, color: Color, note: String, offset: TimeInterval)] = [
      ("Read 10 pages", "book.fill", ProudlyTheme.purple, "Feed your mind daily", -2),
      ("Walk 10 minutes", "figure.walk", ProudlyTheme.mint, "A short walk clears the mind", -1),
      ("Drink water", "drop.fill", ProudlyTheme.blue, "Stay hydrated all day", 0),
    ]
    for seed in seeds {
      let p = PersistentHabit(
        name: seed.name,
        icon: seed.icon,
        colorHex: seed.color.toHex(),
        note: seed.note,
        createdAt: now.addingTimeInterval(seed.offset)
      )
      modelContext.insert(p)
    }
    save()
    hasSeeded = true
    refresh()
  }

  // MARK: - Streak helpers (static so HabitDetailView can reuse)

  static func currentStreak(keys: Set<String>) -> Int {
    let cal = Calendar.current
    let fmt = Self.dateFormatter
    var date = Date.now
    var streak = 0
    if !keys.contains(fmt.string(from: date)) {
      guard let yesterday = cal.date(byAdding: .day, value: -1, to: date) else { return 0 }
      date = yesterday
    }
    while keys.contains(fmt.string(from: date)) {
      streak += 1
      guard let prev = cal.date(byAdding: .day, value: -1, to: date) else { break }
      date = prev
    }
    return streak
  }

  static func bestStreak(keys: Set<String>) -> Int {
    guard !keys.isEmpty else { return 0 }
    let fmt = Self.dateFormatter
    let cal = Calendar.current
    let sorted = keys.compactMap { fmt.date(from: $0) }.sorted()
    guard sorted.count > 1 else { return 1 }
    var best = 1
    var current = 1
    for i in 1..<sorted.count {
      let diff = cal.dateComponents([.day], from: sorted[i - 1], to: sorted[i]).day ?? 0
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
    dateFormatter.string(from: date)
  }

  // MARK: - Private helpers

  private func map(_ p: PersistentHabit) -> Habit {
    let keys = Set(p.completions.map(\.dateKey))
    return Habit(
      id: p.id,
      name: p.name,
      icon: p.icon,
      color: Color(hex: p.colorHex),
      streak: Self.currentStreak(keys: keys),
      bestStreak: Self.bestStreak(keys: keys),
      completedDates: keys,
      note: p.note,
      reminder: reminderString(hour: p.reminderHour, minute: p.reminderMinute)
    )
  }

  private func fetchPersistent(id: UUID) -> PersistentHabit? {
    let descriptor = FetchDescriptor<PersistentHabit>(
      predicate: #Predicate { $0.id == id }
    )
    return try? modelContext.fetch(descriptor).first
  }

  private func save() {
    try? modelContext.save()
  }

  private func reminderString(hour: Int?, minute: Int?) -> String? {
    guard let hour, let minute else { return nil }
    let components = DateComponents(hour: hour, minute: minute)
    guard let date = Calendar.current.date(from: components) else { return nil }
    let fmt = DateFormatter()
    fmt.dateFormat = "h:mm a"
    return fmt.string(from: date)
  }

  private func parseReminder(_ s: String?) -> (Int?, Int?) {
    guard let s else { return (nil, nil) }
    let fmt = DateFormatter()
    fmt.dateFormat = "h:mm a"
    guard let date = fmt.date(from: s) else { return (nil, nil) }
    let c = Calendar.current.dateComponents([.hour, .minute], from: date)
    return (c.hour, c.minute)
  }

  private static let dateFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateFormat = "yyyy-MM-dd"
    return f
  }()
}

#if DEBUG
  extension HabitRepository {
    /// In-memory repository pre-loaded with sample habits for Xcode Previews.
    static var preview: HabitRepository {
      let schema = Schema([PersistentHabit.self, PersistentHabitCompletion.self])
      let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
      let container = try! ModelContainer(for: schema, configurations: [config])
      let repo = HabitRepository(modelContext: container.mainContext)
      // UserDefaults seeding flag may be set from a real launch; force-seed if empty.
      if repo.activeHabits.isEmpty {
        for habit in repo.activeHabits {
          repo.addHabit(habit)
        }
      }
      return repo
    }
  }
#endif
