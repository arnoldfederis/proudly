//
//  FocusTimerStore.swift
//  Proudly
//

import Foundation
import Observation
import SwiftUI

@MainActor
@Observable
final class FocusTimerStore {
  static let shared = FocusTimerStore()

  struct Session: Equatable, Codable {
    let habitID: UUID
    let habitName: String
    let totalDuration: TimeInterval
    var endDate: Date
    var pausedRemaining: TimeInterval?
    var completionAcknowledged: Bool = false

    var isPaused: Bool { pausedRemaining != nil }
  }

  private(set) var session: Session?
  /// Increments while a session runs. UI observes this to re-render the
  /// countdown without subscribing to a wall-clock timer.
  private(set) var tick: Int = 0

  private var tickTask: Task<Void, Never>?

  private static let storageKey = "focusTimer.session.v1"

  var isRunning: Bool { session != nil }

  var isPaused: Bool { session?.isPaused == true }

  init() {
    session = Self.loadPersistedSession()
    if let session, !session.isPaused, !isComplete() {
      startTicking()
    }
  }

  func session(for habitID: UUID) -> Session? {
    session?.habitID == habitID ? session : nil
  }

  func remaining(at date: Date = .now) -> TimeInterval {
    guard let session else { return 0 }
    if let paused = session.pausedRemaining { return paused }
    return max(session.endDate.timeIntervalSince(date), 0)
  }

  func isComplete(at date: Date = .now) -> Bool {
    guard let session else { return false }
    if session.isPaused { return false }
    return remaining(at: date) <= 0
  }

  func start(habit: Habit, duration: TimeInterval) {
    let safeDuration = max(duration, 1)
    let end = Date.now.addingTimeInterval(safeDuration)
    session = Session(
      habitID: habit.id,
      habitName: habit.name,
      totalDuration: safeDuration,
      endDate: end
    )
    persist()
    scheduleCompletionNotification(habitID: habit.id, habitName: habit.name, fireAt: end)
    startTicking()
  }

  func pause() {
    guard var session, !session.isPaused else { return }
    let remaining = max(session.endDate.timeIntervalSince(.now), 0)
    session.pausedRemaining = remaining
    self.session = session
    persist()
    cancelCompletionNotification(habitID: session.habitID)
    tickTask?.cancel()
    tickTask = nil
  }

  func resume() {
    guard var session, let remaining = session.pausedRemaining else { return }
    session.endDate = Date.now.addingTimeInterval(remaining)
    session.pausedRemaining = nil
    self.session = session
    persist()
    scheduleCompletionNotification(
      habitID: session.habitID, habitName: session.habitName, fireAt: session.endDate)
    startTicking()
  }

  func stop() {
    if let habitID = session?.habitID {
      cancelCompletionNotification(habitID: habitID)
    }
    tickTask?.cancel()
    tickTask = nil
    session = nil
    persist()
  }

  func acknowledgeCompletion() {
    guard var session else { return }
    session.completionAcknowledged = true
    self.session = session
    persist()
  }

  /// Called by the app on scene activation to ensure UI reflects wall-clock
  /// time after a background/terminated period.
  func refresh() {
    guard session != nil else { return }
    tick &+= 1
    if isPaused { return }
    if isComplete() {
      tickTask?.cancel()
      tickTask = nil
      return
    }
    if tickTask == nil {
      startTicking()
    }
  }

  private func startTicking() {
    tickTask?.cancel()
    tickTask = Task { [weak self] in
      while !Task.isCancelled {
        try? await Task.sleep(for: .seconds(1))
        guard let self else { return }
        self.tick &+= 1
        if !self.isRunning { return }
        if self.isComplete() {
          self.tickTask?.cancel()
          return
        }
      }
    }
  }

  private func scheduleCompletionNotification(habitID: UUID, habitName: String, fireAt date: Date) {
    Task {
      await NotificationManager.shared.scheduleFocusComplete(
        habitID: habitID, habitName: habitName, fireAt: date)
    }
  }

  private func cancelCompletionNotification(habitID: UUID) {
    Task {
      await NotificationManager.shared.cancelFocusComplete(habitID: habitID)
    }
  }

  // MARK: - Persistence

  private func persist() {
    let defaults = UserDefaults.standard
    guard let session else {
      defaults.removeObject(forKey: Self.storageKey)
      return
    }
    do {
      let data = try JSONEncoder().encode(session)
      defaults.set(data, forKey: Self.storageKey)
    } catch {
      defaults.removeObject(forKey: Self.storageKey)
    }
  }

  private static func loadPersistedSession() -> Session? {
    guard let data = UserDefaults.standard.data(forKey: storageKey) else { return nil }
    return try? JSONDecoder().decode(Session.self, from: data)
  }
}

extension FocusTimerStore {
  static func formatted(_ interval: TimeInterval) -> String {
    let total = max(Int(interval.rounded()), 0)
    let hours = total / 3600
    let minutes = (total % 3600) / 60
    let seconds = total % 60
    if hours > 0 {
      return String(format: "%d:%02d:%02d", hours, minutes, seconds)
    }
    return String(format: "%d:%02d", minutes, seconds)
  }

  static let durationOptions: [Int] = [5, 10, 15, 25, 30, 45, 60, 90, 120]
}
