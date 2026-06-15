//
//  ProudlyApp.swift
//  Proudly
//
//  Created by Arnolfo Federis on 6/9/26.
//

import SwiftData
import SwiftUI

@main
struct ProudlyApp: App {
  @State private var themeViewModel = ThemeViewModel()
  @State private var subscriptionStore = SubscriptionStore()
  @State private var habitRepository: HabitRepository

  let sharedModelContainer: ModelContainer

  init() {
    let schema = Schema([PersistentHabit.self, PersistentHabitCompletion.self])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
    let container: ModelContainer
    do {
      container = try ModelContainer(for: schema, configurations: [config])
    } catch {
      fatalError("Could not create ModelContainer: \(error)")
    }
    sharedModelContainer = container
    _habitRepository = State(initialValue: HabitRepository(modelContext: container.mainContext))
  }

  var body: some Scene {
    WindowGroup {
      RootView()
        .environment(themeViewModel)
        .environment(subscriptionStore)
        .environment(habitRepository)
    }
    .modelContainer(sharedModelContainer)
  }
}

private struct RootView: View {
  @Environment(ThemeViewModel.self) private var theme
  @Environment(SubscriptionStore.self) private var subscriptionStore

  var body: some View {
    HomeView()
      .tint(theme.activeTheme.accentColor)
      .preferredColorScheme(theme.activeTheme == .midnightCalm ? .dark : nil)
      .task {
        subscriptionStore.configureIfNeeded()
      }
      .onChange(of: subscriptionStore.hasProudlyPlus) { _, hasProudlyPlus in
        theme.isPlusUser = hasProudlyPlus
        UserDefaults.standard.set(hasProudlyPlus, forKey: ThemeViewModel.plusCacheKey)
      }
  }
}
