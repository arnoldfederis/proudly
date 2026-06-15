//
//  ProfileView.swift
//  Proudly
//
//  Created by Arnolfo Federis on 6/9/26.
//

import RevenueCatUI
import SwiftUI

struct ProfileView: View {
  @Environment(ThemeViewModel.self) private var theme
  @Environment(SubscriptionStore.self) private var subscriptionStore
  @Environment(HabitRepository.self) private var repository
  @State private var viewModel = ProfileViewModel()
  @State private var showPaywall = false
  @State private var showThemeView = false
  @State private var showCustomerCenter = false
  @State private var navigateToProudMoments = false

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
      .sheet(isPresented: $showThemeView) {
        ThemeView(onLockedThemeTapped: {
          showThemeView = false
          showPaywall = true
        })
      }
      .navigationDestination(isPresented: $navigateToProudMoments) {
        ProudMomentsView()
      }
      .presentCustomerCenter(isPresented: $showCustomerCenter)
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
          Button {
            showCustomerCenter = true
          } label: {
            Text("Manage")
              .font(.system(size: 13, weight: .bold))
              .foregroundStyle(theme.activeTheme.accentColor)
              .padding(.horizontal, 16)
              .padding(.vertical, 8)
              .background(theme.activeTheme.accentColor.opacity(0.12))
              .clipShape(Capsule())
          }
          .buttonStyle(.plain)
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
        if !subscriptionStore.hasProudlyPlus {
          showPaywall = true
        }

        viewModel.iCloudSyncEnabled.toggle()
      } label: {
        ProfileRow(icon: "icloud.fill", label: "iCloud Sync", color: ProudlyTheme.blue) {
          if subscriptionStore.hasProudlyPlus {
            Toggle("", isOn: $viewModel.iCloudSyncEnabled).labelsHidden()
          } else {
            PlusBadge()
          }
        }
      }
      .buttonStyle(.plain)

      Divider().padding(.leading, 56).opacity(0.4)

      Button {
        viewModel.remindersEnabled.toggle()
      } label: {
        ProfileRow(icon: "bell.fill", label: "Reminders", color: ProudlyTheme.pink) {
          Toggle("", isOn: $viewModel.remindersEnabled).labelsHidden()
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
        if subscriptionStore.hasProudlyPlus {
          showCustomerCenter = true
        } else {
          showPaywall = true
        }
      } label: {
        ProfileRow(
          icon: "creditcard.fill",
          label: subscriptionStore.hasProudlyPlus ? "Manage Subscription" : "Subscription",
          color: theme.activeTheme.accentColor
        ) {
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

  private var profileSummary: String {
    let habitCount = repository.activeHabits.count
    let longestStreak = repository.activeHabits.map(\.streak).max() ?? 0
    let habitLabel = habitCount == 1 ? "habit" : "habits"

    return "\(habitCount) \(habitLabel) · \(longestStreak.proudlyStreakLabel)"
  }

  private var legalSection: some View {
    VStack(spacing: 0) {
      ProfileRow(icon: "questionmark.circle.fill", label: "Help Center", color: .gray) {
        Image(systemName: "chevron.right").font(.caption2).foregroundStyle(.tertiary)
      }
      Divider().padding(.leading, 56).opacity(0.4)
      ProfileRow(icon: "hand.raised.fill", label: "Privacy Policy", color: .gray) {
        Image(systemName: "chevron.right").font(.caption2).foregroundStyle(.tertiary)
      }
      Divider().padding(.leading, 56).opacity(0.4)
      ProfileRow(icon: "doc.fill", label: "Terms of Use", color: .gray) {
        Image(systemName: "chevron.right").font(.caption2).foregroundStyle(.tertiary)
      }
    }
    .proudlyGlass()
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
}
