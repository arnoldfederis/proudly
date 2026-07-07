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
  @Environment(SubscriptionStore.self) private var subscriptionStore

  @Environment(FocusTimerStore.self) private var focusTimerStore
  @State private var habit: Habit
  @State private var isEditPresented = false
  @State private var isArchiveConfirmationPresented = false
  @State private var isReplaceTimerConfirmationPresented = false
  @State private var animateContent = false
  @State private var hasOfferedCompletion = false
  @State private var displayedMonth: Date = Calendar.current.startOfMonth(for: .now)
  @State private var showPaywall = false

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
          if habit.hasFocusTimer || isThisHabitsTimerActive {
            focusTimerCard
              .detailEntrance(animateContent, delay: 0.09)
          }
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
    .toolbar(.hidden, for: .tabBar)
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
    .sheet(isPresented: $showPaywall) {
      ProudlyPlusView()
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
    Group {
      if subscriptionStore.hasProudlyPlus {
        VStack(alignment: .leading, spacing: 16) {
          monthHeader
          weekdayHeader
          monthGrid
          monthlySummary
        }
        .padding(20)
        .proudlyGlass()
      } else {
        lockedMonthlyHistoryCard
      }
    }
  }

  private var lockedMonthlyHistoryCard: some View {
    Button {
      Haptics.selection()
      showPaywall = true
    } label: {
      VStack(alignment: .leading, spacing: 14) {
        HStack(spacing: 12) {
          ZStack {
            Circle()
              .fill(habit.color.opacity(0.15))
              .frame(width: 34, height: 34)
            Image(systemName: "calendar")
              .font(.system(size: 15, weight: .semibold))
              .foregroundStyle(habit.color)
          }
          VStack(alignment: .leading, spacing: 2) {
            Text("Monthly History")
              .font(.system(size: 15, weight: .semibold))
              .foregroundStyle(.primary)
            Text("See your full month at a glance.")
              .font(.caption)
              .foregroundStyle(.secondary)
          }
          Spacer()
          PlusBadge()
        }

        ZStack {
          VStack(alignment: .leading, spacing: 12) {
            weekdayHeader
            monthGrid
          }
          .blur(radius: 6)
          .allowsHitTesting(false)
          .frame(maxHeight: 200, alignment: .top)
          .clipped()

          VStack(spacing: 8) {
            Image(systemName: "lock.fill")
              .font(.system(size: 20, weight: .semibold))
              .foregroundStyle(habit.color)
            Text("Unlock with Proudly Plus")
              .font(.system(size: 14, weight: .semibold))
              .foregroundStyle(.primary)
          }
          .padding(.horizontal, 16)
          .padding(.top, 10)
          .padding(.bottom, 18)
          .background(.ultraThinMaterial, in: Capsule())
        }
      }
      .padding(20)
      .proudlyGlass()
    }
    .buttonStyle(.plain)
  }

  private var monthHeader: some View {
    HStack(spacing: 12) {
      ZStack {
        Circle()
          .fill(habit.color.opacity(0.15))
          .frame(width: 34, height: 34)
        Image(systemName: "calendar")
          .font(.system(size: 15, weight: .semibold))
          .foregroundStyle(habit.color)
      }

      VStack(alignment: .leading, spacing: 2) {
        Text("Monthly History")
          .font(.system(size: 15, weight: .semibold))
          .foregroundStyle(.primary)
        Text(monthTitle)
          .font(.caption)
          .foregroundStyle(.secondary)
      }

      Spacer()

      Button {
        shiftMonth(by: -1)
      } label: {
        Image(systemName: "chevron.left")
          .font(.system(size: 13, weight: .bold))
          .foregroundStyle(habit.color)
          .frame(width: 32, height: 32)
          .background(habit.color.opacity(0.12), in: Circle())
      }
      .buttonStyle(.plain)

      Button {
        shiftMonth(by: 1)
      } label: {
        Image(systemName: "chevron.right")
          .font(.system(size: 13, weight: .bold))
          .foregroundStyle(canGoNextMonth ? habit.color : .secondary)
          .frame(width: 32, height: 32)
          .background(
            (canGoNextMonth ? habit.color : Color.secondary).opacity(0.12), in: Circle())
      }
      .buttonStyle(.plain)
      .disabled(!canGoNextMonth)
    }
  }

  private var weekdayHeader: some View {
    HStack(spacing: 0) {
      ForEach(orderedWeekdaySymbols, id: \.self) { symbol in
        Text(symbol)
          .font(.caption2.weight(.semibold))
          .foregroundStyle(.secondary)
          .frame(maxWidth: .infinity)
      }
    }
  }

  private var monthGrid: some View {
    let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)
    return LazyVGrid(columns: columns, spacing: 6) {
      ForEach(monthCells, id: \.self) { cell in
        monthCellView(for: cell)
      }
    }
  }

  private func monthCellView(for cell: MonthCell) -> some View {
    Group {
      switch cell {
      case .empty:
        Color.clear.frame(height: 40)
      case .day(let date, let dateKey, let isFuture):
        let count = habit.completionCountsByDate[dateKey] ?? 0
        let target = max(habit.dailyTargetCount, 1)
        let ratio = min(Double(count) / Double(target), 1)
        let isToday = Calendar.current.isDateInToday(date)
        let dayNumber = Calendar.current.component(.day, from: date)

        ZStack {
          RoundedRectangle(cornerRadius: 10, style: .continuous)
            .fill(habit.color.opacity(ratio == 0 ? 0.06 : 0.15 + ratio * 0.55))
          if isToday {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
              .stroke(habit.color, lineWidth: 1.5)
          }
          VStack(spacing: 2) {
            Text("\(dayNumber)")
              .font(.system(size: 13, weight: ratio >= 1 ? .bold : .medium))
              .foregroundStyle(
                isFuture
                  ? .secondary
                  : (ratio >= 0.5 ? Color.white : Color.primary))
            if count > 0 && target > 1 {
              Text("\(count)/\(target)")
                .font(.system(size: 8, weight: .semibold))
                .foregroundStyle(ratio >= 0.5 ? Color.white.opacity(0.9) : .secondary)
            }
          }
        }
        .frame(height: 40)
        .opacity(isFuture ? 0.4 : 1)
      }
    }
  }

  private var monthlySummary: some View {
    let stats = monthStats
    return HStack(spacing: 20) {
      summaryPill(value: "\(stats.completedDays)", label: "days done")
      summaryPill(value: "\(stats.totalCheckIns)", label: "check-ins")
      summaryPill(value: "\(stats.completionRate)%", label: "of month")
    }
    .frame(maxWidth: .infinity)
    .padding(.top, 4)
  }

  private func summaryPill(value: String, label: String) -> some View {
    VStack(spacing: 2) {
      Text(value)
        .font(.system(size: 16, weight: .bold))
        .foregroundStyle(habit.color)
      Text(label)
        .font(.caption2)
        .foregroundStyle(.secondary)
    }
    .frame(maxWidth: .infinity)
  }

  private enum MonthCell: Hashable {
    case empty(Int)
    case day(Date, String, Bool)
  }

  private var monthCells: [MonthCell] {
    let calendar = Calendar.current
    guard
      let range = calendar.range(of: .day, in: .month, for: displayedMonth),
      let firstDay = calendar.date(
        from: calendar.dateComponents([.year, .month], from: displayedMonth))
    else { return [] }

    let weekday = calendar.component(.weekday, from: firstDay)
    let leadingBlanks = (weekday - calendar.firstWeekday + 7) % 7
    let today = calendar.startOfDay(for: .now)

    var cells: [MonthCell] = (0..<leadingBlanks).map { MonthCell.empty($0) }
    for offset in 0..<range.count {
      guard let date = calendar.date(byAdding: .day, value: offset, to: firstDay) else { continue }
      let dateKey = HabitRepository.dateKey(for: date)
      let isFuture = calendar.startOfDay(for: date) > today
      cells.append(.day(date, dateKey, isFuture))
    }
    return cells
  }

  private var orderedWeekdaySymbols: [String] {
    let calendar = Calendar.current
    let symbols = calendar.veryShortStandaloneWeekdaySymbols
    let start = calendar.firstWeekday - 1
    return Array(symbols[start...] + symbols[..<start])
  }

  private var monthTitle: String {
    let formatter = DateFormatter()
    formatter.setLocalizedDateFormatFromTemplate("MMMM y")
    return formatter.string(from: displayedMonth)
  }

  private var canGoNextMonth: Bool {
    let calendar = Calendar.current
    let currentMonthStart = calendar.startOfMonth(for: .now)
    return displayedMonth < currentMonthStart
  }

  private func shiftMonth(by delta: Int) {
    let calendar = Calendar.current
    guard let next = calendar.date(byAdding: .month, value: delta, to: displayedMonth) else {
      return
    }
    if delta > 0, calendar.startOfMonth(for: next) > calendar.startOfMonth(for: .now) {
      return
    }
    Haptics.selection()
    displayedMonth = calendar.startOfMonth(for: next)
  }

  private struct MonthStats {
    let completedDays: Int
    let totalCheckIns: Int
    let completionRate: Int
  }

  private var monthStats: MonthStats {
    let target = max(habit.dailyTargetCount, 1)
    var completedDays = 0
    var totalCheckIns = 0
    var dayCount = 0
    for cell in monthCells {
      guard case .day(_, let dateKey, let isFuture) = cell, !isFuture else { continue }
      dayCount += 1
      let count = habit.completionCountsByDate[dateKey] ?? 0
      totalCheckIns += count
      if count >= target { completedDays += 1 }
    }
    let rate = dayCount == 0 ? 0 : Int(Double(completedDays) / Double(dayCount) * 100)
    return MonthStats(
      completedDays: completedDays, totalCheckIns: totalCheckIns, completionRate: rate)
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

  // MARK: - Focus Timer

  private var isThisHabitsTimerActive: Bool {
    focusTimerStore.session?.habitID == habit.id
  }

  private var focusTimerCard: some View {
    let remaining = focusTimerStore.remaining()
    let isPaused = focusTimerStore.isPaused && isThisHabitsTimerActive
    let isComplete = isThisHabitsTimerActive && focusTimerStore.isComplete()
    let configuredDuration = TimeInterval((habit.focusDurationMinutes ?? 25) * 60)
    let displayInterval =
      isThisHabitsTimerActive ? (isComplete ? 0 : remaining) : configuredDuration

    return VStack(alignment: .leading, spacing: 14) {
      HStack {
        Label("Focus Timer", systemImage: "timer")
          .font(.system(size: 15, weight: .semibold))
          .foregroundStyle(habit.color)
        Spacer()
        if isThisHabitsTimerActive, !isComplete {
          Text(isPaused ? "Paused" : "Running")
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
        }
      }

      Text(FocusTimerStore.formatted(displayInterval))
        .font(.system(size: 44, weight: .bold, design: .rounded))
        .monospacedDigit()
        .foregroundStyle(.primary)
        .contentTransition(.numericText())

      if isComplete {
        VStack(alignment: .leading, spacing: 6) {
          Text("Focus complete 🌿")
            .font(.system(size: 16, weight: .semibold))
          Text("Mark \(habit.name) when you're ready.")
            .font(.caption)
            .foregroundStyle(.secondary)
        }
      } else if isPaused {
        Text("Paused with \(FocusTimerStore.formatted(remaining)) left.")
          .font(.caption)
          .foregroundStyle(.secondary)
      } else if isThisHabitsTimerActive {
        Text("Stay with it. You're doing great.")
          .font(.caption)
          .foregroundStyle(.secondary)
      } else if habit.hasFocusTimer {
        Text("\(habit.focusDurationMinutes ?? 25) minutes • gentle and optional.")
          .font(.caption)
          .foregroundStyle(.secondary)
      }

      focusTimerControls(isComplete: isComplete, isPaused: isPaused)
    }
    .padding(20)
    .proudlyGlass()
    .onChange(of: focusTimerStore.tick) { _, _ in
      handleFocusTimerTick()
    }
  }

  @ViewBuilder
  private func focusTimerControls(isComplete: Bool, isPaused: Bool) -> some View {
    if isComplete {
      HStack(spacing: 10) {
        Button {
          Haptics.notification(.success)
          if !habit.isCompletedToday {
            repository.incrementCompletion(for: habit)
          }
          focusTimerStore.stop()
        } label: {
          Label("Complete Habit", systemImage: "checkmark.circle.fill")
            .font(.system(size: 16, weight: .semibold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(habit.color)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)

        Button {
          Haptics.selection()
          focusTimerStore.stop()
        } label: {
          Label("Dismiss", systemImage: "xmark.circle.fill")
            .font(.system(size: 16, weight: .semibold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(habit.color.opacity(0.12))
            .foregroundStyle(habit.color)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
      }
    } else if isThisHabitsTimerActive {
      HStack(spacing: 10) {
        Button {
          Haptics.selection()
          if isPaused {
            focusTimerStore.resume()
          } else {
            focusTimerStore.pause()
          }
        } label: {
          Label(
            isPaused ? "Resume" : "Pause",
            systemImage: isPaused ? "play.circle.fill" : "pause.circle.fill"
          )
          .font(.system(size: 16, weight: .semibold))
          .frame(maxWidth: .infinity)
          .padding(.vertical, 14)
          .background(habit.color.opacity(0.16))
          .foregroundStyle(habit.color)
          .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)

        Button {
          Haptics.impact(.soft)
          focusTimerStore.stop()
        } label: {
          Label("End", systemImage: "stop.circle.fill")
            .font(.system(size: 16, weight: .semibold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(habit.color.opacity(0.08))
            .foregroundStyle(.primary)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
      }
    } else {
      Button {
        Haptics.selection()
        if focusTimerStore.isRunning {
          isReplaceTimerConfirmationPresented = true
        } else {
          startFocusTimer()
        }
      } label: {
        Label("Start Focus", systemImage: "play.circle.fill")
          .font(.system(size: 17, weight: .semibold))
          .frame(maxWidth: .infinity)
          .padding(.vertical, 15)
          .background(habit.color)
          .foregroundStyle(.white)
          .clipShape(RoundedRectangle(cornerRadius: 18))
      }
      .buttonStyle(.plain)
      .confirmationDialog(
        "Stop current focus session?",
        isPresented: $isReplaceTimerConfirmationPresented,
        titleVisibility: .visible
      ) {
        Button("Stop and start new", role: .destructive) {
          focusTimerStore.stop()
          startFocusTimer()
        }
      } message: {
        Text("Starting this timer will stop your current focus session.")
      }
    }
  }

  private func startFocusTimer() {
    let duration = TimeInterval(max(habit.focusDurationMinutes ?? 25, 1) * 60)
    hasOfferedCompletion = false
    focusTimerStore.start(habit: habit, duration: duration)
  }

  private func handleFocusTimerTick() {
    guard isThisHabitsTimerActive, focusTimerStore.isComplete(), !hasOfferedCompletion else {
      return
    }
    hasOfferedCompletion = true
    Haptics.notification(.success)
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
  .environment(FocusTimerStore.shared)
}

extension Calendar {
  fileprivate func startOfMonth(for date: Date) -> Date {
    self.date(from: dateComponents([.year, .month], from: date)) ?? startOfDay(for: date)
  }
}
