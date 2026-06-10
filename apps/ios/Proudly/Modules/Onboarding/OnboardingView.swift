//
//  OnboardingView.swift
//  Proudly
//
//  Created by Arnolfo Federis on 6/11/26.
//

import SwiftUI

struct OnboardingView: View {
  var onGetStarted: () -> Void = {}

  private let features: [(icon: String, text: String, color: Color)] = [
    ("checkmark.circle.fill", "Track habits", ProudlyTheme.mint),
    ("flame.fill", "Build streaks", ProudlyTheme.pink),
    ("heart.fill", "Feel proud", ProudlyTheme.purple),
    ("chart.bar.fill", "Grow every day", ProudlyTheme.blue),
  ]

  var body: some View {
    ZStack {
      ProudlyTheme.backgroundGradient.ignoresSafeArea()

      VStack(spacing: 0) {
        Spacer()

        logoSection
          .padding(.bottom, 40)

        featuresSection
          .padding(.horizontal, 32)
          .padding(.bottom, 48)

        getStartedButton
          .padding(.horizontal, 32)
          .padding(.bottom, 60)
      }
    }
  }

  private var logoSection: some View {
    VStack(spacing: 16) {
      ZStack {
        Circle()
          .fill(
            LinearGradient(
              colors: [ProudlyTheme.purple.opacity(0.2), ProudlyTheme.pink.opacity(0.15)],
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            )
          )
          .frame(width: 110, height: 110)
        Image(systemName: "heart.circle.fill")
          .font(.system(size: 56))
          .foregroundStyle(ProudlyTheme.purplePinkGradient)
      }

      Text("Proudly")
        .font(.system(size: 42, weight: .bold, design: .rounded))
        .foregroundStyle(ProudlyTheme.purplePinkGradient)

      Text("A gentle habit tracker for small wins.")
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)
    }
  }

  private var featuresSection: some View {
    VStack(spacing: 10) {
      ForEach(features, id: \.icon) { feature in
        HStack(spacing: 14) {
          Image(systemName: feature.icon)
            .font(.system(size: 20))
            .foregroundStyle(feature.color)
            .frame(width: 28)
          Text(feature.text)
            .font(.system(size: 16, weight: .medium))
          Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 16))
      }
    }
  }

  private var getStartedButton: some View {
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
  }
}

#Preview {
  OnboardingView()
}
