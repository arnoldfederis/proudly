//
//  HabitDetailView.swift
//  Proudly
//
//  Created by Arnolfo Federis on 6/11/26.
//

import SwiftUI

struct HabitDetailView: View {
  @Environment(ThemeViewModel.self) private var theme
  @Environment(HabitRepository.self) private var repository
  @Environment(SubscriptionStore.self) private var subscriptionStore
  @State private var habit: Habit
  let onSave: (Habit) -> Void
  @State private var isDone = false
  @State private var isEditPresented: Bool = false
  @State private var isPaywallPresented: Bool = false

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
    .onAppear { isDone = habit.isCompletedToday }
    .onChange(of: repository.activeHabits) { _, updated in
      if let fresh = updated.first(where: { $0.id == habit.id }) {
        habit = fresh
        isDone = fresh.isCompletedToday
      }
    }
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button(action: presentEditHabit) {
          Image(systemName: "pencil")
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
    .sheet(isPresented: $isPaywallPresented) {
      ProudlyPlusView()
    }
  }

  private var iconBubble: some View {
    VStack(spacing: 10) {
      HabitIconView(icon: habit.icon, color: habit.color, fontSize: 42, circleSize: 96)
        .padding(.top, 20)

      Text(habit.note)
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)
    }
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
          VStack(spacing: 6) {
            ZStack {
              Circle()
                .fill(
                  habit.completedDates.contains(dateKey) ? habit.color : Color.gray.opacity(0.15)
                )
                .frame(width: 36, height: 36)
              if habit.completedDates.contains(dateKey) {
                Image(systemName: "checkmark")
                  .font(.system(size: 12, weight: .bold))
                  .foregroundStyle(.white)
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

  @ViewBuilder
  private var monthlyHistoryCard: some View {
    if subscriptionStore.hasProudlyPlus {
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
        Image(systemName: "chevron.right")
          .font(.system(size: 13))
          .foregroundStyle(.tertiary)
      }
      .padding(16)
      .proudlyGlass(cornerRadius: 18)
    } else {
      Button {
        isPaywallPresented = true
      } label: {
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
            Text("Unlock full habit history with Proudly Plus.")
              .font(.caption)
              .foregroundStyle(.secondary)
          }
          Spacer()
          Image(systemName: "lock.fill")
            .font(.system(size: 13))
            .foregroundStyle(habit.color)
        }
        .padding(16)
        .proudlyGlass(cornerRadius: 18)
      }
      .buttonStyle(.plain)
    }
  }

  private var markDoneButton: some View {
    Button {
      let willBeDone = !isDone
      let todayKey = HabitRepository.dateKey(for: .now)
      withAnimation(.spring(response: 0.4, dampingFraction: 0.65)) {
        isDone = willBeDone
        if willBeDone {
          habit.completedDates.insert(todayKey)
        } else {
          habit.completedDates.remove(todayKey)
        }
      }
      Haptics.notification(willBeDone ? .success : .warning)
      repository.toggleCompletion(for: habit)
    } label: {
      Label(
        isDone ? "Completed!" : "Mark as Done",
        systemImage: isDone ? "checkmark.circle.fill" : "circle"
      )
      .font(.system(size: 17, weight: .semibold))
      .foregroundStyle(isDone ? .white : habit.color)
      .frame(maxWidth: .infinity)
      .padding(.vertical, 17)
      .background(isDone ? habit.color : habit.color.opacity(0.12))
      .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    .buttonStyle(.plain)
  }

  private var lastSevenDays: [String] {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return (0..<7).reversed().map { offset in
      let date = Calendar.current.date(byAdding: .day, value: -offset, to: .now) ?? .now
      return formatter.string(from: date)
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
