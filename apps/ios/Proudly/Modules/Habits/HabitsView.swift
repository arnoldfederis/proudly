//
//  HabitsView.swift
//  Proudly
//
//  Created by Arnolfo Federis on 6/9/26.
//

import SwiftUI

struct HabitsView: View {
  @State private var viewModel = HabitsViewModel()
  @State private var selectedHabit: Habit?
  @State private var isAddPresented: Bool = false
  @State private var isPaywallPresented: Bool = false

  private let isPlusUser = false
  private let freeHabitLimit = 3

  var body: some View {
    NavigationStack {
      ZStack {
        ProudlyTheme.backgroundGradient.ignoresSafeArea()

        GeometryReader { proxy in
          ScrollView {
            VStack(spacing: 16) {
              freePlanBanner.padding(.top, 8)
              filterPicker

              if viewModel.filteredHabits.isEmpty {
                emptyState
                  .frame(maxWidth: .infinity, maxHeight: .infinity)
                  .frame(minHeight: proxy.size.height - 70)
              } else {
                LazyVStack(spacing: 10) {
                  ForEach(viewModel.filteredHabits) { habit in
                    Button {
                      selectedHabit = habit
                    } label: {
                      HabitCardView(habit: habit)
                    }
                    .buttonStyle(.plain)
                  }
                }
              }
            }
            .padding(.horizontal, 20)
          }
        }
      }
      .navigationTitle("Habits")
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

  private var freePlanBanner: some View {
    HStack(spacing: 14) {
      ZStack {
        Circle()
          .fill(ProudlyTheme.purple.opacity(0.15))
          .frame(width: 40, height: 40)
        Image(systemName: "star.fill")
          .font(.system(size: 16))
          .foregroundStyle(ProudlyTheme.purple)
      }
      VStack(alignment: .leading, spacing: 3) {
        Text("Free plan: 3 habits")
          .font(.system(size: 14, weight: .semibold))
        Text("Upgrade to Proudly Plus for unlimited habits.")
          .font(.caption)
          .foregroundStyle(.secondary)
      }
      Spacer()
      Button {
        isPaywallPresented = true
      } label: {
        Text("Upgrade")
          .font(.system(size: 12, weight: .bold))
          .foregroundStyle(.white)
          .padding(.horizontal, 12)
          .padding(.vertical, 6)
          .background(ProudlyTheme.purplePinkGradient)
          .clipShape(Capsule())
      }
      .buttonStyle(.plain)
    }
    .padding(16)
    .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 18))
  }

  private var filterPicker: some View {
    HStack(spacing: 0) {
      ForEach(HabitsViewModel.HabitFilter.allCases, id: \.self) { filter in
        Button {
          withAnimation(.spring(response: 0.3)) {
            viewModel.filter = filter
            Haptics.selection()
          }
        } label: {
          Text(filter.rawValue)
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(viewModel.filter == filter ? .white : .secondary)
            .padding(.vertical, 9)
            .frame(maxWidth: .infinity)
            .background {
              if viewModel.filter == filter {
                Capsule().fill(ProudlyTheme.purple)
              }
            }
        }
        .buttonStyle(.plain)
      }
    }
    .padding(4)
    .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 16))
  }

  private var emptyState: some View {
    VStack(spacing: 12) {
      Image(systemName: "checkmark.circle.fill")
        .font(.system(size: 40))
        .foregroundStyle(ProudlyTheme.mint)
      Text("All done here!")
        .font(.headline)
      Text("No habits in this category.")
        .font(.subheadline)
        .foregroundStyle(.secondary)
    }
    .padding(40)
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

struct HabitCardView: View {
  let habit: Habit

  var body: some View {
    HStack(spacing: 14) {
      ZStack {
        Circle()
          .fill(habit.color.opacity(0.18))
          .frame(width: 52, height: 52)
        Image(systemName: habit.icon)
          .font(.system(size: 22))
          .foregroundStyle(habit.color)
      }

      VStack(alignment: .leading, spacing: 4) {
        Text(habit.name)
          .font(.system(size: 16, weight: .semibold))
          .foregroundStyle(.primary)
        Text(habit.note)
          .font(.caption)
          .foregroundStyle(.secondary)
          .lineLimit(1)
      }

      Spacer()

      VStack(alignment: .trailing, spacing: 2) {
        HStack(spacing: 3) {
          Image(systemName: "flame.fill")
            .font(.caption)
            .foregroundStyle(ProudlyTheme.pink)
          Text("\(habit.streak)")
            .font(.system(size: 16, weight: .bold))
        }
        Text("days")
          .font(.caption2)
          .foregroundStyle(.secondary)
      }
    }
    .padding(16)
    .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 20))
  }
}

#Preview {
  HabitsView()
}
