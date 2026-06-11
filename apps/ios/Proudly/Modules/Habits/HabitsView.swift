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

  var body: some View {
    NavigationStack {
      ZStack {
        ProudlyTheme.backgroundGradient.ignoresSafeArea()

        GeometryReader { proxy in
          ScrollView {
            VStack(spacing: 16) {
              filterPicker.padding(.top, 8)

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
      .navigationDestination(item: $selectedHabit) { habit in
        HabitDetailView(habit: habit) { updatedHabit in
          viewModel.updateHabit(updatedHabit)
        }
      }
      .overlay(alignment: .bottomTrailing) {
        FloatingActionButton(systemImage: "plus", color: ProudlyTheme.purple) {
          isAddPresented = true
        }
        .padding(.bottom, 5)
        .padding(.trailing, 20)
      }
      .sheet(isPresented: $isAddPresented) {
        HabitFormView { habit in
          viewModel.addHabit(habit)
          isAddPresented = false
        }
      }
    }
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
