//
//  HomeView.swift
//  Proudly
//
//  Created by Arnolfo Federis on 6/9/26.
//

import Foundation
import SwiftUI

private enum HomeTab: Hashable {
  case today
  case habits
  case insights
  case profile
}

struct HomeView: View {
  @Environment(ThemeViewModel.self) private var theme
  @Environment(SubscriptionStore.self) private var subscriptionStore
  @Environment(AppNavigationStore.self) private var appNavigationStore
  @State private var selectedTab: HomeTab = .today

  var body: some View {
    TabView(selection: $selectedTab) {
      Tab("Today", systemImage: "bolt.house", value: .today) {
        TodayView()
      }
      Tab("Habits", systemImage: "checkmark.rectangle.stack", value: .habits) {
        HabitsView()
      }
      if subscriptionStore.hasProudlyPlus {
        Tab("Insights", systemImage: "chart.bar", value: .insights) {
          InsightsView()
        }
      }
      Tab("Profile", systemImage: "person.crop.circle", value: .profile) {
        ProfileView()
      }
    }
    .tint(theme.activeTheme.accentColor)
    .onChange(of: selectedTab) { oldValue, newValue in
      Haptics.selection()
    }
    .onChange(of: appNavigationStore.pendingHabitID, initial: true) { _, pendingHabitID in
      guard pendingHabitID != nil else { return }
      selectedTab = .today
    }
  }
}

#Preview {
  HomeView()
    .environment(ThemeViewModel())
    .environment(SubscriptionStore())
    .environment(HabitRepository.preview)
}
