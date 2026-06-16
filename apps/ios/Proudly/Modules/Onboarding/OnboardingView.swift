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
    stepContainer(
      title: "Proudly",
      subtitle: "Do one thing today that makes you proud."
    ) {
      VStack(spacing: 28) {
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
        .frame(maxWidth: .infinity)
        .padding(.top, 8)

        Text("A gentle habit tracker for small wins.")
          .font(.title3.weight(.semibold))
          .frame(maxWidth: .infinity, alignment: .center)
          .multilineTextAlignment(.center)
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
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)

    Text("No guilt. No pressure. Just small wins every day.")
      .font(.footnote.weight(.medium))
      .foregroundStyle(.secondary)
      .frame(maxWidth: .infinity, alignment: .center)
      .multilineTextAlignment(.center)

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
    .padding(.horizontal, 20)
    .padding(.top, 12)
    .padding(.bottom, 28)
  }

  private func stepContainer<Content: View>(
    title: String,
    subtitle: String,
    @ViewBuilder content: () -> Content
  ) -> some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 22) {
        VStack(alignment: .leading, spacing: 10) {
          Text(title)
            .font(.system(size: 30, weight: .bold, design: .rounded))
            .fixedSize(horizontal: false, vertical: true)
          Text(subtitle)
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
        }

        content()
      }
      .padding(.horizontal, 20)
      .padding(.top, 24)
      .padding(.bottom, 28)
    }
  }
}

#Preview {
  OnboardingView()
    .environment(ThemeViewModel())
}
