//
//  HabitDetailView.swift
//  Proudly
//
//  Created by Arnolfo Federis on 6/11/26.
//

import SwiftUI

struct HabitDetailView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(ThemeViewModel.self) private var theme
  @Environment(HabitRepository.self) private var repository

  @State private var habit: Habit
  @State private var isEditPresented = false
  @State private var isArchiveConfirmationPresented = false

  let onSave: (Habit) -> Void

  init(habit: Habit, onSave: @escaping (Habit) -> Void = { _ in }) {
    _habit = State(initialValue: habit)
    self.onSave = onSave
  }

  var body: some View {
    ZStack {
      theme.activeTheme.backgroundGradient.ignoresSafeArea()

      ScrollView {
        LazyVStack(spacing: 24) {
          iconBubble
          progressCard
          statsRow
          sevenDayPreviewCard
          monthlyHistoryCard
          markDoneButton
          Spacer(minLength: 40)
        }
        .padding(.horizontal, 20)
      }
    }
    .navigationTitle(habit.name)
    .navigationBarTitleDisplayMode(.inline)
    .tint(habit.color)
    .onChange(of: repository.activeHabits, initial: true) { _, updated in
      if let fresh = updated.first(where: { $0.id == habit.id }) {
        habit = fresh
      } else {
        dismiss()
      }
    }
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Menu {
          Button(action: presentEditHabit) {
            Label("Edit Habit", systemImage: "pencil")
          }

          Button(role: .destructive) {
            isArchiveConfirmationPresented = true
          } label: {
            Label("Archive Habit", systemImage: "archivebox.fill")
          }
        } label: {
          Image(systemName: "ellipsis.circle")
            .font(.system(size: 18, weight: .semibold))
        }
        .tint(habit.color)
      }
    }
    .toolbarVisibility(.hidden, for: .tabBar)
    .sheet(isPresented: $isEditPresented) {
      HabitFormView(habit: habit) { updatedHabit in
        habit = updatedHabit
        onSave(updatedHabit)
        isEditPresented = false
      }
    }
    .confirmationDialog(
      "Archive habit?",
      isPresented: $isArchiveConfirmationPresented,
      titleVisibility: .visible
    ) {
      Button("Archive", role: .destructive) {
        archiveHabit()
      }
    } message: {
      Text("\(habit.name) will be removed from your active habits.")
    }
  }

  private var iconBubble: some View {
    VStack(spacing: 10) {
      HabitIconView(icon: habit.icon, color: habit.color, fontSize: 42, circleSize: 96)
        .padding(.top, 20)

      if !habit.note.isEmpty {
        Text(habit.note)
          .font(.subheadline)
          .foregroundStyle(.secondary)
          .multilineTextAlignment(.center)
      }
    }
  }

  private var progressCard: some View {
    VStack(alignment: .leading, spacing: 14) {
      HStack(alignment: .firstTextBaseline) {
        VStack(alignment: .leading, spacing: 4) {
          Text("Today")
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.secondary)
          Text("\(habit.completedCountToday) of \(habit.dailyTargetCount) completed today")
            .font(.system(size: 22, weight: .bold, design: .rounded))
            .contentTransition(.numericText())
        }

        Spacer()

        Text(habit.todayProgressPercentText)
          .font(.title3.weight(.semibold))
          .foregroundStyle(habit.color)
          .contentTransition(.numericText())
      }

      ProgressView(value: habit.completionProgressToday)
        .progressViewStyle(.linear)
        .tint(habit.color)
    }
    .padding(20)
    .proudlyGlass()
  }

  private var statsRow: some View {
    HStack(spacing: 12) {
      StatCard(
        label: "Current Streak",
        value: "\(habit.streak)",
        unit: habit.streak.proudlyDayUnit,
        color: ProudlyTheme.pink
      )
      StatCard(
        label: "Best Streak",
        value: "\(habit.bestStreak)",
        unit: habit.bestStreak.proudlyDayUnit,
        color: ProudlyTheme.purple
      )
    }
  }

  private var sevenDayPreviewCard: some View {
    VStack(alignment: .leading, spacing: 14) {
      Text("Last 7 Days")
        .font(.system(size: 16, weight: .semibold))

      HStack(spacing: 6) {
        ForEach(lastSevenDays, id: \.self) { dateKey in
          let count = habit.completionCountsByDate[dateKey] ?? 0
          let isComplete = count >= habit.dailyTargetCount

          VStack(spacing: 6) {
            ZStack {
              Circle()
                .fill(isComplete ? habit.color : Color.gray.opacity(0.15))
                .frame(width: 36, height: 36)

              if isComplete {
                Image(systemName: "checkmark")
                  .font(.system(size: 12, weight: .bold))
                  .foregroundStyle(.white)
              } else if count > 0 {
                Text("\(count)")
                  .font(.system(size: 11, weight: .bold))
                  .foregroundStyle(.primary)
              }
            }

            Text(dayLabel(for: dateKey))
              .font(.caption2)
              .foregroundStyle(.secondary)
          }
          .frame(maxWidth: .infinity)
        }
      }
    }
    .padding(20)
    .proudlyGlass()
  }

  private var monthlyHistoryCard: some View {
    HStack(spacing: 14) {
      ZStack {
        Circle()
          .fill(habit.color.opacity(0.15))
          .frame(width: 42, height: 42)
        Image(systemName: "calendar")
          .foregroundStyle(habit.color)
      }
      VStack(alignment: .leading, spacing: 3) {
        Text("Monthly History")
          .font(.system(size: 15, weight: .semibold))
          .foregroundStyle(.primary)
        Text("Full calendar view coming soon.")
          .font(.caption)
          .foregroundStyle(.secondary)
      }
      Spacer()
    }
    .padding(16)
    .proudlyGlass(cornerRadius: 18)
  }

  private var markDoneButton: some View {
    Button {
      if habit.isCompletedToday {
        Haptics.impact(.soft)
      } else if habit.completedCountToday + 1 >= habit.dailyTargetCount {
        Haptics.notification(.success)
      } else {
        Haptics.selection()
      }

      repository.toggleCompletion(for: habit)
    } label: {
      Label(buttonTitle, systemImage: buttonSymbol)
        .font(.system(size: 17, weight: .semibold))
        .foregroundStyle(habit.isCompletedToday ? .white : habit.color)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 17)
        .background(habit.isCompletedToday ? habit.color : habit.color.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    .buttonStyle(.plain)
  }

  private var buttonTitle: String {
    if habit.dailyTargetCount == 1 {
      return habit.isCompletedToday ? "Completed!" : "Mark as Done"
    }

    if habit.isCompletedToday {
      return "Undo One Check-In"
    }

    return "Log Another Check-In"
  }

  private var buttonSymbol: String {
    habit.isCompletedToday ? "checkmark.circle.fill" : "plus.circle.fill"
  }

  private var lastSevenDays: [String] {
    (0..<7).reversed().map { offset in
      let date = Calendar.current.date(byAdding: .day, value: -offset, to: .now) ?? .now
      return HabitRepository.dateKey(for: date)
    }
  }

  private func dayLabel(for dateKey: String) -> String {
    let inputFormatter = DateFormatter()
    inputFormatter.dateFormat = "yyyy-MM-dd"
    guard let date = inputFormatter.date(from: dateKey) else { return "" }
    let outputFormatter = DateFormatter()
    outputFormatter.dateFormat = "EEE"
    return String(outputFormatter.string(from: date).prefix(1))
  }

  private func presentEditHabit() {
    Haptics.selection()
    isEditPresented = true
  }

  private func archiveHabit() {
    Haptics.impact(.medium)
    repository.archiveHabit(habit)
    dismiss()
  }
}

struct StatCard: View {
  let label: String
  let value: String
  let unit: String
  let color: Color

  var body: some View {
    VStack(spacing: 6) {
      Text(value)
        .font(.system(size: 34, weight: .bold, design: .rounded))
        .foregroundStyle(color)
      Text(unit)
        .font(.caption)
        .foregroundStyle(.secondary)
      Text(label)
        .font(.caption2)
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 22)
    .proudlyGlass(cornerRadius: 20)
  }
}

#Preview {
  NavigationStack {
    HabitDetailView(habit: Habit.samples[1])
  }
  .environment(ThemeViewModel())
  .environment(SubscriptionStore())
  .environment(HabitRepository.preview)
}
