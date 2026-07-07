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
    hasEntitlement(in: customerInfo)
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

    let storeKitVersion: StoreKitVersion = {
      #if targetEnvironment(simulator)
        return .storeKit1
      #else
        return .storeKit2
      #endif
    }()

    let configuration = Configuration.Builder(withAPIKey: RevenueCatConfig.apiKey)
      .with(storeKitVersion: storeKitVersion)
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
      if let recoveredResult = await recoverPurchaseResult(from: error) {
        return recoveredResult
      }

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
      if let recoveredResult = await recoverRestoreResult(from: error) {
        return recoveredResult
      }

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

  private func recoverPurchaseResult(from error: Error) async -> PurchaseResult? {
    let nsError = error as NSError

    if nsError.asErrorCode == .purchaseCancelledError {
      return .cancelled
    }

    guard let errorCode = nsError.asErrorCode else { return nil }

    switch errorCode {
    case .productAlreadyPurchasedError, .receiptAlreadyInUseError,
      .receiptInUseByOtherSubscriberError:
      if let customerInfo = await syncCustomerInfoForRecovery(), hasEntitlement(in: customerInfo) {
        toastCenter?.show(
          message: "Proudly Plus is already active on this account.",
          symbol: "checkmark.circle.fill"
        )
        return .unlocked
      }

      presentedAlert = SubscriptionAlert(
        title: "Subscription already active",
        message:
          "This Apple ID already appears to have a Proudly Plus subscription. Try Restore Purchases or manage it from Apple's subscription settings."
      )
      return .failed

    case .invalidReceiptError, .missingReceiptFileError:
      if let customerInfo = await syncCustomerInfoForRecovery(), hasEntitlement(in: customerInfo) {
        toastCenter?.show(
          message: "Proudly Plus is already active on this account.",
          symbol: "checkmark.circle.fill"
        )
        return .unlocked
      }

      return nil

    default:
      return nil
    }
  }

  private func recoverRestoreResult(from error: Error) async -> RestoreResult? {
    let nsError = error as NSError

    guard let errorCode = nsError.asErrorCode else { return nil }

    switch errorCode {
    case .invalidReceiptError, .missingReceiptFileError,
      .receiptAlreadyInUseError, .receiptInUseByOtherSubscriberError,
      .productAlreadyPurchasedError:
      if let customerInfo = await syncCustomerInfoForRecovery(), hasEntitlement(in: customerInfo) {
        return .restoredPlus
      }

      return .noActiveSubscription

    default:
      return nil
    }
  }

  private func syncCustomerInfoForRecovery() async -> CustomerInfo? {
    do {
      let syncedCustomerInfo = try await Purchases.shared.syncPurchases()
      customerInfo = syncedCustomerInfo
      return syncedCustomerInfo
    } catch {
      do {
        let refreshedCustomerInfo = try await Purchases.shared.customerInfo()
        customerInfo = refreshedCustomerInfo
        return refreshedCustomerInfo
      } catch {
        return customerInfo
      }
    }
  }

  private func hasEntitlement(in customerInfo: CustomerInfo?) -> Bool {
    guard let customerInfo else { return false }

    if customerInfo.entitlements[RevenueCatConfig.proudlyPlusEntitlementID]?.isActive == true {
      return true
    }

    return !customerInfo.activeSubscriptions.isDisjoint(with: plusProductIdentifiers)
  }

  private var plusProductIdentifiers: Set<String> {
    [
      RevenueCatConfig.monthlyProductID,
      RevenueCatConfig.yearlyProductID,
    ]
  }

  private func presentError(title: String, error: Error) {
    let message = (error as NSError).localizedDescription
    presentedAlert = SubscriptionAlert(title: title, message: message)
  }
}
