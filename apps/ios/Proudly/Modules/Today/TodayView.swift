//
//  TodayView.swift
//  Proudly
//
//  Created by Arnolfo Federis on 6/9/26.
//

import SwiftUI

struct TodayView: View {
  @Environment(ThemeViewModel.self) private var theme
  @Environment(SubscriptionStore.self) private var subscriptionStore
  @Environment(HabitRepository.self) private var repository
  @State private var selectedHabit: Habit?
  @State private var isAddPresented: Bool = false
  @State private var isPaywallPresented: Bool = false

  private let freeHabitLimit = 3

  private var completedCount: Int { repository.activeHabits.filter(\.isCompletedToday).count }
  private var totalCount: Int { repository.activeHabits.count }
  private var progressRatio: Double {
    guard totalCount > 0 else { return 0 }
    return Double(completedCount) / Double(totalCount)
  }

  var body: some View {
    NavigationStack {
      ZStack {
        theme.activeTheme.backgroundGradient.ignoresSafeArea()

        ScrollView {
          LazyVStack(spacing: 20) {
            VStack(alignment: .leading) {
              Text("What will make you proud today?")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            progressCard
            habitsSection
            gentleMessageCard
            Spacer(minLength: 80)
          }
          .padding(.horizontal, 20)
        }
      }
      .navigationTitle("Today")
      .navigationBarTitleDisplayMode(.large)
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button(action: presentAddHabit) {
            Image(systemName: "plus")
          }
          .tint(theme.activeTheme.accentColor)
        }
      }
      .navigationDestination(item: $selectedHabit) { habit in
        HabitDetailView(habit: habit) { updatedHabit in
          repository.updateHabit(updatedHabit)
        }
      }
      .sheet(isPresented: $isAddPresented) {
        HabitFormView { habit in
          repository.addHabit(habit)
          isAddPresented = false
        }
      }
      .sheet(isPresented: $isPaywallPresented) {
        ProudlyPlusView()
      }
    }
  }

  private var progressCard: some View {
    HStack(spacing: 16) {
      ZStack {
        Circle()
          .fill(Color.clear)
          .frame(width: 56, height: 56)

        Text("😊")
          .font(.system(size: 52, weight: .bold))
      }

      VStack(alignment: .leading, spacing: 6) {
        Text("You're doing great! 👏")
          .font(.headline)
        Text("\(completedCount) of \(totalCount) habits completed")
          .font(.subheadline)
          .foregroundStyle(.secondary)

        ProgressView(value: progressRatio)
          .progressViewStyle(.linear)
          .tint(theme.activeTheme.accentColor)
          .frame(maxWidth: .infinity)
      }
    }
    .padding(20)
    .proudlyGlass()
  }

  private var habitsSection: some View {
    LazyVStack(spacing: 10) {
      ForEach(repository.activeHabits) { habit in
        HabitRowView(
          habit: habit,
          onToggle: {
            let nextCount =
              habit.isCompletedToday
              ? max(habit.completedCountToday - 1, 0)
              : min(habit.completedCountToday + 1, habit.dailyTargetCount)
            let reachesCompletion = nextCount >= habit.dailyTargetCount

            if habit.isCompletedToday {
              Haptics.impact(.soft)
            } else if reachesCompletion {
              Haptics.notification(.success)
            } else {
              Haptics.selection()
            }
            repository.toggleCompletion(for: habit)
          },
          onNavigate: { selectedHabit = habit }
        )
      }
    }
  }

  private var gentleMessageCard: some View {
    HStack(spacing: 14) {
      ZStack {
        Circle()
          .fill(ProudlyTheme.pink.opacity(0.18))
          .frame(width: 46, height: 46)
        Image(systemName: "heart.fill")
          .font(.title2)
          .foregroundStyle(ProudlyTheme.pink)
      }

      VStack(alignment: .leading, spacing: 2) {
        Text("Small wins count.")
          .font(.headline)
        Text("Every step forward matters.")
          .font(.caption)
          .foregroundStyle(.secondary)
      }
      Spacer()
    }
    .padding(18)
    .proudlyGlass(cornerRadius: 18)
  }

  private func presentAddHabit() {
    Haptics.selection()

    if !subscriptionStore.hasProudlyPlus && repository.activeHabits.count >= freeHabitLimit {
      isPaywallPresented = true
    } else {
      isAddPresented = true
    }
  }
}

struct HabitRowView: View {
  let habit: Habit
  let onToggle: () -> Void
  let onNavigate: () -> Void

  var body: some View {
    Button(action: onNavigate) {
      HStack(spacing: 14) {
        HabitIconView(
          icon: habit.icon,
          color: habit.color,
          fontSize: 19,
          circleSize: 46,
          backgroundOpacity: 0.18
        )

        VStack(alignment: .leading, spacing: 3) {
          Text(habit.name)
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(.primary)
          if habit.dailyTargetCount == 1 {
            HStack(spacing: 4) {
              Image(systemName: "flame.fill")
                .font(.caption2)
                .foregroundStyle(ProudlyTheme.pink)
              Text(habit.streakLabel)
                .font(.caption)
                .foregroundStyle(.secondary)
            }
          } else {
            VStack(alignment: .leading, spacing: 2) {
              HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                  .font(.caption2)
                  .foregroundStyle(ProudlyTheme.pink)
                Text(habit.streakLabel)
                  .font(.caption)
                  .foregroundStyle(.secondary)
              }
              Text("\(habit.completedCountToday) of \(habit.dailyTargetCount) completed today")
                .font(.caption)
                .foregroundStyle(.secondary)
                .contentTransition(.numericText())
            }
          }
        }

        Spacer()

        Button(action: onToggle) {
          VStack(alignment: .trailing, spacing: 4) {
            ZStack {
              Circle()
                .stroke(Color.gray.opacity(0.18), lineWidth: 4)
                .frame(width: 40, height: 40)

              Circle()
                .trim(from: 0, to: habit.completionProgressToday)
                .stroke(
                  habit.color,
                  style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .frame(width: 40, height: 40)
                .animation(
                  .spring(response: 0.32, dampingFraction: 0.78),
                  value: habit.completionProgressToday)

              if habit.isCompletedToday {
                Circle()
                  .fill(habit.color)
                  .frame(width: 30, height: 30)
                Image(systemName: "checkmark")
                  .font(.system(size: 13, weight: .bold))
                  .foregroundStyle(.white)
                  .symbolEffect(.bounce, value: habit.completedCountToday)
              } else if habit.dailyTargetCount == 1 {
                Circle()
                  .fill(Color.white.opacity(0.08))
                  .frame(width: 30, height: 30)
              } else {
                Text(habit.todayProgressLabel)
                  .font(.system(size: 9, weight: .bold))
                  .foregroundStyle(.primary)
                  .contentTransition(.numericText())
              }
            }

            if habit.dailyTargetCount > 1 {
              Text(habit.todayProgressPercentText)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
                .contentTransition(.numericText())
            }
          }
        }
        .buttonStyle(.plain)
      }
      .frame(maxWidth: .infinity)
      .padding(.horizontal, 16)
      .padding(.vertical, 13)
      .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
    .proudlyGlass(cornerRadius: 18)
  }
}

#Preview {
  TodayView()
    .environment(ThemeViewModel())
    .environment(SubscriptionStore())
    .environment(HabitRepository.preview)
}
