//
//  OnboardingView.swift
//  Proudly
//
//  Created by Arnolfo Federis on 6/16/26.
//

import SwiftUI

struct OnboardingView: View {
  @Environment(ThemeViewModel.self) private var theme
  var onGetStarted: () -> Void = {}

  private let features: [(icon: String, text: String, color: Color)] = [
    ("checkmark.circle.fill", "Track small wins", ProudlyTheme.mint),
    ("flame.fill", "Build gentle streaks", ProudlyTheme.pink),
    ("bell.badge.fill", "Stay in rhythm", ProudlyTheme.blue),
    ("heart.fill", "Feel proud every day", ProudlyTheme.purple),
  ]

  var body: some View {
    VStack(spacing: 28) {
      Spacer(minLength: 24)

      VStack(spacing: 18) {
        ZStack {
          Circle()
            .fill(
              LinearGradient(
                colors: [ProudlyTheme.purple.opacity(0.22), ProudlyTheme.blue.opacity(0.16)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
              )
            )
            .frame(width: 118, height: 118)

          Image(systemName: "sparkles")
            .font(.system(size: 44, weight: .semibold))
            .foregroundStyle(ProudlyTheme.purplePinkGradient)
            .symbolEffect(.bounce, value: features.count)
        }

        VStack(spacing: 10) {
          Text("Proudly")
            .font(.system(size: 40, weight: .bold, design: .rounded))
            .foregroundStyle(ProudlyTheme.purplePinkGradient)

          Text("A gentle habit tracker for small wins.")
            .font(.title3.weight(.semibold))

          Text("Do one thing today that makes you proud.")
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
        }
      }

      VStack(spacing: 12) {
        ForEach(features, id: \.icon) { feature in
          HStack(spacing: 14) {
            Image(systemName: feature.icon)
              .font(.system(size: 18, weight: .semibold))
              .foregroundStyle(feature.color)
              .frame(width: 26, height: 26)
            Text(feature.text)
              .font(.system(size: 16, weight: .medium))
            Spacer()
          }
          .padding(.horizontal, 18)
          .padding(.vertical, 15)
          .proudlyGlass(cornerRadius: 18)
        }
      }

      VStack(spacing: 6) {
        Text("No guilt. No pressure. Just small wins every day.")
          .font(.footnote.weight(.medium))
          .foregroundStyle(.secondary)
          .multilineTextAlignment(.center)
      }

      Button(action: onGetStarted) {
        Text("Get Started")
          .font(.system(size: 17, weight: .semibold))
          .foregroundStyle(.white)
          .frame(maxWidth: .infinity)
          .padding(.vertical, 17)
          .background(ProudlyTheme.purplePinkGradient)
          .clipShape(RoundedRectangle(cornerRadius: 20))
      }
      .buttonStyle(.plain)
      .padding(.top, 8)

      Spacer()
    }
    .padding(.horizontal, 24)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(theme.activeTheme.backgroundGradient)
  }
}

#Preview {
  OnboardingView()
    .environment(ThemeViewModel())
}
