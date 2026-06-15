//
//  InsightsView.swift
//  Proudly
//
//  Created by Arnolfo Federis on 6/9/26.
//

import Charts
import SwiftUI

struct InsightsView: View {
  @Environment(ThemeViewModel.self) private var theme
  @State private var viewModel = InsightsViewModel()

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
  }

  private var celebrationCard: some View {
    HStack(spacing: 14) {
      Text("🎉")
        .font(.system(size: 36))
      VStack(alignment: .leading, spacing: 4) {
        Text("Great job this week!")
          .font(.headline)
        Text("You completed \(viewModel.totalCompletions) habits in 7 days.")
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
      Text("Your progress this week")
        .font(.system(size: 16, weight: .semibold))

      Chart(viewModel.weeklyData) { item in
        BarMark(
          x: .value("Day", item.day),
          y: .value("Habits", item.count)
        )
        .foregroundStyle(theme.activeTheme.accentGradient)
        .cornerRadius(8)
      }
      .frame(height: 160)
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
        value: "\(viewModel.currentStreak) days",
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
        value: "\(viewModel.maxDailyCount) habits",
        color: ProudlyTheme.purple
      )
    }
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
}
