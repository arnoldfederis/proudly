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
  @State private var animateContent = false

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
            .detailEntrance(animateContent, delay: 0.00)
          progressCard
            .detailEntrance(animateContent, delay: 0.06)
          statsRow
            .detailEntrance(animateContent, delay: 0.12)
          sevenDayPreviewCard
            .detailEntrance(animateContent, delay: 0.18)
          monthlyHistoryCard
            .detailEntrance(animateContent, delay: 0.24)
          completionButtons
            .detailEntrance(animateContent, delay: 0.30)
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
        Button(role: .destructive) {
          isArchiveConfirmationPresented = true
        } label: {
          Label("Archive Habit", systemImage: "archivebox")
        }
        .tint(.primary)
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

      if #available(iOS 26.0, *) {
        ToolbarSpacer(.fixed, placement: .topBarTrailing)
      }

      ToolbarItem(placement: .topBarTrailing) {
        Button(action: presentEditHabit) {
          Label("Edit Habit", systemImage: "pencil")
        }
        .tint(habit.color)
      }
    }
    .sheet(isPresented: $isEditPresented) {
      HabitFormView(habit: habit) { updatedHabit in
        habit = updatedHabit
        onSave(updatedHabit)
        isEditPresented = false
      }
    }
    .onAppear {
      withAnimation(.spring(response: 0.5, dampingFraction: 0.82)) {
        animateContent = true
      }
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
            .animation(
              .spring(response: 0.32, dampingFraction: 0.82), value: habit.completedCountToday)
        }

        Spacer()

        Text(habit.todayProgressPercentText)
          .font(.title3.weight(.semibold))
          .foregroundStyle(habit.color)
          .contentTransition(.numericText())
          .animation(
            .spring(response: 0.32, dampingFraction: 0.82), value: habit.completedCountToday)
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

  private var completionButtons: some View {
    VStack(spacing: 12) {
      Button {
        guard habit.completedCountToday > 0 else { return }
        Haptics.impact(.soft)
        repository.decrementCompletion(for: habit)
      } label: {
        Label(minusButtonTitle, systemImage: "minus.circle.fill")
          .font(.system(size: 17, weight: .semibold))
          .foregroundStyle(habit.completedCountToday > 0 ? habit.color : .secondary)
          .frame(maxWidth: .infinity)
          .padding(.vertical, 17)
          .background(habit.color.opacity(habit.completedCountToday > 0 ? 0.12 : 0.06))
          .clipShape(RoundedRectangle(cornerRadius: 20))
      }
      .buttonStyle(.plain)
      .disabled(habit.completedCountToday == 0)

      Button {
        if habit.completedCountToday + 1 >= habit.dailyTargetCount {
          Haptics.notification(.success)
        } else {
          Haptics.selection()
        }

        repository.incrementCompletion(for: habit)
      } label: {
        Label(plusButtonTitle, systemImage: plusButtonSymbol)
          .font(.system(size: 17, weight: .semibold))
          .foregroundStyle(habit.isCompletedToday ? .white : habit.color)
          .frame(maxWidth: .infinity)
          .padding(.vertical, 17)
          .background(habit.isCompletedToday ? habit.color : habit.color.opacity(0.12))
          .clipShape(RoundedRectangle(cornerRadius: 20))
      }
      .buttonStyle(.plain)
      .disabled(habit.isCompletedToday)
      .opacity(habit.isCompletedToday ? 0.78 : 1)
    }
  }

  private var plusButtonTitle: String {
    if habit.dailyTargetCount == 1 {
      return habit.isCompletedToday ? "Completed!" : "Mark as Done"
    }

    if habit.isCompletedToday {
      return "Completed Today"
    }

    return "Log Another Check-In"
  }

  private var plusButtonSymbol: String {
    habit.isCompletedToday ? "checkmark.circle.fill" : "plus.circle.fill"
  }

  private var minusButtonTitle: String {
    if habit.dailyTargetCount == 1 {
      return "Undo"
    }
    return "Remove Check-In"
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

extension View {
  fileprivate func detailEntrance(_ isVisible: Bool, delay: Double) -> some View {
    self
      .opacity(isVisible ? 1 : 0)
      .offset(y: isVisible ? 0 : 18)
      .scaleEffect(isVisible ? 1 : 0.98)
      .animation(
        .spring(response: 0.52, dampingFraction: 0.84).delay(delay),
        value: isVisible
      )
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
        .contentTransition(.numericText())
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
