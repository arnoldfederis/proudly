//
//  ProudlyTheme.swift
//  Proudly
//
//  Created by Arnolfo Federis on 6/11/26.
//

import SwiftUI

enum ProudlyTheme {
  static let purple = Color(red: 0.655, green: 0.545, blue: 0.980)
  static let pink = Color(red: 0.957, green: 0.455, blue: 0.765)
  static let blue = Color(red: 0.376, green: 0.647, blue: 0.980)
  static let mint = Color(red: 0.204, green: 0.827, blue: 0.600)

  static let backgroundGradient = LinearGradient(
    colors: [
      Color(red: 0.96, green: 0.94, blue: 1.00),
      Color(red: 0.92, green: 0.96, blue: 1.00),
      Color(red: 0.97, green: 0.94, blue: 0.99),
    ],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
  )

  static let purplePinkGradient = LinearGradient(
    colors: [purple, pink],
    startPoint: .leading,
    endPoint: .trailing
  )
}
