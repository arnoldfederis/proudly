//
//  ProudlyPlusView.swift
//  Proudly
//
//  Created by Arnolfo Federis on 6/11/26.
//

import SwiftUI

struct ProudlyPlusView: View {
  @Environment(\.dismiss) private var dismiss

  private let benefits: [(icon: String, text: String, color: Color)] = [
    ("infinity", "Unlimited habits", ProudlyTheme.purple),
    ("icloud.fill", "iCloud sync and backup", ProudlyTheme.blue),
    ("chart.bar.fill", "Advanced insights", ProudlyTheme.mint),
    ("calendar.badge.clock", "Weekly reports", ProudlyTheme.blue),
    ("heart.text.square.fill", "Proud Moments history", ProudlyTheme.pink),
    ("paintpalette.fill", "Custom themes", ProudlyTheme.pink),
    ("square.grid.2x2.fill", "Widgets (coming soon)", .orange),
  ]

  var body: some View {
    ZStack {
      ProudlyTheme.backgroundGradient.ignoresSafeArea()

      VStack(spacing: 0) {
        closeButton

        ScrollView {
          VStack(spacing: 28) {
            heroSection
            benefitsSection
            ctaSection
          }
          .padding(.horizontal, 24)
          .padding(.bottom, 40)
        }
      }
    }
  }

  private var closeButton: some View {
    HStack {
      Spacer()
      Button {
        dismiss()
      } label: {
        Image(systemName: "xmark.circle.fill")
          .font(.title2)
          .foregroundStyle(.secondary)
      }
      .buttonStyle(.plain)
      .padding()
    }
  }

  private var heroSection: some View {
    VStack(spacing: 14) {
      ZStack {
        Circle()
          .fill(
            LinearGradient(
              colors: [ProudlyTheme.purple.opacity(0.2), ProudlyTheme.pink.opacity(0.2)],
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            )
          )
          .frame(width: 110, height: 110)
        Image(systemName: "trophy.fill")
          .font(.system(size: 48))
          .foregroundStyle(ProudlyTheme.purplePinkGradient)
      }

      Text("Proudly Plus")
        .font(.system(size: 32, weight: .bold, design: .rounded))

      Text("Unlock your best self.")
        .font(.subheadline)
        .foregroundStyle(.secondary)
    }
  }

  private var benefitsSection: some View {
    VStack(spacing: 10) {
      ForEach(benefits, id: \.icon) { benefit in
        HStack(spacing: 14) {
          ZStack {
            Circle()
              .fill(benefit.color.opacity(0.15))
              .frame(width: 42, height: 42)
            Image(systemName: benefit.icon)
              .foregroundStyle(benefit.color)
          }
          Text(benefit.text)
            .font(.system(size: 16, weight: .medium))
          Spacer()
          Image(systemName: "checkmark")
            .font(.system(size: 13, weight: .bold))
            .foregroundStyle(benefit.color)
        }
        .padding(14)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 16))
      }
    }
  }

  private var ctaSection: some View {
    VStack(spacing: 14) {
      Button {
        Haptics.impact(.medium)
      } label: {
        Text("Try 7 Days Free")
          .font(.system(size: 17, weight: .semibold))
          .foregroundStyle(.white)
          .frame(maxWidth: .infinity)
          .padding(.vertical, 17)
          .background(ProudlyTheme.purplePinkGradient)
          .clipShape(RoundedRectangle(cornerRadius: 20))
      }
      .buttonStyle(.plain)

      Text("$14.99 / year after free trial")
        .font(.caption)
        .foregroundStyle(.secondary)

      Button {
        Haptics.impact(.light)
      } label: {
        Text("Restore Purchases")
          .font(.subheadline)
          .foregroundStyle(.secondary)
      }
      .buttonStyle(.plain)
    }
  }
}

#Preview {
  ProudlyPlusView()
}
