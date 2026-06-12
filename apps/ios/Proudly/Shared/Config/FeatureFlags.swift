//
//  FeatureFlags.swift
//  Proudly
//
//  Created by Arnolfo Federis on 6/12/26.
//

enum FeatureFlags {
  /// Set to true to expose the Theme settings row in Profile.
  /// Safe to flip to true once Proudly Plus is ready to ship.
  static let showThemeSettings: Bool = true

  /// Keeps the theme system active for internal previews and screens
  /// even when the settings row is hidden from users.
  static let enableThemePreview: Bool = true
}
