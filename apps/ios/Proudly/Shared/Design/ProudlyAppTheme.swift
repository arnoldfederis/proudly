//
//  ProudlyAppTheme.swift
//  Proudly
//
//  Created by Arnolfo Federis on 6/12/26.
//

import SwiftUI

enum ProudlyAppTheme: String, CaseIterable, Identifiable {
  case liquidGlass = "Liquid Glass"
  case lavenderDream = "Lavender Dream"
  case oceanBreeze = "Ocean Breeze"
  case mintGarden = "Mint Garden"
  case sunsetGlow = "Sunset Glow"
  case midnightCalm = "Midnight Calm"

  var id: String { rawValue }
  var displayName: String {
    self == .liquidGlass ? "Default" : rawValue
  }

  var subtitle: String {
    switch self {
    case .liquidGlass: return "iOS Default"
    case .lavenderDream: return "Soft purple hues"
    case .oceanBreeze: return "Cool blue tones"
    case .mintGarden: return "Fresh greens"
    case .sunsetGlow: return "Warm amber & rose"
    case .midnightCalm: return "Deep dark palette"
    }
  }

  var isPlusOnly: Bool { self != .liquidGlass }

  var accentColor: Color {
    switch self {
    case .liquidGlass: return ProudlyTheme.purple
    case .lavenderDream: return Color(red: 0.72, green: 0.55, blue: 0.98)
    case .oceanBreeze: return ProudlyTheme.blue
    case .mintGarden: return ProudlyTheme.mint
    case .sunsetGlow: return Color(red: 0.98, green: 0.60, blue: 0.35)
    case .midnightCalm: return Color(red: 0.45, green: 0.50, blue: 0.90)
    }
  }

  var secondaryColor: Color {
    switch self {
    case .liquidGlass: return ProudlyTheme.pink
    case .lavenderDream: return ProudlyTheme.pink
    case .oceanBreeze: return ProudlyTheme.mint
    case .mintGarden: return ProudlyTheme.blue
    case .sunsetGlow: return Color(red: 0.98, green: 0.40, blue: 0.55)
    case .midnightCalm: return Color(red: 0.55, green: 0.40, blue: 0.90)
    }
  }

  var backgroundGradient: LinearGradient {
    switch self {
    case .liquidGlass:
      return LinearGradient(colors: [.clear], startPoint: .top, endPoint: .bottom)
    case .lavenderDream:
      return LinearGradient(
        colors: [
          Self.adaptive(light: (0.94, 0.91, 1.00), dark: (0.09, 0.07, 0.16)),
          Self.adaptive(light: (0.97, 0.92, 0.99), dark: (0.11, 0.08, 0.19)),
          Self.adaptive(light: (0.95, 0.90, 1.00), dark: (0.10, 0.07, 0.17)),
        ],
        startPoint: .topLeading, endPoint: .bottomTrailing
      )
    case .oceanBreeze:
      return LinearGradient(
        colors: [
          Self.adaptive(light: (0.88, 0.95, 1.00), dark: (0.06, 0.09, 0.18)),
          Self.adaptive(light: (0.90, 0.97, 0.98), dark: (0.07, 0.11, 0.20)),
          Self.adaptive(light: (0.88, 0.93, 1.00), dark: (0.06, 0.09, 0.20)),
        ],
        startPoint: .topLeading, endPoint: .bottomTrailing
      )
    case .mintGarden:
      return LinearGradient(
        colors: [
          Self.adaptive(light: (0.88, 0.98, 0.93), dark: (0.06, 0.13, 0.09)),
          Self.adaptive(light: (0.91, 1.00, 0.96), dark: (0.07, 0.15, 0.11)),
          Self.adaptive(light: (0.90, 0.98, 0.94), dark: (0.06, 0.14, 0.10)),
        ],
        startPoint: .topLeading, endPoint: .bottomTrailing
      )
    case .sunsetGlow:
      return LinearGradient(
        colors: [
          Self.adaptive(light: (1.00, 0.93, 0.88), dark: (0.15, 0.07, 0.07)),
          Self.adaptive(light: (1.00, 0.90, 0.92), dark: (0.14, 0.06, 0.09)),
          Self.adaptive(light: (1.00, 0.94, 0.88), dark: (0.15, 0.07, 0.07)),
        ],
        startPoint: .topLeading, endPoint: .bottomTrailing
      )
    case .midnightCalm:
      // Always dark — ignores system appearance by design.
      return LinearGradient(
        colors: [
          Color(red: 0.08, green: 0.08, blue: 0.16),
          Color(red: 0.10, green: 0.10, blue: 0.22),
          Color(red: 0.14, green: 0.09, blue: 0.18),
        ],
        startPoint: .topLeading, endPoint: .bottomTrailing
      )
    }
  }

  var accentGradient: LinearGradient {
    if self == .liquidGlass {
      return LinearGradient(
        colors: [accentColor, accentColor],
        startPoint: .leading, endPoint: .trailing
      )
    }

    return LinearGradient(
      colors: [accentColor, secondaryColor],
      startPoint: .leading, endPoint: .trailing
    )
  }

  // Resolves a color at render time based on the current color scheme.
  private static func adaptive(light: (Double, Double, Double), dark: (Double, Double, Double))
    -> Color
  {
    Color(
      uiColor: UIColor { traits in
        let (r, g, b) = traits.userInterfaceStyle == .dark ? dark : light
        return UIColor(red: r, green: g, blue: b, alpha: 1)
      })
  }
}
