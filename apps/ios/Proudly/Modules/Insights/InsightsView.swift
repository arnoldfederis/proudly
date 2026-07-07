//
//  InsightsView.swift
//  Proudly
//
//  Created by Arnolfo Federis on 6/9/26.
//

import Charts
import SwiftUI

struct InsightsView: View {
  @Environment(\.colorScheme) private var colorScheme
  @Environment(ThemeViewModel.self) private var theme
  @Environment(HabitRepository.self) private var repository
  @State private var viewModel = InsightsViewModel()
  @State private var selectedDayID: String?
  @State private var selectedWeekdayID: String?
  @State private var animateContent = false
  @AppStorage("insightsSelectedHabitID") private var selectedHabitIDString: String = ""

  var body: some View {
    NavigationStack {
      ZStack {
        theme.activeTheme.backgroundGradient.ignoresSafeArea()

        ScrollView {
          LazyVStack(spacing: 20) {
            habitFilterPicker
            celebrationCard
              .insightsEntrance(animateContent, delay: 0.00)
            momentumCard
              .insightsEntrance(animateContent, delay: 0.04)
            weeklyChartCard
              .insightsEntrance(animateContent, delay: 0.08)
            weekdayPatternCard
              .insightsEntrance(animateContent, delay: 0.12)
            consistencyCard
              .insightsEntrance(animateContent, delay: 0.16)
            heatmapCard
              .insightsEntrance(animateContent, delay: 0.20)
            statsGrid
              .insightsEntrance(animateContent, delay: 0.24)
            Spacer(minLength: 80)
          }
          .padding(.horizontal, 20)
          .padding(.top, 8)
        }
      }
      .navigationTitle("Insights")
      .navigationBarTitleDisplayMode(.large)
    }
    .onAppear {
      refreshViewModel()
      withAnimation(.spring(response: 0.5, dampingFraction: 0.84)) { animateContent = true }
    }
    .onChange(of: repository.activeHabits) { _, _ in
      refreshViewModel()
    }
    .onChange(of: selectedHabitIDString) { _, _ in
      refreshViewModel(animated: true)
      retriggerEntrance()
    }
  }

  // Re-runs the staggered card entrance so content flashes in when the chip switches.
  private func retriggerEntrance() {
    var reset = Transaction()
    reset.disablesAnimations = true
    withTransaction(reset) { animateContent = false }
    DispatchQueue.main.async {
      withAnimation(.spring(response: 0.5, dampingFraction: 0.84)) { animateContent = true }
    }
  }

  private var selectedHabitID: UUID? {
    guard !selectedHabitIDString.isEmpty else { return nil }
    return UUID(uuidString: selectedHabitIDString)
  }

  // App theme color when "All habits" is selected, else the picked habit's color.
  private var chartColor: Color {
    if let selectedHabitID,
      let habit = repository.activeHabits.first(where: { $0.id == selectedHabitID })
    {
      return habit.color
    }
    return theme.activeTheme.accentColor
  }

  private var chartGradient: AnyShapeStyle {
    if let selectedHabitID,
      let habit = repository.activeHabits.first(where: { $0.id == selectedHabitID })
    {
      return AnyShapeStyle(
        LinearGradient(
          colors: [habit.color, habit.color.opacity(0.7)],
          startPoint: .leading, endPoint: .trailing
        )
      )
    }
    return AnyShapeStyle(theme.activeTheme.accentGradient)
  }

  private func refreshViewModel(animated: Bool = false) {
    let habits = repository.activeHabits
    let resolvedID: UUID? = {
      guard let selectedHabitID else { return nil }
      return habits.contains(where: { $0.id == selectedHabitID }) ? selectedHabitID : nil
    }()
    if resolvedID == nil && !selectedHabitIDString.isEmpty {
      selectedHabitIDString = ""
    }
    let apply = {
      viewModel.update(habits: habits, selectedHabitID: resolvedID)
      selectedDayID = nil
      selectedWeekdayID = nil
    }
    if animated {
      withAnimation(.spring(response: 0.5, dampingFraction: 0.82)) { apply() }
    } else {
      apply()
    }
  }

  private var habitFilterPicker: some View {
    let habits = repository.activeHabits
    return ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 8) {
        filterChip(
          label: "All habits",
          isSelected: selectedHabitID == nil,
          color: theme.activeTheme.accentColor
        ) {
          Haptics.selection()
          selectedHabitIDString = ""
        }

        ForEach(habits) { habit in
          filterChip(
            label: habit.name,
            isSelected: selectedHabitID == habit.id,
            color: habit.color
          ) {
            Haptics.selection()
            selectedHabitIDString = habit.id.uuidString
          }
        }
      }
      .padding(.vertical, 2)
    }
    .scrollIndicators(.hidden)
  }

  private func filterChip(
    label: String,
    isSelected: Bool,
    color: Color,
    action: @escaping () -> Void
  ) -> some View {
    Button(action: action) {
      Text(label)
        .font(.system(size: 13, weight: .semibold))
        .foregroundStyle(isSelected ? Color.white : .primary)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
          Capsule().fill(
            isSelected ? AnyShapeStyle(color) : AnyShapeStyle(Color.secondary.opacity(0.12))
          )
        )
    }
    .buttonStyle(.plain)
    .animation(.spring(response: 0.32, dampingFraction: 0.82), value: isSelected)
  }

  private var celebrationCard: some View {
    HStack(spacing: 14) {
      Text("🎉")
        .font(.system(size: 36))
      VStack(alignment: .leading, spacing: 4) {
        Text("Great job this week!")
          .font(.headline)
        Text(
          "You logged \(viewModel.totalCompletions) \(completionUnit(for: viewModel.totalCompletions)) in 7 days."
        )
        .font(.subheadline)
        .foregroundStyle(.secondary)
      }
      Spacer()
    }
    .padding(18)
    .proudlyGlass()
  }

  private var weeklyChartCard: some View {
    VStack(alignment: .leading, spacing: 14) {
      VStack(alignment: .leading, spacing: 6) {
        Text("Your progress this week")
          .font(.system(size: 16, weight: .semibold))

        if let selectedDay {
          Text("\(selectedDay.day): \(selectedDay.count) \(completionUnit(for: selectedDay.count))")
            .font(.caption.weight(.semibold))
            .foregroundStyle(chartColor)
            .contentTransition(.numericText())
        } else {
          Text("Tap a bar to inspect that day.")
            .font(.caption)
            .foregroundStyle(.secondary)
        }
      }

      Chart(viewModel.weeklyData) { item in
        BarMark(
          x: .value("Day", item.day),
          y: .value("Habits", item.count)
        )
        .foregroundStyle(
          selectedDayID == nil || selectedDayID == item.id
            ? chartGradient
            : AnyShapeStyle(Color.secondary.opacity(0.28))
        )
        .cornerRadius(8)
        .annotation(position: .top) {
          if selectedDayID == item.id {
            Text("\(item.count)")
              .font(.caption2.weight(.bold))
              .foregroundStyle(colorScheme == .dark ? .black : .white)
              .padding(.horizontal, 8)
              .padding(.vertical, 4)
              .background(
                colorScheme == .dark ? Color.white.opacity(0.92) : Color.black.opacity(0.88),
                in: Capsule()
              )
          }
        }
      }
      .frame(height: 160)
      .chartOverlay { proxy in
        GeometryReader { geometry in
          Rectangle()
            .fill(.clear)
            .contentShape(Rectangle())
            .gesture(
              DragGesture(minimumDistance: 0)
                .onChanged { value in
                  updateSelectedDay(at: value.location, proxy: proxy, geometry: geometry)
                }
                .onEnded { value in
                  updateSelectedDay(at: value.location, proxy: proxy, geometry: geometry)
                }
            )
        }
      }
      .chartYAxis {
        AxisMarks(values: .automatic(desiredCount: 4)) { _ in
          AxisGridLine()
            .foregroundStyle(Color.secondary.opacity(0.2))
          AxisValueLabel()
        }
      }
      .chartXAxis {
        AxisMarks { _ in
          AxisValueLabel()
        }
      }
    }
    .padding(20)
    .proudlyGlass()
  }

  private var momentumCard: some View {
    let delta = viewModel.momentumDelta
    let percent = viewModel.momentumPercent
    let isUp = delta >= 0
    let color: Color = isUp ? ProudlyTheme.mint : ProudlyTheme.pink
    let symbol = isUp ? "arrow.up.right" : "arrow.down.right"
    let headline =
      delta == 0
      ? "Steady week — same as last week."
      : (isUp
        ? "You're up \(abs(delta)) check-ins vs last week."
        : "You're down \(abs(delta)) check-ins vs last week.")

    return HStack(spacing: 14) {
      ZStack {
        Circle()
          .fill(color.opacity(0.15))
          .frame(width: 46, height: 46)
        Image(systemName: symbol)
          .font(.system(size: 18, weight: .bold))
          .foregroundStyle(color)
      }
      VStack(alignment: .leading, spacing: 4) {
        Text("Momentum")
          .font(.system(size: 15, weight: .semibold))
        Text(headline)
          .font(.caption)
          .foregroundStyle(.secondary)
      }
      Spacer()
      if delta != 0 {
        Text("\(percent > 0 ? "+" : "")\(percent)%")
          .font(.system(size: 15, weight: .bold))
          .foregroundStyle(color)
      }
    }
    .padding(18)
    .proudlyGlass()
  }

  private var weekdayPatternCard: some View {
    VStack(alignment: .leading, spacing: 12) {
      VStack(alignment: .leading, spacing: 6) {
        Text("Weekday pattern")
          .font(.system(size: 16, weight: .semibold))
        if let selectedWeekday {
          Text(
            "\(fullWeekdayName(from: selectedWeekday.day)): \(selectedWeekday.count) \(completionUnit(for: selectedWeekday.count)) (30d)"
          )
          .font(.caption.weight(.semibold))
          .foregroundStyle(chartColor)
          .contentTransition(.numericText())
        } else {
          Text(weekdayPatternSubtitle)
            .font(.caption)
            .foregroundStyle(.secondary)
        }
      }

      Chart(viewModel.weekdayPattern) { bucket in
        BarMark(
          x: .value("Day", bucket.day),
          y: .value("Check-ins", bucket.count)
        )
        .foregroundStyle(
          selectedWeekdayID == nil || selectedWeekdayID == bucket.id
            ? chartGradient
            : AnyShapeStyle(Color.secondary.opacity(0.28))
        )
        .cornerRadius(6)
        .annotation(position: .top) {
          if selectedWeekdayID == bucket.id {
            Text("\(bucket.count)")
              .font(.caption2.weight(.bold))
              .foregroundStyle(colorScheme == .dark ? .black : .white)
              .padding(.horizontal, 8)
              .padding(.vertical, 4)
              .background(
                colorScheme == .dark ? Color.white.opacity(0.92) : Color.black.opacity(0.88),
                in: Capsule()
              )
          }
        }
      }
      .frame(height: 130)
      .chartOverlay { proxy in
        GeometryReader { geometry in
          Rectangle()
            .fill(.clear)
            .contentShape(Rectangle())
            .gesture(
              DragGesture(minimumDistance: 0)
                .onChanged { value in
                  updateSelectedWeekday(at: value.location, proxy: proxy, geometry: geometry)
                }
                .onEnded { value in
                  updateSelectedWeekday(at: value.location, proxy: proxy, geometry: geometry)
                }
            )
        }
      }
      .chartYAxis {
        AxisMarks(values: .automatic(desiredCount: 3)) { _ in
          AxisGridLine().foregroundStyle(Color.secondary.opacity(0.15))
          AxisValueLabel()
        }
      }
    }
    .padding(20)
    .proudlyGlass()
  }

  private var selectedWeekday: InsightsViewModel.WeekdayBucket? {
    guard let selectedWeekdayID else { return nil }
    return viewModel.weekdayPattern.first(where: { $0.id == selectedWeekdayID })
  }

  private func updateSelectedWeekday(
    at location: CGPoint,
    proxy: ChartProxy,
    geometry: GeometryProxy
  ) {
    guard let plotFrame = proxy.plotFrame else { return }
    let plotArea = geometry[plotFrame]
    guard plotArea.contains(location) else {
      selectedWeekdayID = nil
      return
    }
    let relativeX = location.x - plotArea.origin.x
    guard let day: String = proxy.value(atX: relativeX) else { return }
    selectedWeekdayID = viewModel.weekdayPattern.first(where: { $0.day == day })?.id
  }

  private var consistencyCard: some View {
    let percent = viewModel.consistencyPercent
    return VStack(alignment: .leading, spacing: 14) {
      HStack(spacing: 14) {
        ZStack {
          Circle()
            .fill(chartColor.opacity(0.15))
            .frame(width: 46, height: 46)
          Image(systemName: "target")
            .font(.system(size: 18, weight: .bold))
            .foregroundStyle(chartColor)
        }
        VStack(alignment: .leading, spacing: 4) {
          Text("Consistency (30 days)")
            .font(.system(size: 15, weight: .semibold))
          Text(consistencyCopy(for: percent))
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        Spacer()
        Text("\(percent)%")
          .font(.system(size: 20, weight: .bold))
          .foregroundStyle(chartColor)
          .contentTransition(.numericText())
      }

      GeometryReader { geo in
        ZStack(alignment: .leading) {
          Capsule()
            .fill(Color.secondary.opacity(0.15))
          Capsule()
            .fill(chartGradient)
            .frame(width: geo.size.width * CGFloat(percent) / 100)
        }
      }
      .frame(height: 10)
    }
    .padding(20)
    .proudlyGlass()
  }

  private var heatmapCard: some View {
    VStack(alignment: .leading, spacing: 12) {
      VStack(alignment: .leading, spacing: 4) {
        Text("Last 6 months")
          .font(.system(size: 16, weight: .semibold))
        Text("Every square is a day. Darker means more check-ins.")
          .font(.caption)
          .foregroundStyle(.secondary)
      }

      heatmapGrid

      HStack(spacing: 6) {
        Text("Less")
          .font(.caption2)
          .foregroundStyle(.secondary)
        ForEach([0.0, 0.25, 0.5, 0.75, 1.0], id: \.self) { level in
          RoundedRectangle(cornerRadius: 3)
            .fill(chartColor.opacity(0.1 + level * 0.7))
            .frame(width: 12, height: 12)
        }
        Text("More")
          .font(.caption2)
          .foregroundStyle(.secondary)
        Spacer()
      }
    }
    .padding(20)
    .proudlyGlass()
  }

  private var heatmapGrid: some View {
    let cells = viewModel.heatmapCells
    let weeks = stride(from: 0, to: cells.count, by: 7).map {
      Array(cells[$0..<min($0 + 7, cells.count)])
    }
    return ScrollView(.horizontal, showsIndicators: false) {
      HStack(alignment: .top, spacing: 3) {
        ForEach(Array(weeks.enumerated()), id: \.offset) { _, week in
          VStack(spacing: 3) {
            ForEach(week) { cell in
              RoundedRectangle(cornerRadius: 3)
                .fill(
                  cell.count == 0
                    ? Color.secondary.opacity(0.1)
                    : chartColor.opacity(0.15 + cell.ratio * 0.7)
                )
                .frame(width: 12, height: 12)
            }
          }
        }
      }
      .padding(.vertical, 2)
    }
  }

  private var weekdayPatternSubtitle: String {
    guard let top = viewModel.weekdayPattern.max(by: { $0.count < $1.count }), top.count > 0 else {
      return "Track for a few days to see your pattern."
    }
    return "You show up most on \(fullWeekdayName(from: top.day))."
  }

  private func fullWeekdayName(from abbrev: String) -> String {
    switch abbrev {
    case "Sun": "Sundays"
    case "Mon": "Mondays"
    case "Tue": "Tuesdays"
    case "Wed": "Wednesdays"
    case "Thu": "Thursdays"
    case "Fri": "Fridays"
    case "Sat": "Saturdays"
    default: abbrev
    }
  }

  private func consistencyCopy(for percent: Int) -> String {
    switch percent {
    case 0: "Log any habit to start building consistency."
    case 1..<25: "Every small day counts."
    case 25..<50: "You're building the rhythm."
    case 50..<75: "Strong consistency — keep going."
    case 75..<95: "Great rhythm across the month."
    default: "Incredible consistency."
    }
  }

  private var statsGrid: some View {
    LazyVGrid(
      columns: [GridItem(.flexible()), GridItem(.flexible())],
      spacing: 12
    ) {
      InsightStatCard(
        icon: "checkmark.circle.fill",
        label: "Total Completions",
        value: "\(viewModel.totalCompletions)",
        color: ProudlyTheme.mint
      )
      InsightStatCard(
        icon: "flame.fill",
        label: "Current Streak",
        value: "\(viewModel.currentStreak) \(dayUnit(for: viewModel.currentStreak))",
        color: ProudlyTheme.pink
      )
      InsightStatCard(
        icon: "star.fill",
        label: "Top Habit",
        value: viewModel.topHabit,
        color: ProudlyTheme.blue
      )
      InsightStatCard(
        icon: "trophy.fill",
        label: "Best Day",
        value: "\(viewModel.maxDailyCount) \(completionUnit(for: viewModel.maxDailyCount))",
        color: ProudlyTheme.purple
      )
    }
  }

  private var selectedDay: InsightsViewModel.DayData? {
    guard let selectedDayID else { return nil }
    return viewModel.weeklyData.first(where: { $0.id == selectedDayID })
  }

  private func completionUnit(for count: Int) -> String {
    count == 1 ? "completion" : "completions"
  }

  private func dayUnit(for count: Int) -> String {
    count == 1 ? "day" : "days"
  }

  private func updateSelectedDay(
    at location: CGPoint,
    proxy: ChartProxy,
    geometry: GeometryProxy
  ) {
    guard let plotFrame = proxy.plotFrame else { return }
    let plotArea = geometry[plotFrame]
    guard plotArea.contains(location) else {
      selectedDayID = nil
      return
    }

    let relativeX = location.x - plotArea.origin.x
    guard let day: String = proxy.value(atX: relativeX) else { return }
    selectedDayID = viewModel.weeklyData.first(where: { $0.day == day })?.id
  }
}

struct InsightStatCard: View {
  let icon: String
  let label: String
  let value: String
  let color: Color

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      Image(systemName: icon)
        .font(.title2)
        .foregroundStyle(color)
      Spacer()
      Text(value)
        .font(.system(size: 16, weight: .bold))
        .lineLimit(2)
        .minimumScaleFactor(0.8)
        .contentTransition(.numericText())
      Text(label)
        .font(.caption)
        .foregroundStyle(.secondary)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(16)
    .frame(height: 120)
    .proudlyGlass(cornerRadius: 20)
  }
}

extension View {
  fileprivate func insightsEntrance(_ isVisible: Bool, delay: Double) -> some View {
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

#Preview {
  InsightsView()
    .environment(ThemeViewModel())
    .environment(HabitRepository.preview)
}
