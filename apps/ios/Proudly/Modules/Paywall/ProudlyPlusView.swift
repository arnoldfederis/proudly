//
//  ProudlyPlusView.swift
//  Proudly
//
//  Created by Arnolfo Federis on 6/15/26.
//

import RevenueCat
import RevenueCatUI
import SwiftUI

struct ProudlyPlusView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.colorScheme) private var colorScheme
  @Environment(ThemeViewModel.self) private var theme
  @Environment(SubscriptionStore.self) private var subscriptionStore
  @Environment(ToastCenter.self) private var toastCenter

  @State private var showCustomerCenter = false

  // V1 paywall rule: only list features that are functional in this app version.
  private let benefits: [ProudlyPlusBenefit] = [
    .init(
      icon: "infinity",
      title: "Unlimited habits",
      description: "Track every small win that matters to you.",
      color: ProudlyTheme.purple
    ),
    .init(
      icon: "paintpalette.fill",
      title: "Custom themes",
      description: "Personalize Proudly with curated themes that change the look and feel.",
      color: ProudlyTheme.purple
    ),
    .init(
      icon: "heart.fill",
      title: "Proud Moments history",
      description: "Look back at the wins you have completed.",
      color: ProudlyTheme.pink
    ),
    .init(
      icon: "chart.line.uptrend.xyaxis",
      title: "Advanced progress insights",
      description: "Understand your real habit progress without pressure.",
      color: ProudlyTheme.mint
    ),
    .init(
      icon: "calendar",
      title: "Monthly history",
      description: "See your full month at a glance with completion trends.",
      color: ProudlyTheme.mint
    ),
    .init(
      icon: "icloud.fill",
      title: "iCloud sync",
      description: "Keep your habits in sync across your Apple devices.",
      color: ProudlyTheme.blue
    ),
  ]

  private let privacyPolicyURL = URL(string: "https://proudlyhabit.com/privacy")
  private let termsOfUseURL = URL(string: "https://proudlyhabit.com/terms")

  var body: some View {
    NavigationStack {
      ZStack {
        AnimatedAmbientBackground(gradientColors: backgroundGradientColors)

        ScrollView {
          LazyVStack(spacing: 18) {
            heroSection
            reassuranceCard
            benefitsSection
            pricingSection
            footerSection
            #if DEBUG
              debugInfoSection
            #endif
          }
          .padding(.horizontal, 20)
          .padding(.top, 12)
          .padding(.bottom, 8)
        }
      }
      .navigationTitle("Proudly Plus")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button("Close") { dismiss() }
            .tint(theme.activeTheme.accentColor)
        }

        if subscriptionStore.hasProudlyPlus {
          ToolbarItem(placement: .topBarTrailing) {
            Button("Manage") {
              showCustomerCenter = true
            }
            .foregroundStyle(theme.activeTheme.accentColor)
          }
        }
      }
    }
    .task {
      subscriptionStore.configureIfNeeded()
      await subscriptionStore.loadOfferings()
      await subscriptionStore.refreshCustomerInfo()
    }
    .presentCustomerCenter(isPresented: $showCustomerCenter)
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
    .alert(
      subscriptionStore.presentedAlert?.title ?? "Subscription Error",
      isPresented: Binding(
        get: { subscriptionStore.presentedAlert != nil },
        set: { isPresented in
          if !isPresented {
            subscriptionStore.clearAlert()
          }
        }
      ),
      presenting: subscriptionStore.presentedAlert
    ) { _ in
      Button("OK") {
        subscriptionStore.clearAlert()
      }
    } message: { alert in
      Text(alert.message)
    }
  }

  private var heroSection: some View {
    VStack(spacing: 14) {
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
      .padding(.top, 10)

      VStack(spacing: 8) {
        Text("Proudly Plus")
          .font(.system(size: 34, weight: .bold))

        Text(
          subscriptionStore.hasProudlyPlus
            ? "Your premium access is active."
            : "Unlock more room for your small wins."
        )
        .font(.system(size: 17, weight: .medium))
        .foregroundStyle(.secondary)

        Text(
          "Start with 3 free habits. Upgrade when you're ready to track more, personalize Proudly, and see deeper progress."
        )
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)
        .frame(maxWidth: 318)
      }
    }
    .frame(maxWidth: .infinity)
    .padding(.top, 8)
  }

  private var reassuranceCard: some View {
    HStack(spacing: 12) {
      Image(systemName: "heart.fill")
        .font(.system(size: 14, weight: .semibold))
        .foregroundStyle(ProudlyTheme.pink)
        .frame(width: 32, height: 32)
        .background(ProudlyTheme.pink.opacity(0.12), in: Circle())

      Text("You can keep using Proudly for free with up to 3 habits.")
        .font(.footnote.weight(.medium))
        .foregroundStyle(.primary)

      Spacer()
    }
    .padding(14)
    .proudlyGlass(cornerRadius: 20)
  }

  private var benefitsSection: some View {
    LazyVStack(spacing: 12) {
      ForEach(benefits) { benefit in
        BenefitCard(benefit: benefit)
      }
    }
  }

  @ViewBuilder
  private var pricingSection: some View {
    if subscriptionStore.hasProudlyPlus {
      subscribedSection
    } else if subscriptionStore.isLoadingOfferings && subscriptionStore.availablePackages.isEmpty {
      loadingSection
    } else if subscriptionStore.availablePackages.isEmpty {
      unavailableSection
    } else {
      purchaseOptionsSection
    }
  }

  private var loadingSection: some View {
    VStack(spacing: 12) {
      ProgressView()
        .tint(theme.activeTheme.accentColor)
      Text("Loading your plans…")
        .font(.subheadline)
        .foregroundStyle(.secondary)
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 28)
    .proudlyGlass(cornerRadius: 24)
  }

  private var subscribedSection: some View {
    VStack(alignment: .leading, spacing: 14) {
      Label("Proudly Plus is already unlocked.", systemImage: "checkmark.circle.fill")
        .font(.system(size: 17, weight: .semibold))
        .foregroundStyle(theme.activeTheme.accentColor)

      Text("Your habits, themes, and progress are all available now.")
        .font(.subheadline)
        .foregroundStyle(.secondary)

      Button {
        showCustomerCenter = true
      } label: {
        Text("Manage Subscription")
          .font(.system(size: 17, weight: .semibold))
          .foregroundStyle(.white)
          .frame(maxWidth: .infinity)
          .padding(.vertical, 18)
          .background(theme.activeTheme.accentGradient)
          .clipShape(RoundedRectangle(cornerRadius: 22))
      }
      .buttonStyle(.plain)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(20)
    .proudlyGlass(cornerRadius: 24)
  }

  private var unavailableSection: some View {
    VStack(alignment: .leading, spacing: 14) {
      Text("Plans aren't available right now.")
        .font(.system(size: 18, weight: .semibold))

      Text("Please try again in a moment. Your habits are still here.")
        .font(.subheadline)
        .foregroundStyle(.secondary)

      Button {
        Task {
          await subscriptionStore.refreshCustomerInfo()
          await subscriptionStore.loadOfferings()
          if subscriptionStore.availablePackages.isEmpty {
            toastCenter.show(
              message: "Plans still aren't available. Please try again later.",
              symbol: "exclamationmark.triangle.fill"
            )
          }
        }
      } label: {
        Text("Retry")
          .font(.system(size: 16, weight: .semibold))
          .foregroundStyle(theme.activeTheme.accentColor)
      }
      .buttonStyle(.plain)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(20)
    .proudlyGlass(cornerRadius: 24)
  }

  private var purchaseOptionsSection: some View {
    VStack(alignment: .leading, spacing: 14) {
      Text("Choose your plan")
        .font(.system(size: 20, weight: .bold))

      Text("Cancel anytime. Your progress stays yours.")
        .font(.caption)
        .foregroundStyle(.secondary)

      if let yearlyPackage = subscriptionStore.yearlyPackage {
        SubscriptionPackageButton(
          package: yearlyPackage,
          displayName: "Proudly Plus Yearly",
          accentColor: ProudlyTheme.purple,
          secondaryColor: ProudlyTheme.pink,
          highlightStyle: .featured,
          isLoading: subscriptionStore.isPurchaseInProgress,
          action: {
            await purchase(yearlyPackage)
          }
        )
      }

      if let monthlyPackage = subscriptionStore.monthlyPackage {
        SubscriptionPackageButton(
          package: monthlyPackage,
          displayName: "Proudly Plus Monthly",
          accentColor: ProudlyTheme.blue,
          secondaryColor: ProudlyTheme.mint,
          highlightStyle: .standard,
          isLoading: subscriptionStore.isPurchaseInProgress,
          action: {
            await purchase(monthlyPackage)
          }
        )
      }

      if subscriptionStore.monthlyPackage == nil || subscriptionStore.yearlyPackage == nil {
        ForEach(
          subscriptionStore.availablePackages.filter { package in
            package.id != subscriptionStore.monthlyPackage?.id
              && package.id != subscriptionStore.yearlyPackage?.id
          }
        ) { package in
          SubscriptionPackageButton(
            package: package,
            displayName: package.storeProduct.localizedTitle,
            accentColor: ProudlyTheme.purple,
            secondaryColor: ProudlyTheme.blue,
            highlightStyle: .standard,
            isLoading: subscriptionStore.isPurchaseInProgress,
            action: {
              await purchase(package)
            }
          )
        }
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  @ViewBuilder
  private var primaryCTAButton: some View {
    if let primaryPackage = subscriptionStore.yearlyPackage ?? subscriptionStore.monthlyPackage {
      Button {
        Task {
          await purchase(primaryPackage)
        }
      } label: {
        HStack {
          if subscriptionStore.isPurchaseInProgress {
            ProgressView()
              .tint(.white)
          } else {
            Text("Unlock Proudly Plus")
              .font(.system(size: 17, weight: .semibold))
            Spacer()
            Text(primaryCTATrailingCopy(for: primaryPackage))
              .font(.footnote.weight(.medium))
              .foregroundStyle(.white.opacity(0.82))
          }
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background(
          LinearGradient(
            colors: [ProudlyTheme.purple, ProudlyTheme.pink, ProudlyTheme.blue],
            startPoint: .leading,
            endPoint: .trailing
          )
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: ProudlyTheme.purple.opacity(0.22), radius: 22, y: 10)
      }
      .buttonStyle(.plain)
      .disabled(subscriptionStore.isPurchaseInProgress || subscriptionStore.isRestoreInProgress)
    }
  }

  private var footerSection: some View {
    VStack(spacing: 8) {
      HStack(spacing: 16) {
        Group {
          Link("Terms", destination: termsOfUseURL!)
          Link("Privacy", destination: privacyPolicyURL!)
        }
        Button {
          Task {
            let result = await subscriptionStore.restorePurchases()
            switch result {
            case .restoredPlus:
              toastCenter.show(
                message: "Subscription restored", symbol: "arrow.clockwise.circle.fill")
              dismiss()
            case .noActiveSubscription:
              toastCenter.show(
                message: "No active subscription found", symbol: "info.circle.fill")
            case .failed:
              break
            }
          }
        } label: {
          Text(subscriptionStore.isRestoreInProgress ? "Restoring..." : "Restore Purchases")
        }
        .buttonStyle(.plain)
        .disabled(subscriptionStore.isRestoreInProgress || subscriptionStore.isPurchaseInProgress)
      }
      .font(.caption)
      .foregroundStyle(footerForegroundColor)
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 14)
    .padding(.horizontal, 16)
    .background(bottomBarBackground, in: RoundedRectangle(cornerRadius: 18))
    .overlay {
      RoundedRectangle(cornerRadius: 18)
        .strokeBorder(footerBorderColor, lineWidth: 1)
    }
  }

  private func primaryCTATrailingCopy(for package: Package) -> String {
    if package.packageType == .annual
      || package.storeProduct.productIdentifier == RevenueCatConfig.yearlyProductID
    {
      return package.localizedPriceString + " / year"
    }

    if package.packageType == .monthly
      || package.storeProduct.productIdentifier == RevenueCatConfig.monthlyProductID
    {
      return package.localizedPriceString + " / month"
    }

    return package.localizedPriceString
  }

  private func purchase(_ package: Package) async {
    let result = await subscriptionStore.purchase(package)
    switch result {
    case .unlocked:
      toastCenter.show(message: "Proudly Plus unlocked", symbol: "sparkles")
      dismiss()
    case .cancelled:
      break
    case .notUnlocked:
      toastCenter.show(
        message: "Purchase completed, but Plus is not active yet. Please try Restore Purchases.",
        symbol: "exclamationmark.circle.fill"
      )
    case .failed:
      break
    }
  }

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

  private var heroCircleFill: Color {
    colorScheme == .dark ? .white.opacity(0.10) : .white.opacity(0.50)
  }

  private var heroCircleStroke: Color {
    colorScheme == .dark ? .white.opacity(0.14) : .white.opacity(0.45)
  }

  private var bottomBarBackground: some ShapeStyle {
    return AnyShapeStyle(.ultraThinMaterial)
  }

  private var bottomBarDivider: Color {
    colorScheme == .dark ? .white.opacity(0.10) : .white.opacity(0.55)
  }

  private var footerBorderColor: Color {
    colorScheme == .dark ? .white.opacity(0.14) : .white.opacity(0.24)
  }

  private var footerForegroundColor: Color {
    colorScheme == .dark ? .white.opacity(0.82) : .primary.opacity(0.72)
  }

  #if DEBUG
    private var debugInfoSection: some View {
      VStack(alignment: .leading, spacing: 6) {
        Text("DEBUG · Subscription State")
          .font(.caption2.weight(.bold))
          .foregroundStyle(.orange)
        Text("Entitlement ID: \(RevenueCatConfig.proudlyPlusEntitlementID)")
          .font(.caption2.monospaced())
        Text("hasProudlyPlus: \(subscriptionStore.hasProudlyPlus ? "true" : "false")")
          .font(.caption2.monospaced())
        Text("Packages loaded: \(subscriptionStore.availablePackages.count)")
          .font(.caption2.monospaced())
      }
      .padding(12)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
    }
  #endif
}

private struct ProudlyPlusBenefit: Identifiable {
  let id = UUID()
  let icon: String
  let title: String
  let description: String
  let color: Color
}

private struct BenefitCard: View {
  @Environment(\.colorScheme) private var colorScheme
  let benefit: ProudlyPlusBenefit

  var body: some View {
    HStack(alignment: .top, spacing: 14) {
      ZStack {
        RoundedRectangle(cornerRadius: 16)
          .fill(benefit.color.opacity(0.15))
          .frame(width: 48, height: 48)
        Image(systemName: benefit.icon)
          .font(.system(size: 19, weight: .semibold))
          .foregroundStyle(benefit.color)
      }

      VStack(alignment: .leading, spacing: 4) {
        Text(benefit.title)
          .font(.system(size: 16, weight: .semibold))
          .foregroundStyle(.primary)

        Text(benefit.description)
          .font(.subheadline)
          .foregroundStyle(.secondary)
          .fixedSize(horizontal: false, vertical: true)
      }

      Spacer(minLength: 0)
    }
    .padding(16)
    .background {
      RoundedRectangle(cornerRadius: 22)
        .fill(colorScheme == .dark ? .white.opacity(0.04) : .white.opacity(0.12))
    }
    .overlay {
      RoundedRectangle(cornerRadius: 22)
        .strokeBorder(
          colorScheme == .dark ? .white.opacity(0.06) : .white.opacity(0.18), lineWidth: 1)
    }
    .proudlyGlass(cornerRadius: 22)
  }
}

private enum SubscriptionHighlightStyle {
  case standard
  case featured
}

private struct SubscriptionPackageButton: View {
  @Environment(\.colorScheme) private var colorScheme
  let package: Package
  let displayName: String
  let accentColor: Color
  let secondaryColor: Color
  let highlightStyle: SubscriptionHighlightStyle
  let isLoading: Bool
  let action: @Sendable () async -> Void

  private var isFeatured: Bool { highlightStyle == .featured }

  var body: some View {
    Button {
      Task {
        await action()
      }
    } label: {
      VStack(alignment: .leading, spacing: 14) {
        HStack(alignment: .top, spacing: 12) {
          VStack(alignment: .leading, spacing: 4) {
            Text(displayName)
              .font(.system(size: 18, weight: .bold))
              .foregroundStyle(.primary)

            Text(packageSubtitle)
              .font(.subheadline)
              .foregroundStyle(.secondary)
          }

          Spacer()

          if isFeatured {
            Text("Best Value")
              .font(.caption.weight(.bold))
              .foregroundStyle(.white)
              .padding(.horizontal, 10)
              .padding(.vertical, 6)
              .background(
                LinearGradient(
                  colors: [accentColor, secondaryColor],
                  startPoint: .leading,
                  endPoint: .trailing
                )
              )
              .clipShape(Capsule())
          }
        }

        HStack(alignment: .firstTextBaseline, spacing: 8) {
          Text(package.localizedPriceString)
            .font(.system(size: 30, weight: .bold, design: .rounded))
            .foregroundStyle(accentColor)

          Text(billingCaption)
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }

      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(18)
      .background {
        RoundedRectangle(cornerRadius: 24)
          .fill(
            isFeatured
              ? (colorScheme == .dark ? .white.opacity(0.08) : .white.opacity(0.22))
              : (colorScheme == .dark ? .white.opacity(0.04) : .white.opacity(0.08))
          )
      }
      .overlay {
        RoundedRectangle(cornerRadius: 24)
          .strokeBorder(
            isFeatured
              ? LinearGradient(
                colors: [accentColor.opacity(0.55), secondaryColor.opacity(0.35)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
              )
              : LinearGradient(
                colors: [
                  .white.opacity(colorScheme == .dark ? 0.12 : 0.45),
                  .white.opacity(colorScheme == .dark ? 0.04 : 0.18),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
              ),
            lineWidth: isFeatured ? 1.5 : 1
          )
      }
      .contentShape(RoundedRectangle(cornerRadius: 24))
      .proudlyGlass(cornerRadius: 24)
      .shadow(color: isFeatured ? accentColor.opacity(0.12) : .clear, radius: 22, y: 10)
    }
    .buttonStyle(.plain)
    .disabled(isLoading)
    .overlay(alignment: .center) {
      if isLoading {
        ProgressView()
          .padding(18)
      }
    }
  }

  private var packageSubtitle: String {
    if let period = package.storeProduct.subscriptionPeriod {
      return "Billed every \(periodDescription(period))"
    }

    return package.storeProduct.localizedDescription
  }

  private var billingCaption: String {
    if let period = package.storeProduct.subscriptionPeriod {
      return "/ \(periodDescription(period))"
    }

    return ""
  }

  private func periodDescription(_ period: SubscriptionPeriod) -> String {
    let unit: String

    switch period.unit {
    case .day:
      unit = "day"
    case .week:
      unit = "week"
    case .month:
      unit = "month"
    case .year:
      unit = "year"
    @unknown default:
      unit = "period"
    }

    if period.value == 1 {
      return unit
    }

    return "\(period.value) \(unit)s"
  }
}

#Preview {
  ProudlyPlusView()
    .environment(ThemeViewModel())
    .environment(SubscriptionStore())
    .environment(ToastCenter())
    .preferredColorScheme(.light)
}

#Preview("Dark") {
  ProudlyPlusView()
    .environment(ThemeViewModel())
    .environment(SubscriptionStore())
    .environment(ToastCenter())
    .preferredColorScheme(.dark)
}
