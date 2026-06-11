//
//  HabitDetailView.swift
//  Proudly
//
//  Created by Arnolfo Federis on 6/11/26.
//

import SwiftUI

struct HabitDetailView: View {
  @State private var habit: Habit
  let onSave: (Habit) -> Void
  @State private var isDone = false
  @State private var isEditPresented: Bool = false

  private let completedDays: Set<Int> = [
    1, 3, 5, 6, 7, 8, 10, 12, 14, 15, 16, 18, 20, 22, 24, 25, 26, 27, 28, 29,
  ]

  init(habit: Habit, onSave: @escaping (Habit) -> Void = { _ in }) {
    _habit = State(initialValue: habit)
    self.onSave = onSave
  }

  var body: some View {
    ZStack {
      ProudlyTheme.backgroundGradient.ignoresSafeArea()

      ScrollView {
        VStack(spacing: 24) {
          iconBubble
          statsRow
          calendarCard
          markDoneButton
          Spacer(minLength: 40)
        }
        .padding(.horizontal, 20)
      }
    }
    .navigationTitle(habit.name)
    .navigationBarTitleDisplayMode(.inline)
    .onAppear { isDone = habit.isCompletedToday }
    .overlay(alignment: .bottomTrailing) {
      FloatingActionButton(systemImage: "pencil", color: habit.color) {
        isEditPresented = true
      }
      .padding(.bottom, 5)
      .padding(.trailing, 20)
    }
    .sheet(isPresented: $isEditPresented) {
      HabitFormView(habit: habit) { updatedHabit in
        habit = updatedHabit
        onSave(updatedHabit)
        isEditPresented = false
      }
    }
  }

  private var iconBubble: some View {
    VStack(spacing: 10) {
      ZStack {
        Circle()
          .fill(habit.color.opacity(0.15))
          .frame(width: 96, height: 96)
        Image(systemName: habit.icon)
          .font(.system(size: 42))
          .foregroundStyle(habit.color)
      }
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
        unit: "days",
        color: ProudlyTheme.pink
      )
      StatCard(
        label: "Best Streak",
        value: "\(habit.bestStreak)",
        unit: "days",
        color: ProudlyTheme.purple
      )
    }
  }

  private var calendarCard: some View {
    VStack(alignment: .leading, spacing: 14) {
      Text("June 2026")
        .font(.system(size: 16, weight: .semibold))

      LazyVGrid(
        columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 7),
        spacing: 6
      ) {
        ForEach(1...30, id: \.self) { day in
          ZStack {
            Circle()
              .fill(completedDays.contains(day) ? habit.color : Color.clear)
              .frame(height: 36)
            Text("\(day)")
              .font(.system(size: 13, weight: completedDays.contains(day) ? .semibold : .regular))
              .foregroundStyle(completedDays.contains(day) ? .white : .primary)
          }
        }
      }
    }
    .padding(20)
    .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 22))
  }

  private var markDoneButton: some View {
    Button {
      withAnimation(.spring(response: 0.4, dampingFraction: 0.65)) {
        isDone.toggle()
        Haptics.notification(isDone ? .success : .warning)
      }
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
    .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 20))
  }
}

#Preview {
  NavigationStack {
    HabitDetailView(habit: Habit.samples[1])
  }
}
