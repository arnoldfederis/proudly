//
//  SubscriptionManagementView.swift
//  Proudly
//
//  Created by Arnolfo Federis on 6/18/26.
//

import RevenueCatUI
import SwiftUI

struct SubscriptionManagementView: View {
  @Environment(ThemeViewModel.self) private var theme
  @Environment(SubscriptionStore.self) private var subscriptionStore
  @Environment(HabitRepository.self) private var repository
  @Environment(ToastCenter.self) private var toastCenter

  @State private var showPaywall = false
  @State private var showCustomerCenter = false

  var body: some View {
    NavigationStack {
      ZStack {
        theme.activeTheme.backgroundGradient.ignoresSafeArea()

        ScrollView {
          LazyVStack(spacing: 20) {
            subscriptionStatusCard
            includedWithPlusSection
            usageSection
            Spacer(minLength: 80)
          }
          .padding(.horizontal, 20)
          .padding(.top, 8)
        }
      }
      .navigationTitle("Subscription")
      .navigationBarTitleDisplayMode(.large)
      .toolbar(.hidden, for: .tabBar)
      .sheet(isPresented: $showPaywall) {
        ProudlyPlusView()
      }
      .sheet(isPresented: $showCustomerCenter) {
        ZStack {
          theme.activeTheme.backgroundGradient.ignoresSafeArea()
          CustomerCenterView()
        }
      }
      .alert(
        subscriptionStore.presentedAlert?.title ?? "Restore Failed",
        isPresented: Binding(
          get: { subscriptionStore.presentedAlert != nil },
          set: { isPresented in
            if !isPresented { subscriptionStore.clearAlert() }
          }
        ),
        presenting: subscriptionStore.presentedAlert
      ) { _ in
        Button("OK") { subscriptionStore.clearAlert() }
      } message: { alert in
        Text(alert.message)
      }
    }
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
  }

  // MARK: - Subscription status card

  private var subscriptionStatusCard: some View {
    VStack(alignment: .leading, spacing: 16) {
      HStack(alignment: .top) {
        VStack(alignment: .leading, spacing: 6) {
          Text(subscriptionStore.hasProudlyPlus ? "Proudly Plus" : "Proudly Free")
            .font(.system(size: 20, weight: .bold))

          Text(subscriptionStore.hasProudlyPlus ? "Active" : "3 habits included")
            .font(.caption.weight(.semibold))
            .foregroundStyle(
              subscriptionStore.hasProudlyPlus ? theme.activeTheme.accentColor : .secondary
            )
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
              subscriptionStore.hasProudlyPlus
                ? theme.activeTheme.accentColor.opacity(0.14)
                : Color.secondary.opacity(0.10),
              in: Capsule()
            )
        }

        Spacer()

        Image(systemName: subscriptionStore.hasProudlyPlus ? "sparkles" : "lock.open")
          .font(.system(size: 22, weight: .medium))
          .foregroundStyle(
            subscriptionStore.hasProudlyPlus ? theme.activeTheme.accentColor : Color.secondary
          )
          .padding(.top, 2)
      }

      Text(
        subscriptionStore.hasProudlyPlus
          ? "Unlimited habits, custom themes, Proud Moments, and deeper insights are unlocked."
          : "Track up to 3 habits for free. Upgrade when you're ready for more room to grow."
      )
      .font(.subheadline)
      .foregroundStyle(.secondary)
      .fixedSize(horizontal: false, vertical: true)

      Button {
        if subscriptionStore.hasProudlyPlus {
          showCustomerCenter = true
        } else {
          showPaywall = true
        }
      } label: {
        Text(subscriptionStore.hasProudlyPlus ? "Manage Subscription" : "Upgrade to Proudly Plus")
          .font(.system(size: 16, weight: .semibold))
          .foregroundStyle(.white)
          .frame(maxWidth: .infinity)
          .padding(.vertical, 14)
          .background(theme.activeTheme.accentGradient)
          .clipShape(RoundedRectangle(cornerRadius: 18))
      }
      .buttonStyle(.plain)
    }
    .padding(20)
    .proudlyGlass()
  }

  // MARK: - Included with Plus section

  private var includedWithPlusSection: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("Included with Proudly Plus")
        .font(.footnote.weight(.semibold))
        .foregroundStyle(.secondary)
        .padding(.horizontal, 4)

      VStack(spacing: 0) {
        ForEach(Self.plusBenefits, id: \.title) { benefit in
          Button {
            if !subscriptionStore.hasProudlyPlus { showPaywall = true }
          } label: {
            HStack(spacing: 14) {
              ZStack {
                RoundedRectangle(cornerRadius: 8)
                  .fill(benefit.color.opacity(0.15))
                  .frame(width: 34, height: 34)
                Image(systemName: benefit.icon)
                  .font(.system(size: 14))
                  .foregroundStyle(benefit.color)
              }

              VStack(alignment: .leading, spacing: 2) {
                Text(benefit.title)
                  .font(.system(size: 15, weight: .semibold))
                  .foregroundStyle(.primary)
                Text(benefit.description)
                  .font(.caption)
                  .foregroundStyle(.secondary)
              }

              Spacer()

              if subscriptionStore.hasProudlyPlus {
                Image(systemName: "checkmark.circle.fill")
                  .font(.system(size: 16))
                  .foregroundStyle(theme.activeTheme.accentColor)
              } else {
                PlusBadge()
              }
            }
            .padding(14)
            .contentShape(Rectangle())
          }
          .buttonStyle(.plain)

          if benefit.title != Self.plusBenefits.last?.title {
            Divider().padding(.leading, 62).opacity(0.4)
          }
        }
      }
      .proudlyGlass()
    }
  }

  private static let plusBenefits: [PlusBenefitItem] = [
    PlusBenefitItem(
      icon: "infinity", color: ProudlyTheme.purple,
      title: "Unlimited habits",
      description: "Track every small win that matters to you."
    ),
    PlusBenefitItem(
      icon: "paintpalette.fill", color: ProudlyTheme.purple,
      title: "Custom themes",
      description: "Personalize Proudly with curated themes that change the look and feel."
    ),
    PlusBenefitItem(
      icon: "heart.fill", color: ProudlyTheme.pink,
      title: "Proud Moments history",
      description: "Look back at the wins you have completed."
    ),
    PlusBenefitItem(
      icon: "chart.line.uptrend.xyaxis", color: ProudlyTheme.mint,
      title: "Advanced progress insights",
      description: "Understand your progress without pressure."
    ),
  ]

  // MARK: - Usage section

  private var activeHabitCount: Int { repository.activeHabits.count }
  private var proudMomentCount: Int { repository.proudMoments.count }
  private var activeReminderCount: Int {
    repository.activeHabits.filter(\.remindersEnabled).count
  }
  private var longestCurrentStreak: Int {
    repository.activeHabits.map(\.streak).max() ?? 0
  }

  private var usageSection: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("Your usage")
        .font(.footnote.weight(.semibold))
        .foregroundStyle(.secondary)
        .padding(.horizontal, 4)

      if subscriptionStore.hasProudlyPlus {
        plusUsageCard
      } else {
        freeUsageCard
      }
    }
  }

  private var plusUsageCard: some View {
    VStack(spacing: 0) {
      usageStat(
        icon: "checkmark.rectangle.stack",
        color: theme.activeTheme.accentColor,
        value: "\(activeHabitCount)",
        label: activeHabitCount == 1 ? "active habit" : "active habits"
      )
      Divider().padding(.leading, 56).opacity(0.4)
      usageStat(
        icon: "heart.fill",
        color: ProudlyTheme.pink,
        value: "\(proudMomentCount)",
        label: proudMomentCount == 1 ? "proud moment" : "proud moments"
      )
      Divider().padding(.leading, 56).opacity(0.4)
      usageStat(
        icon: "bell.fill",
        color: ProudlyTheme.blue,
        value: "\(activeReminderCount)",
        label: activeReminderCount == 1 ? "active reminder" : "active reminders"
      )
      Divider().padding(.leading, 56).opacity(0.4)
      usageStat(
        icon: "flame.fill",
        color: ProudlyTheme.pink,
        value: longestCurrentStreak.proudlyDayPhrase,
        label: "best current streak"
      )
    }
    .proudlyGlass()
  }

  private var freeUsageCard: some View {
    VStack(spacing: 0) {
      usageStat(
        icon: "checkmark.rectangle.stack",
        color: theme.activeTheme.accentColor,
        value: "\(activeHabitCount) of 3",
        label: "free habits used"
      )
      Divider().padding(.leading, 56).opacity(0.4)
      Button {
        showPaywall = true
      } label: {
        usageStat(
          icon: "heart.fill",
          color: ProudlyTheme.pink,
          value: "\(proudMomentCount)",
          label: "proud moments ready with Plus"
        )
      }
      .buttonStyle(.plain)
      Divider().padding(.leading, 56).opacity(0.4)
      Button {
        showPaywall = true
      } label: {
        HStack(spacing: 14) {
          ZStack {
            RoundedRectangle(cornerRadius: 8)
              .fill(theme.activeTheme.accentColor.opacity(0.15))
              .frame(width: 34, height: 34)
            Image(systemName: "arrow.up.circle.fill")
              .font(.system(size: 14))
              .foregroundStyle(theme.activeTheme.accentColor)
          }
          Text("Upgrade for unlimited habits")
            .font(.system(size: 15, weight: .medium))
            .foregroundStyle(theme.activeTheme.accentColor)
          Spacer()
          Image(systemName: "chevron.right")
            .font(.caption2)
            .foregroundStyle(.tertiary)
        }
        .padding(14)
        .contentShape(Rectangle())
      }
      .buttonStyle(.plain)
    }
    .proudlyGlass()
  }

  private func usageStat(icon: String, color: Color, value: String, label: String) -> some View {
    HStack(spacing: 14) {
      ZStack {
        RoundedRectangle(cornerRadius: 8)
          .fill(color.opacity(0.15))
          .frame(width: 34, height: 34)
        Image(systemName: icon)
          .font(.system(size: 14))
          .foregroundStyle(color)
      }
      HStack(alignment: .firstTextBaseline, spacing: 4) {
        Text(value)
          .font(.system(size: 15, weight: .bold))
          .foregroundStyle(.primary)
        Text(label)
          .font(.system(size: 14, weight: .medium))
          .foregroundStyle(.secondary)
      }
      Spacer()
    }
    .padding(14)
    .contentShape(Rectangle())
  }
}

private struct PlusBenefitItem {
  let icon: String
  let color: Color
  let title: String
  let description: String
}

#Preview {
  SubscriptionManagementView()
    .environment(ThemeViewModel())
    .environment(SubscriptionStore())
    .environment(HabitRepository.preview)
    .environment(ToastCenter())
}
