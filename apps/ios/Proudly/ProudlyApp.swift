//
//  ProudlyApp.swift
//  Proudly
//
//  Created by Arnolfo Federis on 6/9/26.
//

import SwiftData
import SwiftUI
import UIKit
import UserNotifications

@MainActor
@Observable
final class ToastCenter {
  struct Toast: Identifiable, Equatable {
    let id = UUID()
    let message: String
    let symbol: String
  }

  var toasts: [Toast] = []

  private var dismissalTasks: [UUID: Task<Void, Never>] = [:]
  private let toastDuration: Duration = .seconds(2)

  func show(message: String, symbol: String = "checkmark.circle.fill") {
    if let existingToast = toasts.last(where: { $0.message == message && $0.symbol == symbol }) {
      scheduleDismissal(for: existingToast)
      return
    }

    let toast = Toast(message: message, symbol: symbol)

    withAnimation(.spring(response: 0.34, dampingFraction: 0.82)) {
      toasts.append(toast)
    }

    scheduleDismissal(for: toast)
  }

  func dismiss(id: UUID) {
    dismissalTasks[id]?.cancel()
    dismissalTasks[id] = nil

    withAnimation(.spring(response: 0.3, dampingFraction: 0.86)) {
      toasts.removeAll { $0.id == id }
    }
  }

  private func scheduleDismissal(for toast: Toast) {
    dismissalTasks[toast.id]?.cancel()
    let toastDuration = self.toastDuration
    dismissalTasks[toast.id] = Task { [weak self] in
      try? await Task.sleep(for: toastDuration)
      self?.dismiss(id: toast.id)
    }
  }
}

@MainActor
@Observable
final class AppNavigationStore {
  static let shared = AppNavigationStore()

  var pendingHabitID: UUID?

  func openHabit(id: UUID) {
    pendingHabitID = id
  }

  func consumePendingHabitID() {
    pendingHabitID = nil
  }
}

final class NotificationAppDelegate: NSObject, UIApplicationDelegate,
  UNUserNotificationCenterDelegate
{
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    UNUserNotificationCenter.current().delegate = self
    return true
  }

  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse
  ) async {
    guard let habitID = Self.habitID(from: response.notification) else { return }
    await MainActor.run {
      AppNavigationStore.shared.openHabit(id: habitID)
    }
  }

  private static func habitID(from notification: UNNotification) -> UUID? {
    if let habitIDString = notification.request.content.userInfo["habitID"] as? String,
      let habitID = UUID(uuidString: habitIDString)
    {
      return habitID
    }

    let identifierParts = notification.request.identifier.split(separator: "-")
    guard identifierParts.count >= 6 else { return nil }
    let uuidString = identifierParts.dropLast().joined(separator: "-")
      .replacingOccurrences(of: "proudly.habit.", with: "")
    return UUID(uuidString: uuidString)
  }
}

@main
struct ProudlyApp: App {
  @UIApplicationDelegateAdaptor(NotificationAppDelegate.self) private var notificationAppDelegate
  @State private var themeViewModel = ThemeViewModel()
  @State private var toastCenter: ToastCenter
  @State private var subscriptionStore: SubscriptionStore
  @State private var habitRepository: HabitRepository
  @State private var appNavigationStore = AppNavigationStore.shared
  @State private var focusTimerStore = FocusTimerStore.shared
  @Environment(\.scenePhase) private var scenePhase

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
    let toastCenter = ToastCenter()
    sharedModelContainer = container
    _toastCenter = State(initialValue: toastCenter)
    _subscriptionStore = State(initialValue: SubscriptionStore(toastCenter: toastCenter))
    _habitRepository = State(
      initialValue: HabitRepository(modelContext: container.mainContext, toastCenter: toastCenter))
  }

  var body: some Scene {
    WindowGroup {
      RootView()
        .environment(themeViewModel)
        .environment(toastCenter)
        .environment(subscriptionStore)
        .environment(habitRepository)
        .environment(appNavigationStore)
        .environment(focusTimerStore)
    }
    .modelContainer(sharedModelContainer)
    .onChange(of: scenePhase) { _, phase in
      if phase == .active {
        focusTimerStore.refresh()
      }
    }
  }
}

private struct RootView: View {
  @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
  @AppStorage("hasStartedOnboardingFlow") private var hasStartedOnboardingFlow = false
  @Environment(ThemeViewModel.self) private var theme
  @Environment(ToastCenter.self) private var toastCenter
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
    .overlay(alignment: .top) {
      VStack(spacing: 10) {
        ForEach(Array(toastCenter.toasts.suffix(3).enumerated()), id: \.element.id) {
          index, toast in
          ToastBannerView(toast: toast)
            .padding(.horizontal, 20)
            .scaleEffect(index == 0 ? 1 : 0.98)
            .opacity(index == 0 ? 1 : 0.92)
            .transition(.move(edge: .top).combined(with: .opacity))
        }
      }
      .padding(.top, 8)
    }
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

struct ToastBannerView: View {
  let toast: ToastCenter.Toast

  var body: some View {
    HStack(spacing: 10) {
      Image(systemName: toast.symbol)
        .font(.system(size: 14, weight: .semibold))
        .foregroundStyle(.white)

      Text(toast.message)
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(.white)
        .lineLimit(2)

      Spacer(minLength: 0)
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 14)
    .background(.black.opacity(0.84), in: RoundedRectangle(cornerRadius: 18))
    .shadow(color: .black.opacity(0.18), radius: 18, y: 10)
  }
}
