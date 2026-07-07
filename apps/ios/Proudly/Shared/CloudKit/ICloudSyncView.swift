//
//  ICloudSyncView.swift
//  Proudly
//
//  Created by Arnolfo Federis on 7/3/26.
//

import CloudKit
import SwiftUI

struct ICloudSyncView: View {
  @Environment(ThemeViewModel.self) private var theme
  @Environment(CloudKitSyncMonitor.self) private var monitor
  @Environment(SubscriptionStore.self) private var subscriptionStore
  @AppStorage(ProudlyApp.iCloudSyncEnabledKey) private var iCloudSyncEnabled = false
  @State private var initialEnabledState: Bool?
  @State private var showPaywall = false

  var body: some View {
    ZStack {
      theme.activeTheme.backgroundGradient.ignoresSafeArea()

      ScrollView {
        VStack(spacing: 20) {
          toggleCard
          if restartNeeded {
            restartNotice
          }
          statusCard
          infoCard
          Spacer(minLength: 40)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
      }
    }
    .navigationTitle("iCloud Sync")
    .navigationBarTitleDisplayMode(.large)
    .toolbar(.hidden, for: .tabBar)
    .task {
      await monitor.refreshAccountStatus()
      if initialEnabledState == nil {
        initialEnabledState = iCloudSyncEnabled
      }
    }
    .sheet(isPresented: $showPaywall) {
      ProudlyPlusView()
    }
  }

  private var restartNeeded: Bool {
    guard let initial = initialEnabledState else { return false }
    return initial != iCloudSyncEnabled
  }

  private var toggleCard: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack(spacing: 14) {
        ZStack {
          Circle()
            .fill(ProudlyTheme.blue.opacity(0.15))
            .frame(width: 46, height: 46)
          Image(systemName: "icloud.fill")
            .font(.system(size: 20, weight: .semibold))
            .foregroundStyle(ProudlyTheme.blue)
        }
        VStack(alignment: .leading, spacing: 4) {
          Text("Sync with iCloud")
            .font(.system(size: 17, weight: .semibold))
          Text(
            subscriptionStore.hasProudlyPlus
              ? "Habits sync across your Apple devices."
              : "Available with Proudly Plus."
          )
          .font(.caption)
          .foregroundStyle(.secondary)
        }
        Spacer()
        if subscriptionStore.hasProudlyPlus {
          Toggle("", isOn: $iCloudSyncEnabled)
            .labelsHidden()
            .tint(theme.activeTheme.accentColor)
        } else {
          Button {
            showPaywall = true
          } label: {
            PlusBadge()
          }
          .buttonStyle(.plain)
        }
      }
    }
    .padding(18)
    .proudlyGlass()
  }

  private var restartNotice: some View {
    HStack(alignment: .top, spacing: 12) {
      Image(systemName: "arrow.clockwise.circle.fill")
        .font(.system(size: 18, weight: .semibold))
        .foregroundStyle(ProudlyTheme.pink)
      VStack(alignment: .leading, spacing: 4) {
        Text("Restart required")
          .font(.subheadline.weight(.semibold))
        Text("Quit and reopen Proudly to apply the new sync setting.")
          .font(.caption)
          .foregroundStyle(.secondary)
      }
      Spacer(minLength: 0)
    }
    .padding(14)
    .proudlyGlass()
  }

  private var statusCard: some View {
    VStack(spacing: 16) {
      HStack(spacing: 14) {
        ZStack {
          Circle()
            .fill(statusColor.opacity(0.15))
            .frame(width: 46, height: 46)
          Image(systemName: statusSymbol)
            .font(.system(size: 20, weight: .semibold))
            .foregroundStyle(statusColor)
        }

        VStack(alignment: .leading, spacing: 4) {
          Text(statusTitle)
            .font(.system(size: 17, weight: .semibold))
          Text(statusDetail)
            .font(.caption)
            .foregroundStyle(.secondary)
        }

        Spacer()

        if case .syncing = monitor.status {
          ProgressView().scaleEffect(0.9)
        }
      }

      if let lastSyncedAt = monitor.lastSyncedAt {
        Divider().opacity(0.4)
        HStack {
          Text("Last synced")
            .font(.subheadline)
            .foregroundStyle(.secondary)
          Spacer()
          Text(lastSyncedAt, style: .relative)
            .font(.subheadline.weight(.medium))
        }
      }
    }
    .padding(18)
    .proudlyGlass()
  }

  private var infoCard: some View {
    VStack(alignment: .leading, spacing: 12) {
      infoRow(
        symbol: "icloud",
        title: "Sync your habits across devices with iCloud."
      )
      infoRow(
        symbol: "lock.shield",
        title: "Your habit data is stored in your private iCloud account."
      )
      infoRow(
        symbol: "iphone",
        title: "Proudly still works locally when iCloud is unavailable."
      )
      infoRow(
        symbol: "bell",
        title: "Reminders are scheduled locally on each device."
      )
    }
    .padding(18)
    .proudlyGlass()
  }

  private func infoRow(symbol: String, title: String) -> some View {
    HStack(alignment: .top, spacing: 12) {
      Image(systemName: symbol)
        .font(.system(size: 15, weight: .semibold))
        .foregroundStyle(theme.activeTheme.accentColor)
        .frame(width: 22)
      Text(title)
        .font(.subheadline)
        .foregroundStyle(.primary.opacity(0.85))
      Spacer(minLength: 0)
    }
  }

  private var statusSymbol: String {
    switch monitor.status {
    case .syncing: "arrow.triangle.2.circlepath.icloud"
    case .idle: "checkmark.icloud.fill"
    case .signedOut: "person.icloud"
    case .unavailable: "icloud.slash"
    case .localOnly: "iphone"
    case .error: "exclamationmark.icloud"
    case .unknown: "icloud"
    }
  }

  private var statusColor: Color {
    switch monitor.status {
    case .syncing: ProudlyTheme.blue
    case .idle: ProudlyTheme.mint
    case .signedOut, .unavailable: ProudlyTheme.pink
    case .localOnly: .secondary
    case .error: ProudlyTheme.pink
    case .unknown: .secondary
    }
  }

  private var statusTitle: String {
    switch monitor.status {
    case .syncing: "Syncing with iCloud"
    case .idle: "iCloud sync active"
    case .signedOut: "Sign in to iCloud to sync"
    case .unavailable: "iCloud unavailable"
    case .localOnly: "Local only"
    case .error: "Sync error"
    case .unknown: "Checking iCloud"
    }
  }

  private var statusDetail: String {
    switch monitor.status {
    case .syncing: "Your habits are updating across devices."
    case .idle: "Your habits sync to your iCloud account."
    case .signedOut: "Open Settings and sign in to iCloud to sync."
    case .unavailable: "Sync will resume when iCloud is available."
    case .localOnly: "Habits are saved on this device only."
    case .error(let message): message
    case .unknown: "Checking your iCloud account status."
    }
  }
}

#Preview {
  NavigationStack {
    ICloudSyncView()
  }
  .environment(ThemeViewModel())
  .environment(CloudKitSyncMonitor())
  .environment(SubscriptionStore())
}
