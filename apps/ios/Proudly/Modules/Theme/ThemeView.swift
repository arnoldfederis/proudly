//
//  ThemeView.swift
//  Proudly
//
//  Created by Arnolfo Federis on 6/12/26.
//

import SwiftUI

struct ThemeView: View {
  @Environment(ThemeViewModel.self) private var theme
  @Environment(SubscriptionStore.self) private var subscriptionStore
  var onLockedThemeTapped: () -> Void = {}

  var body: some View {
    NavigationStack {
      ZStack {
        theme.activeTheme.backgroundGradient.ignoresSafeArea()

        ScrollView {
          LazyVStack(spacing: 20) {
            themeSection
            Spacer(minLength: 80)
          }
          .padding(.horizontal, 20)
          .padding(.top, 8)
        }
      }
      .navigationTitle("Theme")
      .navigationBarTitleDisplayMode(.large)
      .toolbar(.hidden, for: .tabBar)
    }
    .preferredColorScheme(theme.activeTheme == .midnightCalm ? .dark : SystemAppearance.colorScheme)
    .onAppear {
      theme.isPlusUser = subscriptionStore.hasProudlyPlus
    }
  }

  private var themeSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("App Theme")
        .font(.footnote.weight(.semibold))
        .foregroundStyle(.secondary)
        .padding(.leading, 4)

      VStack(spacing: 0) {
        ForEach(Array(ProudlyAppTheme.allCases.enumerated()), id: \.element.id) { index, appTheme in
          themeRow(appTheme)
          if index < ProudlyAppTheme.allCases.count - 1 {
            Divider().padding(.leading, 64).opacity(0.4)
          }
        }
      }
      .proudlyGlass()
    }
  }

  @ViewBuilder
  private func themeRow(_ appTheme: ProudlyAppTheme) -> some View {
    let isSelected = theme.selectedTheme == appTheme
    let isLocked = appTheme.isPlusOnly && !subscriptionStore.hasProudlyPlus

    Button {
      if isLocked {
        onLockedThemeTapped()
      } else {
        theme.select(appTheme)
      }
    } label: {
      HStack(spacing: 14) {
        Circle()
          .fill(
            appTheme == .liquidGlass
              ? AnyShapeStyle(appTheme.accentColor) : AnyShapeStyle(appTheme.accentGradient)
          )
          .frame(width: 36, height: 36)

        VStack(alignment: .leading, spacing: 2) {
          Text(appTheme.displayName)
            .font(.system(size: 16, weight: .medium))
            .foregroundStyle(.primary)
          Text(appTheme.subtitle)
            .font(.caption)
            .foregroundStyle(.secondary)
        }

        Spacer()

        if isLocked {
          PlusBadge()
        } else if isSelected {
          Image(systemName: "checkmark")
            .font(.system(size: 14, weight: .bold))
            .foregroundStyle(theme.activeTheme.accentColor)
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(14)
      .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
  }
}

#Preview {
  ThemeView()
    .environment(ThemeViewModel())
    .environment(SubscriptionStore())
}
