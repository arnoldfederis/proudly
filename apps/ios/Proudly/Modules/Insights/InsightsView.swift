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

  var body: some View {
    NavigationStack {
      ZStack {
        theme.activeTheme.backgroundGradient.ignoresSafeArea()

        ScrollView {
          LazyVStack(spacing: 20) {
            celebrationCard
            weeklyChartCard
            statsGrid
            Spacer(minLength: 80)
          }
          .padding(.horizontal, 20)
          .padding(.top, 8)
        }
      }
      .navigationTitle("Insights")
      .navigationBarTitleDisplayMode(.large)
    }
    .onAppear { viewModel.update(habits: repository.activeHabits) }
    .onChange(of: repository.activeHabits) { _, habits in
      viewModel.update(habits: habits)
    }
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
            .foregroundStyle(theme.activeTheme.accentColor)
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
            ? AnyShapeStyle(theme.activeTheme.accentGradient)
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

#Preview {
  InsightsView()
    .environment(ThemeViewModel())
    .environment(HabitRepository.preview)
}
