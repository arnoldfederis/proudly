//
//  HabitsView.swift
//  Proudly
//
//  Created by Arnolfo Federis on 6/9/26.
//

import SwiftUI

struct HabitsView: View {
  @Environment(ThemeViewModel.self) private var theme
  @Environment(SubscriptionStore.self) private var subscriptionStore
  @Environment(HabitRepository.self) private var repository
  @State private var viewModel = HabitsViewModel()
  @State private var selectedHabit: Habit?
  @State private var habitPendingArchive: Habit?
  @State private var isArchiveConfirmationPresented = false
  @State private var swipeResetToken = UUID()
  @State private var isAddPresented: Bool = false
  @State private var isPaywallPresented: Bool = false

  private let freeHabitLimit = 3

  private var displayedHabits: [Habit] {
    viewModel.filteredHabits(from: repository.activeHabits)
  }

  var body: some View {
    NavigationStack {
      ZStack {
        theme.activeTheme.backgroundGradient.ignoresSafeArea()

        GeometryReader { proxy in
          ScrollView {
            VStack(spacing: 16) {
              if !subscriptionStore.hasProudlyPlus {
                freePlanBanner.padding(.top, 8)
              }

              if displayedHabits.isEmpty {
                emptyState
                  .frame(maxWidth: .infinity, maxHeight: .infinity)
                  .frame(minHeight: proxy.size.height - 70)
              } else {
                LazyVStack(spacing: 10) {
                  ForEach(displayedHabits) { habit in
                    Button {
                      selectedHabit = habit
                    } label: {
                      HabitCardView(habit: habit)
                    }
                    .id(rowID(for: habit))
                    .buttonStyle(.plain)
                    .animation(
                      .spring(response: 0.32, dampingFraction: 0.82), value: swipeResetToken
                    )
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                      Button(role: .destructive) {
                        habitPendingArchive = habit
                        isArchiveConfirmationPresented = true
                      } label: {
                        Label("Archive", systemImage: "archivebox.fill")
                      }
                    }
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
          filterToolbar
        }
        if #available(iOS 26.0, *) {
          ToolbarSpacer(.fixed, placement: .topBarTrailing)
        }
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
      .onChange(of: isArchiveConfirmationPresented) { _, isPresented in
        if !isPresented, habitPendingArchive != nil {
          resetArchiveSwipeState()
        }
      }
      .alert(
        "Archive habit?",
        isPresented: $isArchiveConfirmationPresented,
      ) {
        Button("Archive", role: .destructive) {
          guard let habitPendingArchive else { return }
          archiveHabit(habitPendingArchive)
        }
        Button("Cancel", role: .cancel) {
          resetArchiveSwipeState()
        }
      } message: {
        Text(
          "\(habitPendingArchive?.name ?? "This habit") will be removed from your active habits.")
      }
    }
  }

  private var freePlanBanner: some View {
    HStack(spacing: 14) {
      ZStack {
        Circle()
          .fill(theme.activeTheme.accentColor.opacity(0.15))
          .frame(width: 40, height: 40)
        Image(systemName: "star.fill")
          .font(.system(size: 16))
          .foregroundStyle(theme.activeTheme.accentColor)
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
          .background(theme.activeTheme.accentGradient)
          .clipShape(Capsule())
      }
      .buttonStyle(.plain)
    }
    .padding(16)
    .proudlyGlass(cornerRadius: 18)
  }

  private var filterToolbar: some View {
    Menu {
      ForEach(HabitsViewModel.HabitFilter.allCases, id: \.self) { filter in
        Button {
          withAnimation(.spring(response: 0.3)) {
            viewModel.filter = filter
            Haptics.selection()
          }
        } label: {
          if viewModel.filter == filter {
            Label(filter.rawValue, systemImage: "checkmark")
          } else {
            Text(filter.rawValue)
          }
        }
      }
    } label: {
      Image(systemName: "line.3.horizontal.decrease.circle")
        .font(.system(size: 17, weight: .semibold))
        .foregroundStyle(theme.activeTheme.accentColor)
    }
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

    if !subscriptionStore.hasProudlyPlus && repository.activeHabits.count >= freeHabitLimit {
      isPaywallPresented = true
    } else {
      isAddPresented = true
    }
  }

  private func archiveHabit(_ habit: Habit) {
    Haptics.impact(.medium)
    repository.archiveHabit(habit)
    resetArchiveSwipeState()
  }

  private func resetArchiveSwipeState() {
    habitPendingArchive = nil
    withAnimation(.spring(response: 0.34, dampingFraction: 0.82)) {
      swipeResetToken = UUID()
    }
  }

  private func rowID(for habit: Habit) -> String {
    "\(habit.id.uuidString)-\(swipeResetToken.uuidString)"
  }
}

struct HabitIconView: View {
  let icon: String
  let color: Color
  let fontSize: CGFloat
  let circleSize: CGFloat
  var backgroundOpacity: Double = 0.15

  private var isSFSymbol: Bool { icon.isHabitSFSymbol }

  var body: some View {
    ZStack {
      Circle()
        .fill(color.opacity(backgroundOpacity))
        .frame(width: circleSize, height: circleSize)
      if isSFSymbol {
        Image(systemName: icon)
          .font(.system(size: fontSize))
          .foregroundStyle(color)
      } else {
        Text(icon)
          .font(.system(size: fontSize))
      }
    }
  }
}

struct HabitCardView: View {
  let habit: Habit

  var body: some View {
    HStack(spacing: 14) {
      HabitIconView(
        icon: habit.icon, color: habit.color, fontSize: 22, circleSize: 52, backgroundOpacity: 0.18)

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
        Text(habit.dailyTargetCount == 1 ? habit.streak.proudlyDayUnit : habit.todayProgressLabel)
          .font(.caption2)
          .foregroundStyle(.secondary)
          .contentTransition(.numericText())
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(16)
    .contentShape(Rectangle())
    .proudlyGlass(cornerRadius: 20)
  }
}

#Preview {
  HabitsView()
    .environment(ThemeViewModel())
    .environment(SubscriptionStore())
    .environment(HabitRepository.preview)
}
