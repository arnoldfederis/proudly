import SwiftUI

struct AnimatedAmbientBackground: View {
  let gradientColors: [Color]

  @State private var animateOrbs = false

  var body: some View {
    ZStack {
      LinearGradient(
        colors: gradientColors,
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
      .ignoresSafeArea()

      ambientOrb(
        color: ProudlyTheme.purple.opacity(0.32),
        size: 320,
        blurRadius: 30,
        baseOffset: CGSize(width: -120, height: -320),
        animatedOffset: CGSize(width: -140, height: 104),
        restingScale: 0.92,
        animatedScale: 1.22,
        restingOpacity: 0.88,
        animatedOpacity: 1.0,
        restingRotation: -10,
        animatedRotation: 14,
        animation: .easeInOut(duration: 4.8)
          .delay(0.1)
          .repeatForever(autoreverses: true)
      )

      ambientOrb(
        color: ProudlyTheme.blue.opacity(0.28),
        size: 270,
        blurRadius: 24,
        baseOffset: CGSize(width: 140, height: -180),
        animatedOffset: CGSize(width: 98, height: -132),
        restingScale: 0.93,
        animatedScale: 1.18,
        restingOpacity: 0.84,
        animatedOpacity: 0.98,
        restingRotation: 8,
        animatedRotation: -14,
        animation: .easeInOut(duration: 5.4)
          .delay(0.35)
          .repeatForever(autoreverses: true)
      )

      ambientOrb(
        color: ProudlyTheme.pink.opacity(0.26),
        size: 270,
        blurRadius: 24,
        baseOffset: CGSize(width: 120, height: 220),
        animatedOffset: CGSize(width: -118, height: -88),
        restingScale: 0.91,
        animatedScale: 1.2,
        restingOpacity: 0.80,
        animatedOpacity: 0.96,
        restingRotation: -12,
        animatedRotation: 12,
        animation: .easeInOut(duration: 5.0)
          .delay(0.2)
          .repeatForever(autoreverses: true)
      )
    }
    .ignoresSafeArea()
    .saturation(1.15)
    .contrast(1.08)
    .onAppear {
      animateOrbs = true
    }
  }

  private func ambientOrb(
    color: Color,
    size: CGFloat,
    blurRadius: CGFloat,
    baseOffset: CGSize,
    animatedOffset: CGSize,
    restingScale: CGFloat,
    animatedScale: CGFloat,
    restingOpacity: Double,
    animatedOpacity: Double,
    restingRotation: Double,
    animatedRotation: Double,
    animation: Animation
  ) -> some View {
    Circle()
      .fill(color)
      .frame(width: size, height: size)
      .blur(radius: blurRadius)
      .opacity(animateOrbs ? animatedOpacity : restingOpacity)
      .scaleEffect(animateOrbs ? animatedScale : restingScale)
      .rotationEffect(.degrees(animateOrbs ? animatedRotation : restingRotation))
      .offset(
        x: animateOrbs ? baseOffset.width + animatedOffset.width : baseOffset.width,
        y: animateOrbs ? baseOffset.height + animatedOffset.height : baseOffset.height
      )
      .animation(animation, value: animateOrbs)
  }
}

#Preview() {
  AnimatedAmbientBackground(gradientColors: [
    Color(red: 0.98, green: 0.95, blue: 1.0),
    Color(red: 0.93, green: 0.97, blue: 1.0),
    Color(red: 0.95, green: 0.99, blue: 0.97),
  ])
  .preferredColorScheme(.light)
}

#Preview("Dark") {
  AnimatedAmbientBackground(gradientColors: [
    Color(red: 0.10, green: 0.09, blue: 0.16),
    Color(red: 0.09, green: 0.13, blue: 0.18),
    Color(red: 0.10, green: 0.14, blue: 0.13),
  ])
  .preferredColorScheme(.dark)
}
