//
//  ProfileView.swift
//  Proudly
//
//  Created by Arnolfo Federis on 6/9/26.
//

import SwiftUI

struct ProfileView: View {
  @Environment(ThemeViewModel.self) private var theme
  @Environment(SubscriptionStore.self) private var subscriptionStore
  @Environment(HabitRepository.self) private var repository
  @Environment(ToastCenter.self) private var toastCenter
  @Environment(\.openURL) private var openURL
  @State private var showPaywall = false
  @State private var showICloudAlert = false
  @State private var showThemeView = false
  @State private var showSubscriptionManagement = false
  @State private var navigateToProudMoments = false
  @State private var navigateToReminders = false
  @State private var navigateToSiri = false

  private let termsURL = URL(string: "https://proudlyhabit.com/terms")
  private let privacyURL = URL(string: "https://proudlyhabit.com/privacy")

  var body: some View {
    NavigationStack {
      ZStack {
        theme.activeTheme.backgroundGradient.ignoresSafeArea()

        ScrollView {
          LazyVStack(spacing: 20) {
            profileCard
            settingsSection
            legalSection
            Spacer(minLength: 80)
          }
          .padding(.horizontal, 20)
          .padding(.top, 8)
        }
      }
      .navigationTitle("Profile")
      .navigationBarTitleDisplayMode(.large)
      .sheet(isPresented: $showPaywall) {
        ProudlyPlusView()
      }
      .navigationDestination(isPresented: $showThemeView) {
        ThemeView(onLockedThemeTapped: {
          showThemeView = false
          showPaywall = true
        })
      }
      .navigationDestination(isPresented: $showSubscriptionManagement) {
        SubscriptionManagementView()
      }
      .navigationDestination(isPresented: $navigateToProudMoments) {
        ProudMomentsView()
      }
      .navigationDestination(isPresented: $navigateToReminders) {
        RemindersView()
      }
      .navigationDestination(isPresented: $navigateToSiri) {
        SiriShortcutsView()
      }
    }
  }

  private var profileCard: some View {
    VStack(spacing: 14) {
      HStack(spacing: 16) {
        ZStack {
          Circle()
            .fill(theme.activeTheme.accentGradient)
            .frame(width: 60, height: 60)
          Text("A")
            .font(.system(size: 26, weight: .bold))
            .foregroundStyle(.white)
        }

        VStack(alignment: .leading, spacing: 4) {
          Text("Arnolfo")
            .font(.system(size: 18, weight: .bold))
          Text(profileSummary)
            .font(.caption)
            .foregroundStyle(.secondary)
        }

        Spacer()
      }

      Divider().opacity(0.4)

      HStack {
        VStack(alignment: .leading, spacing: 2) {
          Text(subscriptionStore.hasProudlyPlus ? "Proudly Plus" : "Proudly Free")
            .font(.system(size: 14, weight: .semibold))
          Text(
            subscriptionStore.hasProudlyPlus
              ? "All premium features unlocked"
              : "3 habits included"
          )
          .font(.caption)
          .foregroundStyle(.secondary)
        }

        Spacer()

        if subscriptionStore.hasProudlyPlus {
          Text("Active")
            .font(.system(size: 13, weight: .bold))
            .foregroundStyle(theme.activeTheme.accentColor)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(theme.activeTheme.accentColor.opacity(0.12))
            .clipShape(Capsule())
        } else {
          Button {
            showPaywall = true
          } label: {
            Text("Upgrade")
              .font(.system(size: 13, weight: .bold))
              .foregroundStyle(.white)
              .padding(.horizontal, 16)
              .padding(.vertical, 8)
              .background(theme.activeTheme.accentGradient)
              .clipShape(Capsule())
          }
          .buttonStyle(.plain)
        }
      }
    }
    .padding(20)
    .proudlyGlass()
  }

  private var settingsSection: some View {
    VStack(spacing: 0) {
      Button {
        showICloudAlert = true
      } label: {
        ProfileRow(icon: "icloud.fill", label: "iCloud Sync", color: ProudlyTheme.blue) {
          Text("Coming soon")
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
      }
      .buttonStyle(.plain)
      .alert("Coming soon", isPresented: $showICloudAlert) {
        Button("OK") {}
      } message: {
        Text("iCloud sync is planned for a future update.")
      }

      Divider().padding(.leading, 56).opacity(0.4)

      Button {
        navigateToReminders = true
      } label: {
        ProfileRow(icon: "bell.fill", label: "Reminders", color: ProudlyTheme.pink) {
          HStack(spacing: 6) {
            Text(reminderSummary)
              .font(.subheadline)
              .foregroundStyle(.secondary)
            Image(systemName: "chevron.right")
              .font(.caption2)
              .foregroundStyle(.tertiary)
          }
        }
      }
      .buttonStyle(.plain)

      Divider().padding(.leading, 56).opacity(0.4)

      Button {
        navigateToSiri = true
      } label: {
        ProfileRow(icon: "mic.fill", label: "Siri Shortcuts", color: ProudlyTheme.purple) {
          Image(systemName: "chevron.right")
            .font(.caption2)
            .foregroundStyle(.tertiary)
        }
      }
      .buttonStyle(.plain)

      Divider().padding(.leading, 56).opacity(0.4)

      Button {
        if subscriptionStore.hasProudlyPlus {
          showThemeView = true
        } else {
          showPaywall = true
        }
      } label: {
        ProfileRow(icon: "paintbrush.fill", label: "Theme", color: ProudlyTheme.purple) {
          HStack(spacing: 6) {
            if subscriptionStore.hasProudlyPlus {
              Text(theme.selectedTheme.displayName)
                .font(.subheadline)
                .foregroundStyle(.secondary)
              Image(systemName: "chevron.right")
                .font(.caption2)
                .foregroundStyle(.tertiary)
            } else {
              PlusBadge()
            }
          }
        }
      }
      .buttonStyle(.plain)

      Divider().padding(.leading, 56).opacity(0.4)

      Button {
        showSubscriptionManagement = true
      } label: {
        ProfileRow(
          icon: "creditcard.fill",
          label: "Subscription",
          color: theme.activeTheme.accentColor
        ) {
          HStack(spacing: 6) {
            Text(subscriptionStore.hasProudlyPlus ? "Plus" : "Free")
              .font(.subheadline)
              .foregroundStyle(.secondary)
            Image(systemName: "chevron.right")
              .font(.caption2)
              .foregroundStyle(.tertiary)
          }
        }
      }
      .buttonStyle(.plain)

      Divider().padding(.leading, 56).opacity(0.4)

      Button {
        if subscriptionStore.hasProudlyPlus {
          navigateToProudMoments = true
        } else {
          showPaywall = true
        }
      } label: {
        ProfileRow(icon: "heart.fill", label: "Proud Moments", color: ProudlyTheme.mint) {
          if subscriptionStore.hasProudlyPlus {
            Image(systemName: "chevron.right")
              .font(.caption2)
              .foregroundStyle(.tertiary)
          } else {
            PlusBadge()
          }
        }
      }
      .buttonStyle(.plain)
    }
    .proudlyGlass()
  }

  private var legalSection: some View {
    VStack(spacing: 0) {
      Button {
        Task {
          let result = await subscriptionStore.restorePurchases()
          switch result {
          case .restoredPlus:
            toastCenter.show(
              message: "Subscription restored", symbol: "arrow.clockwise.circle.fill")
          case .noActiveSubscription:
            toastCenter.show(
              message: "No active subscription found", symbol: "info.circle.fill")
          case .failed:
            break
          }
        }
      } label: {
        ProfileRow(icon: "arrow.clockwise", label: "Restore Purchases", color: .secondary) {
          if subscriptionStore.isRestoreInProgress {
            ProgressView()
              .scaleEffect(0.8)
          }
        }
      }
      .buttonStyle(.plain)
      .disabled(subscriptionStore.isRestoreInProgress)

      Divider().padding(.leading, 56).opacity(0.4)

      Button {
        if let url = termsURL {
          if #available(iOS 26.0, *) {
            openURL(url, prefersInApp: true)
          } else {
            openURL(url)
          }
        }
      } label: {
        ProfileRow(icon: "doc.fill", label: "Terms of Use", color: .gray) {
          Image(systemName: "chevron.right")
            .font(.caption2)
            .foregroundStyle(.tertiary)
        }
      }
      .buttonStyle(.plain)

      Divider().padding(.leading, 56).opacity(0.4)

      Button {
        if let url = privacyURL {
          if #available(iOS 26.0, *) {
            openURL(url, prefersInApp: true)
          } else {
            openURL(url)
          }
        }
      } label: {
        ProfileRow(icon: "hand.raised.fill", label: "Privacy Policy", color: .gray) {
          Image(systemName: "chevron.right")
            .font(.caption2)
            .foregroundStyle(.tertiary)
        }
      }
      .buttonStyle(.plain)

      Divider().opacity(0.2)

      Text(
        "Billing is managed securely by Apple. You can manage or cancel your subscription anytime."
      )
      .font(.caption)
      .foregroundStyle(.secondary)
      .multilineTextAlignment(.center)
      .padding(.horizontal, 16)
      .padding(.vertical, 14)
    }
    .proudlyGlass()
  }

  private var profileSummary: String {
    let habitCount = repository.activeHabits.count
    let longestStreak = repository.activeHabits.map(\.streak).max() ?? 0
    let habitLabel = habitCount == 1 ? "habit" : "habits"
    return "\(habitCount) \(habitLabel) · \(longestStreak.proudlyStreakLabel)"
  }

  private var reminderSummary: String {
    let count = repository.activeHabits.filter(\.remindersEnabled).count
    return count == 0 ? "Off" : count == 1 ? "1 active" : "\(count) active"
  }
}

struct PlusBadge: View {
  @Environment(ThemeViewModel.self) private var theme

  var body: some View {
    HStack(spacing: 4) {
      Image(systemName: "lock.fill")
        .font(.caption2)
      Text("Plus")
        .font(.system(size: 11, weight: .bold))
    }
    .foregroundStyle(.white)
    .padding(.horizontal, 8)
    .padding(.vertical, 4)
    .background(theme.activeTheme.accentGradient)
    .clipShape(Capsule())
  }
}

struct ProfileRow<Trailing: View>: View {
  let icon: String
  let label: String
  let color: Color
  @ViewBuilder let trailing: () -> Trailing

  var body: some View {
    HStack(spacing: 12) {
      ZStack {
        RoundedRectangle(cornerRadius: 8)
          .fill(color.opacity(0.15))
          .frame(width: 34, height: 34)
        Image(systemName: icon)
          .font(.system(size: 14))
          .foregroundStyle(color)
      }
      Text(label).font(.system(size: 16, weight: .medium))
      Spacer()
      trailing()
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(14)
    .contentShape(Rectangle())
  }
}

#Preview {
  ProfileView()
    .environment(ThemeViewModel())
    .environment(SubscriptionStore())
    .environment(HabitRepository.preview)
    .environment(ToastCenter())
}
