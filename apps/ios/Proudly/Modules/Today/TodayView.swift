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
  @Environment(AppNavigationStore.self) private var appNavigationStore
  @Environment(\.scenePhase) private var scenePhase
  @State private var selectedHabit: Habit?
  @State private var isAddPresented: Bool = false
  @State private var isPaywallPresented: Bool = false
  @State private var showsCelebrationCard = false
  @State private var displayedCompletedCount = 0
  @State private var isAwaitingCompletedCountSync = false
  @State private var togglingHabitIDs: Set<UUID> = []
  @State private var currentDateKey: String = LocalDay.key()
  @State private var midnightRefreshTask: Task<Void, Never>?

  private let freeHabitLimit = 3

  private var completedCount: Int { displayedCompletedCount }
  private var repositoryCompletedCount: Int {
    repository.activeHabits.filter(\.isCompletedToday).count
  }
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
            if completedCount > 0 {
              progressCard
                .transition(.move(edge: .top).combined(with: .opacity).combined(with: .scale))
            }
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
    .onAppear {
      displayedCompletedCount = repositoryCompletedCount
      showsCelebrationCard = displayedCompletedCount > 0
      handleLocalDayChangeIfNeeded()
      scheduleMidnightRefresh()
      navigateToPendingHabitIfNeeded()
    }
    .onDisappear {
      midnightRefreshTask?.cancel()
      midnightRefreshTask = nil
    }
    .onChange(of: scenePhase) { _, phase in
      guard phase == .active else {
        midnightRefreshTask?.cancel()
        midnightRefreshTask = nil
        return
      }
      handleLocalDayChangeIfNeeded()
      scheduleMidnightRefresh()
    }
    .onChange(of: completedCount) { _, newValue in
      withAnimation(.spring(response: 0.42, dampingFraction: 0.8)) {
        showsCelebrationCard = newValue > 0
      }
    }
    .onChange(of: repository.activeHabits) { _, _ in
      let actualCompletedCount = repositoryCompletedCount
      guard !isAwaitingCompletedCountSync || actualCompletedCount == displayedCompletedCount else {
        return
      }

      withAnimation(.spring(response: 0.32, dampingFraction: 0.78)) {
        displayedCompletedCount = actualCompletedCount
        isAwaitingCompletedCountSync = false
      }

      navigateToPendingHabitIfNeeded()
    }
    .onChange(of: appNavigationStore.pendingHabitID, initial: true) { _, _ in
      navigateToPendingHabitIfNeeded()
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
          .symbolEffect(.bounce, value: completedCount)
        Text("\(completedCount) of \(totalCount) habits completed")
          .font(.subheadline)
          .foregroundStyle(.secondary)
          .contentTransition(.numericText())

        ProgressView(value: progressRatio)
          .progressViewStyle(.linear)
          .tint(theme.activeTheme.accentColor)
          .frame(maxWidth: .infinity)
      }
    }
    .padding(20)
    .proudlyGlass()
    .scaleEffect(showsCelebrationCard ? 1 : 0.96)
    .opacity(showsCelebrationCard ? 1 : 0)
  }

  private var habitsSection: some View {
    LazyVStack(spacing: 10) {
      ForEach(repository.activeHabits) { habit in
        HabitRowView(
          habit: habit,
          isToggleDisabled: togglingHabitIDs.contains(habit.id),
          onToggle: {
            toggleHabit(habit)
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

  private func handleLocalDayChangeIfNeeded() {
    let todayKey = LocalDay.key()
    guard todayKey != currentDateKey else { return }
    currentDateKey = todayKey
    repository.refresh()
    withAnimation(.spring(response: 0.32, dampingFraction: 0.78)) {
      displayedCompletedCount = repositoryCompletedCount
      showsCelebrationCard = displayedCompletedCount > 0
      isAwaitingCompletedCountSync = false
    }
  }

  private func scheduleMidnightRefresh() {
    midnightRefreshTask?.cancel()
    let interval = LocalDay.timeUntilNextMidnight() + 1
    midnightRefreshTask = Task { @MainActor in
      try? await Task.sleep(for: .seconds(interval))
      guard !Task.isCancelled else { return }
      handleLocalDayChangeIfNeeded()
      scheduleMidnightRefresh()
    }
  }

  private func navigateToPendingHabitIfNeeded() {
    guard let pendingHabitID = appNavigationStore.pendingHabitID,
      let pendingHabit = repository.activeHabits.first(where: { $0.id == pendingHabitID })
    else {
      return
    }

    selectedHabit = pendingHabit
    appNavigationStore.consumePendingHabitID()
  }

  private func toggleHabit(_ habit: Habit) {
    guard !togglingHabitIDs.contains(habit.id) else { return }
    guard let currentHabit = repository.activeHabits.first(where: { $0.id == habit.id }) else {
      return
    }

    togglingHabitIDs.insert(habit.id)

    let target = max(currentHabit.dailyTargetCount, 1)
    let currentCount = currentHabit.completedCountToday
    let nextCount =
      currentHabit.isCompletedToday
      ? max(currentCount - 1, 0)
      : min(currentCount + 1, currentHabit.dailyTargetCount)
    let wasComplete = currentCount >= target
    let reachesCompletion = nextCount >= target
    let completedDelta =
      wasComplete == reachesCompletion ? 0 : (reachesCompletion ? 1 : -1)

    if completedDelta != 0 {
      withAnimation(.spring(response: 0.32, dampingFraction: 0.78)) {
        displayedCompletedCount = max(0, displayedCompletedCount + completedDelta)
        isAwaitingCompletedCountSync = true
      }
    }

    if currentHabit.isCompletedToday {
      Haptics.impact(.soft)
      repository.decrementCompletion(for: currentHabit)
    } else if reachesCompletion {
      Haptics.notification(.success)
      repository.incrementCompletion(for: currentHabit)
    } else {
      Haptics.selection()
      repository.incrementCompletion(for: currentHabit)
    }

    Task { @MainActor in
      try? await Task.sleep(for: .milliseconds(250))
      togglingHabitIDs.remove(habit.id)
      if repositoryCompletedCount == displayedCompletedCount {
        isAwaitingCompletedCountSync = false
      }
    }
  }
}

struct HabitRowView: View {
  let habit: Habit
  let isToggleDisabled: Bool
  let onToggle: () -> Void
  let onNavigate: () -> Void

  @State private var displayedCount: Int
  @State private var isAwaitingRepositorySync = false

  init(
    habit: Habit,
    isToggleDisabled: Bool,
    onToggle: @escaping () -> Void,
    onNavigate: @escaping () -> Void
  ) {
    self.habit = habit
    self.isToggleDisabled = isToggleDisabled
    self.onToggle = onToggle
    self.onNavigate = onNavigate
    _displayedCount = State(initialValue: habit.completedCountToday)
  }

  private var displayedProgress: Double {
    min(Double(displayedCount) / Double(max(habit.dailyTargetCount, 1)), 1)
  }

  private var displayedPercentText: String {
    "\(Int((displayedProgress * 100).rounded()))%"
  }

  private var displayedProgressLabel: String {
    "\(displayedCount)/\(max(habit.dailyTargetCount, 1))"
  }

  private var isDisplayedComplete: Bool {
    displayedCount >= max(habit.dailyTargetCount, 1)
  }

  var body: some View {
    HStack(spacing: 14) {
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
                .contentTransition(.numericText())
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
                  .contentTransition(.numericText())
              }
              Text("\(displayedCount) of \(habit.dailyTargetCount) completed today")
                .font(.caption)
                .foregroundStyle(.secondary)
                .contentTransition(.numericText())
            }
          }
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .contentShape(Rectangle())
      .onTapGesture(perform: onNavigate)
      .accessibilityAddTraits(.isButton)

      Button {
        let target = max(habit.dailyTargetCount, 1)
        let nextCount =
          isDisplayedComplete
          ? max(displayedCount - 1, 0)
          : min(displayedCount + 1, target)

        withAnimation(.spring(response: 0.32, dampingFraction: 0.78)) {
          displayedCount = nextCount
          isAwaitingRepositorySync = true
        }

        onToggle()
      } label: {
        VStack(spacing: 6) {
          ZStack {
            Circle()
              .stroke(Color.gray.opacity(0.18), lineWidth: 4)
              .frame(width: 40, height: 40)

            if isDisplayedComplete {
              Circle()
                .stroke(habit.color, lineWidth: 4)
                .frame(width: 40, height: 40)
                .animation(
                  .spring(response: 0.32, dampingFraction: 0.78),
                  value: isDisplayedComplete)
            } else {
              Circle()
                .trim(from: 0, to: displayedProgress)
                .stroke(
                  habit.color,
                  style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .frame(width: 40, height: 40)
                .animation(
                  .spring(response: 0.32, dampingFraction: 0.78),
                  value: displayedProgress)
            }

            if isDisplayedComplete {
              Circle()
                .fill(habit.color)
                .frame(width: 30, height: 30)
              Image(systemName: "checkmark")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.white)
                .symbolEffect(.bounce, value: displayedCount)
            } else if habit.dailyTargetCount == 1 {
              Circle()
                .fill(Color.white.opacity(0.08))
                .frame(width: 30, height: 30)
            } else {
              Text(displayedProgressLabel)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(.primary)
                .contentTransition(.numericText())
            }
          }
          .frame(width: 40, height: 40)

          if habit.dailyTargetCount > 1 {
            Text(displayedPercentText)
              .font(.caption2.weight(.semibold))
              .foregroundStyle(.secondary)
              .frame(maxWidth: .infinity, alignment: .center)
              .contentTransition(.numericText())
          }
        }
        .frame(width: 48, alignment: .center)
      }
      .buttonStyle(.plain)
      .disabled(isToggleDisabled)
    }
    .frame(maxWidth: .infinity)
    .padding(.horizontal, 16)
    .padding(.vertical, 13)
    .proudlyGlass(cornerRadius: 18)
    .onChange(of: habit.completedCountToday, initial: true) { _, newValue in
      guard !isAwaitingRepositorySync || newValue == displayedCount else { return }

      withAnimation(.spring(response: 0.32, dampingFraction: 0.78)) {
        displayedCount = newValue
        isAwaitingRepositorySync = false
      }
    }
    .onChange(of: isToggleDisabled) { _, disabled in
      if !disabled, habit.completedCountToday == displayedCount {
        isAwaitingRepositorySync = false
      }
    }
  }
}

#Preview {
  TodayView()
    .environment(ThemeViewModel())
    .environment(SubscriptionStore())
    .environment(HabitRepository.preview)
    .environment(AppNavigationStore.shared)
}
