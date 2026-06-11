//
//  ProfileView.swift
//  Proudly
//
//  Created by Arnolfo Federis on 6/9/26.
//

import SwiftUI

struct ProfileView: View {
  @State private var viewModel = ProfileViewModel()
  @State private var showPaywall = false

  var body: some View {
    NavigationStack {
      ZStack {
        ProudlyTheme.backgroundGradient.ignoresSafeArea()

        ScrollView {
          VStack(spacing: 20) {
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
    }
  }

  private var profileCard: some View {
    VStack(spacing: 14) {
      HStack(spacing: 16) {
        ZStack {
          Circle()
            .fill(ProudlyTheme.purplePinkGradient)
            .frame(width: 60, height: 60)
          Text("A")
            .font(.system(size: 26, weight: .bold))
            .foregroundStyle(.white)
        }

        VStack(alignment: .leading, spacing: 4) {
          Text("Arnolfo")
            .font(.system(size: 18, weight: .bold))
          Text("3 habits · 12-day streak")
            .font(.caption)
            .foregroundStyle(.secondary)
        }

        Spacer()
      }

      Divider().opacity(0.4)

      HStack {
        VStack(alignment: .leading, spacing: 2) {
          Text("Proudly Free")
            .font(.system(size: 14, weight: .semibold))
          Text("3 habits included")
            .font(.caption)
            .foregroundStyle(.secondary)
        }

        Spacer()

        Button {
          showPaywall = true
        } label: {
          Text("Upgrade")
            .font(.system(size: 13, weight: .bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(ProudlyTheme.purplePinkGradient)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
      }
    }
    .padding(20)
    .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 22))
  }

  private var settingsSection: some View {
    VStack(spacing: 0) {
      Button {
        showPaywall = true
      } label: {
        ProfileRow(icon: "icloud.fill", label: "iCloud Sync", color: ProudlyTheme.blue) {
          PlusBadge()
        }
      }
      .buttonStyle(.plain)

      Divider().padding(.leading, 56).opacity(0.4)

      ProfileRow(icon: "bell.fill", label: "Reminders", color: ProudlyTheme.pink) {
        Toggle("", isOn: $viewModel.remindersEnabled).labelsHidden()
      }

      Divider().padding(.leading, 56).opacity(0.4)

      Button {
        showPaywall = true
      } label: {
        ProfileRow(icon: "paintbrush.fill", label: "Theme", color: ProudlyTheme.purple) {
          HStack(spacing: 6) {
            Text(viewModel.selectedTheme)
              .font(.subheadline)
              .foregroundStyle(.secondary)
            PlusBadge()
          }
        }
      }
      .buttonStyle(.plain)

      Divider().padding(.leading, 56).opacity(0.4)

      Button {
        showPaywall = true
      } label: {
        ProfileRow(icon: "heart.fill", label: "Proud Moments", color: ProudlyTheme.mint) {
          PlusBadge()
        }
      }
      .buttonStyle(.plain)
    }
    .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 22))
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
    .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 22))
  }
}

private struct PlusBadge: View {
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
    .background(ProudlyTheme.purplePinkGradient)
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
    .padding(14)
  }
}

#Preview {
  ProfileView()
}
