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
  @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
  @AppStorage("hasStartedOnboardingFlow") private var hasStartedOnboardingFlow = false
  @Environment(ThemeViewModel.self) private var theme
  @Environment(SubscriptionStore.self) private var subscriptionStore
  @Environment(HabitRepository.self) private var habitRepository

  var body: some View {
    Group {
      if hasCompletedOnboarding {
        HomeView()
      } else if hasStartedOnboardingFlow {
        OnboardingFlowView()
      } else {
        OnboardingView {
          Haptics.selection()
          hasStartedOnboardingFlow = true
        }
      }
    }
    .tint(theme.activeTheme.accentColor)
    .preferredColorScheme(theme.activeTheme == .midnightCalm ? .dark : nil)
    .task {
      subscriptionStore.configureIfNeeded()
      hydrateExistingUsersIfNeeded()
      if hasCompletedOnboarding {
        habitRepository.seedIfNeeded()
      }
    }
    .onChange(of: subscriptionStore.hasProudlyPlus, initial: true) { _, hasProudlyPlus in
      theme.isPlusUser = hasProudlyPlus
      UserDefaults.standard.set(hasProudlyPlus, forKey: ThemeViewModel.plusCacheKey)
    }
    .onChange(of: hasCompletedOnboarding, initial: true) { _, completed in
      if completed {
        hasStartedOnboardingFlow = false
        habitRepository.seedIfNeeded()
      }
    }
  }

  private func hydrateExistingUsersIfNeeded() {
    guard UserDefaults.standard.object(forKey: "hasCompletedOnboarding") == nil else { return }

    if !habitRepository.activeHabits.isEmpty
      || UserDefaults.standard.bool(forKey: "hasSeededDefaultHabits")
    {
      hasCompletedOnboarding = true
      hasStartedOnboardingFlow = false
    }
  }
}
