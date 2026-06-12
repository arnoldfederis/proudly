//
//  ThemedGlassCard.swift
//  Proudly
//
//  Created by Arnolfo Federis on 6/12/26.
//

import SwiftUI

struct ThemedGlassCard<Content: View>: View {
  private let cornerRadius: CGFloat
  private let themeViewModel: ThemeViewModel?
  private let content: Content

  init(
    cornerRadius: CGFloat = 22,
    themeViewModel: ThemeViewModel? = nil,
    @ViewBuilder content: () -> Content
  ) {
    self.cornerRadius = cornerRadius
    self.themeViewModel = themeViewModel
    self.content = content()
  }

  private var accentColor: Color {
    themeViewModel?.activeTheme.accentColor ?? ProudlyTheme.purple
  }

  var body: some View {
    content
      .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius))
      .overlay(
        RoundedRectangle(cornerRadius: cornerRadius)
          .stroke(Color.white.opacity(0.25), lineWidth: 1)
      )
      .shadow(color: accentColor.opacity(0.10), radius: 14, x: 0, y: 4)
  }
}
