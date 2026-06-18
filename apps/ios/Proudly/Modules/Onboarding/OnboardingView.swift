//
//  OnboardingView.swift
//  Proudly
//
//  Created by Arnolfo Federis on 6/16/26.
//

import SwiftUI

struct OnboardingView: View {
  @Environment(ThemeViewModel.self) private var theme
  @Environment(\.colorScheme) private var colorScheme
  var onGetStarted: () -> Void = {}

  @State private var isLoading = false

  private let features: [(icon: String, text: String, color: Color)] = [
    ("checkmark.circle.fill", "Track small wins", ProudlyTheme.mint),
    ("flame.fill", "Build gentle streaks", ProudlyTheme.pink),
    ("bell.badge.fill", "Stay in rhythm", ProudlyTheme.blue),
    ("heart.fill", "Feel proud every day", ProudlyTheme.purple),
  ]

  private var backgroundGradientColors: [Color] {
    if colorScheme == .dark {
      return [
        Color(red: 0.10, green: 0.09, blue: 0.16),
        Color(red: 0.09, green: 0.13, blue: 0.18),
        Color(red: 0.10, green: 0.14, blue: 0.13),
      ]
    }

    return [
      Color(red: 0.98, green: 0.95, blue: 1.0),
      Color(red: 0.93, green: 0.97, blue: 1.0),
      Color(red: 0.95, green: 0.99, blue: 0.97),
    ]
  }

  var body: some View {
    ZStack {
      AnimatedAmbientBackground(gradientColors: backgroundGradientColors)

      VStack {
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

              Image("AppIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 110, height: 110)
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

        Button {
          isLoading = true
          Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(500))
            onGetStarted()
          }
        } label: {
          Group {
            if isLoading {
              ProgressView()
                .tint(.white)
            } else {
              Text("Get Started")
                .font(.system(size: 17, weight: .semibold))
            }
          }
          .foregroundStyle(.white)
          .frame(maxWidth: .infinity)
          .padding(.vertical, 17)
          .background(ProudlyTheme.purplePinkGradient)
          .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 28)
      }
    }
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
