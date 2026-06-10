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
  @State private var selectedTab: HomeTab = .today
  @State private var previousTab: HomeTab = .today
  @State private var isAddPresented = false

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
    }
    .tint(ProudlyTheme.purple)
    .overlay(alignment: .bottomTrailing) {
      if selectedTab == .today || selectedTab == .habits {
        Button {
          isAddPresented = true
        } label: {
          Image(systemName: "plus")
            .font(.title2.bold())
            .foregroundColor(.white)
            .frame(width: 52, height: 52)
            .background(ProudlyTheme.purple)
            .clipShape(Circle())
            .shadow(radius: 6)
        }
        .padding(.bottom, 60)
        .padding(.trailing, 20)
      }
    }
    .onChange(of: selectedTab) { oldValue, newValue in
      Haptics.selection()

      if newValue == .today || newValue == .habits {
        previousTab = newValue
      }
    }
    .sheet(isPresented: $isAddPresented) {
      NewHabitView(onSave: {
        selectedTab = previousTab
        isAddPresented = false
      })
    }
  }
}

#Preview {
  HomeView()
}
