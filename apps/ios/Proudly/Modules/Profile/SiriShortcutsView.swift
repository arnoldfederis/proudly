//
//  SiriShortcutsView.swift
//  Proudly
//

import SwiftUI

struct SiriShortcutsView: View {
  @Environment(ThemeViewModel.self) private var theme

  var body: some View {
    ZStack {
      theme.activeTheme.backgroundGradient.ignoresSafeArea()

      ScrollView {
        LazyVStack(spacing: 20) {
          headerCard
          quickActionsCard
          phrasesCard
          Spacer(minLength: 80)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
      }
    }
    .navigationTitle("Siri Shortcuts")
    .navigationBarTitleDisplayMode(.large)
    .toolbar(.hidden, for: .tabBar)
  }

  private var headerCard: some View {
    VStack(spacing: 14) {
      ZStack {
        Circle()
          .fill(theme.activeTheme.accentGradient)
          .frame(width: 72, height: 72)
        Image(systemName: "waveform")
          .font(.system(size: 30, weight: .semibold))
          .foregroundStyle(.white)
      }

      VStack(spacing: 6) {
        Text("Hey Siri, talk to Proudly")
          .font(.system(size: 20, weight: .bold))
          .multilineTextAlignment(.center)
        Text("Log habits, start focus timers, and open Today — all hands-free.")
          .font(.subheadline)
          .foregroundStyle(.secondary)
          .multilineTextAlignment(.center)
      }
    }
    .frame(maxWidth: .infinity)
    .padding(24)
    .proudlyGlass()
  }

  private var quickActionsCard: some View {
    VStack(alignment: .leading, spacing: 0) {
      sectionHeader("Quick Actions")

      VStack(spacing: 0) {
        QuickActionRow(
          icon: "checkmark.circle.fill",
          color: ProudlyTheme.mint,
          title: "Open Today",
          subtitle: "Jump straight to today's checklist"
        )
        Divider().padding(.leading, 56).opacity(0.4)
        QuickActionRow(
          icon: "checkmark.seal.fill",
          color: ProudlyTheme.pink,
          title: "Complete a Habit",
          subtitle: "Mark any habit done by name"
        )
        Divider().padding(.leading, 56).opacity(0.4)
        QuickActionRow(
          icon: "timer",
          color: ProudlyTheme.blue,
          title: "Start Focus Timer",
          subtitle: "Begin a focused session for a habit"
        )
        Divider().padding(.leading, 56).opacity(0.4)
        QuickActionRow(
          icon: "list.bullet.circle.fill",
          color: ProudlyTheme.purple,
          title: "Open a Habit",
          subtitle: "Jump to one habit's detail view"
        )
      }
      .proudlyGlass()
    }
  }

  private var phrasesCard: some View {
    VStack(alignment: .leading, spacing: 0) {
      sectionHeader("Try saying")

      VStack(alignment: .leading, spacing: 10) {
        PhraseBubble(text: "Hey Siri, open Today in Proudly")
        PhraseBubble(text: "Hey Siri, complete reading in Proudly")
        PhraseBubble(text: "Hey Siri, start my programming habit in Proudly")

        Text("Add your own phrases in the Shortcuts app.")
          .font(.caption)
          .foregroundStyle(.secondary)
          .padding(.top, 6)
      }
      .padding(16)
      .frame(maxWidth: .infinity, alignment: .leading)
      .proudlyGlass()
    }
  }

  private func sectionHeader(_ title: String) -> some View {
    Text(title.uppercased())
      .font(.system(size: 12, weight: .semibold))
      .foregroundStyle(.secondary)
      .tracking(0.6)
      .padding(.leading, 4)
      .padding(.bottom, 8)
  }
}

private struct QuickActionRow: View {
  let icon: String
  let color: Color
  let title: String
  let subtitle: String

  var body: some View {
    HStack(spacing: 12) {
      ZStack {
        RoundedRectangle(cornerRadius: 8)
          .fill(color.opacity(0.15))
          .frame(width: 34, height: 34)
        Image(systemName: icon)
          .font(.system(size: 14))
          .foregroundStyle(color)
      }

      VStack(alignment: .leading, spacing: 2) {
        Text(title).font(.system(size: 16, weight: .medium))
        Text(subtitle)
          .font(.caption)
          .foregroundStyle(.secondary)
      }

      Spacer()
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(14)
  }
}

private struct PhraseBubble: View {
  @Environment(ThemeViewModel.self) private var theme
  let text: String

  var body: some View {
    HStack(alignment: .top, spacing: 10) {
      Image(systemName: "quote.opening")
        .font(.system(size: 12, weight: .bold))
        .foregroundStyle(theme.activeTheme.accentColor)
        .padding(.top, 3)
      Text(text)
        .font(.system(size: 15, weight: .medium))
        .italic()
        .foregroundStyle(.primary)
        .fixedSize(horizontal: false, vertical: true)
      Spacer(minLength: 0)
    }
    .padding(.horizontal, 14)
    .padding(.vertical, 10)
    .background(theme.activeTheme.accentColor.opacity(0.10))
    .clipShape(RoundedRectangle(cornerRadius: 14))
  }
}

#Preview {
  NavigationStack {
    SiriShortcutsView()
      .environment(ThemeViewModel())
  }
}
