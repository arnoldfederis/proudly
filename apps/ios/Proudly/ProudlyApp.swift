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
  var sharedModelContainer: ModelContainer = {
    let schema = Schema([
      Item.self
    ])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

    do {
      return try ModelContainer(for: schema, configurations: [modelConfiguration])
    } catch {
      fatalError("Could not create ModelContainer: \(error)")
    }
  }()

  var body: some Scene {
    WindowGroup {
      RootView()
        .environment(themeViewModel)
    }
    .modelContainer(sharedModelContainer)
  }
}

private struct RootView: View {
  @Environment(ThemeViewModel.self) private var theme

  var body: some View {
    HomeView()
      .tint(theme.activeTheme.accentColor)
      .preferredColorScheme(theme.activeTheme == .midnightCalm ? .dark : nil)
  }
}
