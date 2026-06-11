//
//  TodayView.swift
//  Proudly
//
//  Created by Arnolfo Federis on 6/9/26.
//

import SwiftUI

struct TodayView: View {
  @State private var viewModel = TodayViewModel()
  @State private var selectedHabit: Habit?
  @State private var isAddPresented: Bool = false
  @State private var isPaywallPresented: Bool = false

  private let isPlusUser = false
  private let freeHabitLimit = 3

  var body: some View {
    NavigationStack {
      ZStack {
        ProudlyTheme.backgroundGradient.ignoresSafeArea()

        ScrollView {
          VStack(spacing: 20) {
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
          .tint(ProudlyTheme.purple)
        }
      }
      .navigationDestination(item: $selectedHabit) { habit in
        HabitDetailView(habit: habit) { updatedHabit in
          viewModel.updateHabit(updatedHabit)
        }
      }
      .sheet(isPresented: $isAddPresented) {
        HabitFormView { habit in
          viewModel.addHabit(habit)
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
      VStack(alignment: .leading, spacing: 6) {
        Text("You're doing great!")
          .font(.headline)
        Text("\(viewModel.completedCount) of \(viewModel.totalCount) habits completed")
          .font(.subheadline)
          .foregroundStyle(.secondary)

        ProgressView(value: viewModel.progressRatio)
          .progressViewStyle(.linear)
          .tint(ProudlyTheme.purple)
          .frame(maxWidth: .infinity)
      }

      ZStack {
        Circle()
          .stroke(Color.gray.opacity(0.2), lineWidth: 4)
          .frame(width: 56, height: 56)
        Circle()
          .trim(from: 0, to: viewModel.progressRatio)
          .stroke(
            ProudlyTheme.purplePinkGradient,
            style: StrokeStyle(lineWidth: 4, lineCap: .round)
          )
          .frame(width: 56, height: 56)
          .rotationEffect(.degrees(-90))
          .animation(.easeInOut(duration: 0.4), value: viewModel.progressRatio)
        Text("\(Int(viewModel.progressRatio * 100))%")
          .font(.system(size: 12, weight: .bold))
      }
    }
    .padding(20)
    .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 22))
  }

  private var habitsSection: some View {
    VStack(spacing: 10) {
      ForEach(viewModel.habits) { habit in
        HabitRowView(
          habit: habit,
          onToggle: { viewModel.toggleCompletion(for: habit) },
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
    .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 18))
  }

  private func presentAddHabit() {
    Haptics.selection()

    if !isPlusUser && viewModel.habits.count >= freeHabitLimit {
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
        ZStack {
          Circle()
            .fill(habit.color.opacity(0.18))
            .frame(width: 46, height: 46)
          Image(systemName: habit.icon)
            .font(.system(size: 19))
            .foregroundStyle(habit.color)
        }

        VStack(alignment: .leading, spacing: 3) {
          Text(habit.name)
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(.primary)
          HStack(spacing: 4) {
            Image(systemName: "flame.fill")
              .font(.caption2)
              .foregroundStyle(ProudlyTheme.pink)
            Text("\(habit.streak) day streak")
              .font(.caption)
              .foregroundStyle(.secondary)
          }
        }

        Spacer()

        Button(action: onToggle) {
          ZStack {
            Circle()
              .strokeBorder(
                habit.isCompletedToday ? habit.color : Color.gray.opacity(0.35),
                lineWidth: 2.5
              )
              .frame(width: 34, height: 34)

            if habit.isCompletedToday {
              Circle()
                .fill(habit.color)
                .frame(width: 34, height: 34)
              Image(systemName: "checkmark")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.white)
            }
          }
          .animation(.spring(response: 0.3, dampingFraction: 0.6), value: habit.isCompletedToday)
        }
        .buttonStyle(.plain)
      }
    }
    .buttonStyle(.plain)
    .padding(.horizontal, 16)
    .padding(.vertical, 13)
    .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 18))
  }
}

#Preview {
  TodayView()
}
