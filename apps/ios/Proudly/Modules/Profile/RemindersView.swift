//
//  RemindersView.swift
//  Proudly
//
//  Created by Arnolfo Federis on 6/16/26.
//

import SwiftUI

struct RemindersView: View {
  @Environment(ThemeViewModel.self) private var theme
  @Environment(HabitRepository.self) private var repository

  var body: some View {
    ZStack {
      theme.activeTheme.backgroundGradient.ignoresSafeArea()

      ScrollView {
        LazyVStack(spacing: 16) {
          summaryCard

          if repository.activeHabits.isEmpty {
            emptyState
          } else {
            LazyVStack(spacing: 10) {
              ForEach(repository.activeHabits) { habit in
                reminderRow(for: habit)
              }
            }
          }

          Spacer(minLength: 40)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
      }
    }
    .navigationTitle("Reminders")
    .navigationBarTitleDisplayMode(.inline)
  }

  private var summaryCard: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Daily reminders")
        .font(.headline)
      Text("Proudly can remind you based on each habit's daily target and saved reminder times.")
        .font(.subheadline)
        .foregroundStyle(.secondary)
      Text(reminderSummary)
        .font(.footnote.weight(.semibold))
        .foregroundStyle(theme.activeTheme.accentColor)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(18)
    .proudlyGlass(cornerRadius: 20)
  }

  private var emptyState: some View {
    VStack(spacing: 10) {
      Image(systemName: "bell.slash")
        .font(.system(size: 32, weight: .semibold))
        .foregroundStyle(.secondary)
      Text("No habits yet")
        .font(.headline)
      Text("Create a habit first, then add reminders from the habit form.")
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)
    }
    .padding(28)
    .frame(maxWidth: .infinity)
    .proudlyGlass(cornerRadius: 20)
  }

  private func reminderRow(for habit: Habit) -> some View {
    HStack(spacing: 14) {
      HabitIconView(
        icon: habit.icon,
        color: habit.color,
        fontSize: 18,
        circleSize: 42,
        backgroundOpacity: 0.18
      )

      VStack(alignment: .leading, spacing: 4) {
        Text(habit.name)
          .font(.system(size: 16, weight: .semibold))
        Text(reminderDescription(for: habit))
          .font(.caption)
          .foregroundStyle(.secondary)
      }

      Spacer()

      Image(systemName: habit.remindersEnabled ? "bell.fill" : "bell.slash")
        .font(.system(size: 15, weight: .semibold))
        .foregroundStyle(habit.remindersEnabled ? habit.color : .secondary)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(16)
    .proudlyGlass(cornerRadius: 18)
  }

  private var reminderSummary: String {
    let count = repository.activeHabits.filter(\.remindersEnabled).count
    return count == 1 ? "1 habit has reminders on." : "\(count) habits have reminders on."
  }

  private func reminderDescription(for habit: Habit) -> String {
    guard habit.remindersEnabled, !habit.reminderTimes.isEmpty else {
      return "No reminder set"
    }

    return habit.reminderTimes.joined(separator: "  •  ")
  }
}

#Preview {
  NavigationStack {
    RemindersView()
  }
  .environment(ThemeViewModel())
  .environment(HabitRepository.preview)
}
