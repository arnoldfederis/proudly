//
//  RevenueCatConfig.swift
//  Proudly
//
//  Created by Arnolfo Federis on 6/13/26.
//

import Foundation

enum RevenueCatConfig {
  static var apiKey: String {
    guard
      let apiKey = Bundle.main.object(forInfoDictionaryKey: "RevenueCatAPIKey") as? String
    else {
      fatalError("Missing RevenueCatAPIKey in Info.plist.")
    }

    let trimmedApiKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
    guard
      !trimmedApiKey.isEmpty,
      trimmedApiKey != "__MISSING_REVENUECAT_API_KEY__",
      !trimmedApiKey.hasPrefix("$(")
    else {
      fatalError(
        "RevenueCatAPIKey is not configured. Set REVENUECAT_API_KEY in Proudly/Configurations/Secrets.xcconfig."
      )
    }

    return trimmedApiKey
  }

  /// This identifier must match the entitlement identifier in RevenueCat.
  static let proudlyPlusEntitlementID = "Proudly Plus"

  /// These identifiers should match the App Store Connect / RevenueCat product IDs.
  static let monthlyProductID = "monthly"
  static let yearlyProductID = "yearly"
}
