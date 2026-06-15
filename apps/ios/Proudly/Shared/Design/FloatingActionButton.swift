//
//  FloatingActionButton.swift
//  Proudly
//
//  Created by Arnolfo Federis on 6/12/26.
//

import SwiftUI

struct FloatingActionButton: View {
  let systemImage: String
  let color: Color
  let action: () -> Void

  @State private var symbolTrigger = 0

  var body: some View {
    Button {
      symbolTrigger += 1
      Haptics.selection()
      action()
    } label: {
      Image(systemName: systemImage)
        .font(.title2.bold())
        .foregroundStyle(.white)
        .symbolEffect(.bounce.byLayer, value: symbolTrigger)
        .frame(width: 52, height: 52)
        .background(color, in: Circle())
    }
    .buttonStyle(FloatingActionButtonStyle())
  }
}

private struct FloatingActionButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .scaleEffect(configuration.isPressed ? 0.92 : 1)
      .brightness(configuration.isPressed ? -0.05 : 0)
      .animation(.spring(response: 0.22, dampingFraction: 0.72), value: configuration.isPressed)
  }
}
