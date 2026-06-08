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
  case addHabit
}

struct HomeView: View {
  @State private var selectedTab: HomeTab = .today
  @State private var previousTab: HomeTab = .today
  @State private var isAddPresented = false
  @State private var isLimitReached: Bool = true

  var body: some View {
    TabView(selection: $selectedTab) {
      Tab("Today", systemImage: "bolt.house", value: .today) {
        TodayView()
      }
      Tab("Habits", systemImage: "checkmark.rectangle.stack", value: .habits) {
        HabitsView()
      }
      Tab("Insights", systemImage: "chart.bar", value: .insights) {
        InsightsView()
      }
      Tab("Profile", systemImage: "person.crop.circle", value: .profile) {
        ProfileView()
      }
      Tab("", systemImage: "plus", value: .addHabit, role: .search) { Color.clear }
    }
    .onChange(of: selectedTab) { oldValue, newValue in
      Haptics.selection()
      if newValue == .addHabit {
        isAddPresented = true
        selectedTab = oldValue
      } else {
        previousTab = newValue
      }
    }
    .sheet(isPresented: $isAddPresented) {
      NewHabitView(isPresented: $isAddPresented)
    }
  }
}

#Preview {
  HomeView()
}
