//
//  SubscriptionStore.swift
//  Proudly
//
//  Created by Arnolfo Federis on 6/13/26.
//

import Foundation
import Observation
import RevenueCat

enum PurchaseResult {
  case unlocked
  case cancelled
  case notUnlocked
  case failed
}

enum RestoreResult {
  case restoredPlus
  case noActiveSubscription
  case failed
}

@MainActor
@Observable
final class SubscriptionStore {
  struct SubscriptionAlert: Identifiable {
    let id = UUID()
    let title: String
    let message: String
  }

  private(set) var customerInfo: CustomerInfo?
  private(set) var currentOffering: Offering?
  private(set) var isConfigured = false
  private(set) var isLoadingOfferings = false
  private(set) var isRefreshingCustomerInfo = false
  private(set) var isPurchaseInProgress = false
  private(set) var isRestoreInProgress = false
  var presentedAlert: SubscriptionAlert?

  private let toastCenter: ToastCenter?
  private var customerInfoUpdatesTask: Task<Void, Never>?

  init(toastCenter: ToastCenter? = nil) {
    self.toastCenter = toastCenter
  }

  var hasProudlyPlus: Bool {
    customerInfo?.entitlements[RevenueCatConfig.proudlyPlusEntitlementID]?.isActive == true
  }

  var availablePackages: [Package] {
    currentOffering?.availablePackages ?? []
  }

  var monthlyPackage: Package? {
    package(
      matchingProductID: RevenueCatConfig.monthlyProductID,
      packageType: .monthly
    )
  }

  var yearlyPackage: Package? {
    package(
      matchingProductID: RevenueCatConfig.yearlyProductID,
      packageType: .annual
    )
  }

  func configureIfNeeded() {
    guard !isConfigured else { return }

    #if DEBUG
      Purchases.logLevel = .debug
    #else
      Purchases.logLevel = .info
    #endif

    let configuration = Configuration.Builder(withAPIKey: RevenueCatConfig.apiKey)
      .with(storeKitVersion: StoreKitVersion.storeKit2)
      .build()

    Purchases.configure(with: configuration)
    isConfigured = true

    observeCustomerInfoUpdates()

    Task {
      await refresh()
    }
  }

  func refresh() async {
    await refreshCustomerInfo()
    await loadOfferings()
  }

  func refreshCustomerInfo() async {
    guard isConfigured, !isRefreshingCustomerInfo else { return }

    isRefreshingCustomerInfo = true
    defer { isRefreshingCustomerInfo = false }

    do {
      customerInfo = try await Purchases.shared.customerInfo()
    } catch {
      presentError(
        title: "Couldn't refresh subscription",
        error: error
      )
    }
  }

  func loadOfferings() async {
    guard isConfigured, !isLoadingOfferings else { return }

    isLoadingOfferings = true
    defer { isLoadingOfferings = false }

    do {
      currentOffering = try await Purchases.shared.offerings().current
    } catch {
      presentError(
        title: "Couldn't load subscriptions",
        error: error
      )
    }
  }

  @discardableResult
  func purchase(_ package: Package) async -> PurchaseResult {
    guard isConfigured, !isPurchaseInProgress else { return .failed }

    isPurchaseInProgress = true
    defer { isPurchaseInProgress = false }

    do {
      let (_, updatedCustomerInfo, userCancelled) = try await Purchases.shared.purchase(
        package: package
      )

      guard !userCancelled else { return .cancelled }

      customerInfo = updatedCustomerInfo
      return hasProudlyPlus ? .unlocked : .notUnlocked
    } catch {
      presentError(
        title: "Purchase failed",
        error: error
      )
      return .failed
    }
  }

  @discardableResult
  func restorePurchases() async -> RestoreResult {
    guard isConfigured, !isRestoreInProgress else { return .failed }

    isRestoreInProgress = true
    defer { isRestoreInProgress = false }

    do {
      customerInfo = try await Purchases.shared.restorePurchases()
      return hasProudlyPlus ? .restoredPlus : .noActiveSubscription
    } catch {
      presentError(
        title: "Restore failed",
        error: error
      )
      return .failed
    }
  }

  func clearAlert() {
    presentedAlert = nil
  }

  private func observeCustomerInfoUpdates() {
    guard customerInfoUpdatesTask == nil else { return }

    customerInfoUpdatesTask = Task { [weak self] in
      guard let self else { return }

      for await updatedCustomerInfo in Purchases.shared.customerInfoStream {
        await MainActor.run {
          self.customerInfo = updatedCustomerInfo
        }
      }
    }
  }

  private func package(
    matchingProductID productID: String,
    packageType: PackageType
  ) -> Package? {
    if let exactMatch = availablePackages.first(where: {
      $0.storeProduct.productIdentifier == productID || $0.identifier == productID
    }) {
      return exactMatch
    }

    return availablePackages.first(where: { $0.packageType == packageType })
  }

  private func presentError(title: String, error: Error) {
    let message = (error as NSError).localizedDescription
    presentedAlert = SubscriptionAlert(title: title, message: message)
  }
}
