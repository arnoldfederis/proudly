//
//  OnboardingCelebrationView.swift
//  Proudly
//
//  Created by Arnolfo Federis on 6/16/26.
//

import SwiftUI

struct OnboardingCelebrationView: View {
  let message: String?
  let onContinue: () -> Void

  @State private var animateParticles = false
  @State private var animateBadge = false

  private let particleColors: [Color] = [
    ProudlyTheme.purple,
    ProudlyTheme.pink,
    ProudlyTheme.blue,
    ProudlyTheme.mint,
  ]

  var body: some View {
    VStack(spacing: 0) {
      stepContainer(
        title: "Welcome to Proudly",
        subtitle: "Start simple. Do one thing today that makes you proud."
      ) {
        Spacer()

        VStack(spacing: 28) {
          ZStack {
            ForEach(0..<18, id: \.self) { index in
              Circle()
                .fill(particleColors[index % particleColors.count].opacity(0.85))
                .frame(width: 10, height: 10)
                .offset(y: animateParticles ? 130 : 0)
                .offset(x: animateParticles ? particleOffset(for: index) : 0)
                .opacity(animateParticles ? 0 : 1)
                .animation(
                  .easeOut(duration: 1.2).delay(Double(index) * 0.03),
                  value: animateParticles
                )
            }

            Circle()
              .fill(
                LinearGradient(
                  colors: [ProudlyTheme.purple.opacity(0.28), ProudlyTheme.mint.opacity(0.20)],
                  startPoint: .topLeading,
                  endPoint: .bottomTrailing
                )
              )
              .frame(width: 132, height: 132)

            Image(systemName: "sparkles")
              .font(.system(size: 48, weight: .semibold))
              .foregroundStyle(ProudlyTheme.purplePinkGradient)
              .scaleEffect(animateBadge ? 1 : 0.82)
              .animation(.spring(response: 0.6, dampingFraction: 0.68), value: animateBadge)
          }
          .frame(maxWidth: .infinity)
          .padding(.top, 40)

          VStack(spacing: 10) {
            Text("Your first small win is ready.")
              .font(.title3.weight(.semibold))
              .multilineTextAlignment(.center)

            if let message {
              Text(message)
                .font(.footnote.weight(.medium))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 4)
            }
          }
          .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, alignment: .top)
      }

      Button(action: onContinue) {
        Text("Go to Today")
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
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .onAppear {
      Haptics.notification(.success)
      animateBadge = true
      animateParticles = true
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

  private func particleOffset(for index: Int) -> CGFloat {
    let direction: CGFloat = index.isMultiple(of: 2) ? 1 : -1
    let spread = CGFloat((index % 5) + 1) * 18
    return direction * spread
  }
}

#Preview {
  OnboardingCelebrationView(message: nil, onContinue: {})
}
