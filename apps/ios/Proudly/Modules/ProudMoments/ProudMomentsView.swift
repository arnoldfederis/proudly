//
//  ProudMomentsView.swift
//  Proudly
//
//  Created by Arnolfo Federis on 6/11/26.
//

import SwiftUI

struct ProudMomentsView: View {
  @Environment(ThemeViewModel.self) private var theme
  @Environment(HabitRepository.self) private var repository

  private var grouped: [(String, [ProudMoment])] {
    var groups: [String: [ProudMoment]] = [:]
    var keyOrder: [String] = []

    for moment in repository.proudMoments {
      let key = sectionLabel(for: moment.date)
      if groups[key] == nil {
        keyOrder.append(key)
        groups[key] = []
      }
      groups[key]?.append(moment)
    }

    return keyOrder.map { ($0, groups[$0] ?? []) }
  }

  var body: some View {
    ZStack {
      theme.activeTheme.backgroundGradient.ignoresSafeArea()

      if repository.proudMoments.isEmpty {
        emptyState
      } else {
        ScrollView {
          LazyVStack(spacing: 0) {
            ForEach(grouped, id: \.0) { section, items in
              LazyVStack(alignment: .leading, spacing: 10) {
                Text(section)
                  .font(.system(size: 13, weight: .semibold))
                  .foregroundStyle(.secondary)
                  .padding(.horizontal, 20)
                  .padding(.top, 24)
                  .padding(.bottom, 2)

                ForEach(items) { moment in
                  ProudMomentCard(moment: moment)
                    .padding(.horizontal, 20)
                }
              }
            }
            Spacer(minLength: 80)
          }
        }
      }
    }
    .navigationTitle("Proud Moments")
    .navigationBarTitleDisplayMode(.large)
    .tint(theme.activeTheme.accentColor)
    .toolbarVisibility(.hidden, for: .tabBar)
  }

  private var emptyState: some View {
    VStack(spacing: 12) {
      Image(systemName: "star.fill")
        .font(.system(size: 40))
        .foregroundStyle(theme.activeTheme.accentColor)
      Text("No moments yet")
        .font(.headline)
      Text("Complete a habit to create your first proud moment.")
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 40)
    }
  }

  private func sectionLabel(for date: Date) -> String {
    if Calendar.current.isDateInToday(date) { return "Today" }
    if Calendar.current.isDateInYesterday(date) { return "Yesterday" }
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM d"
    return formatter.string(from: date)
  }
}

struct ProudMomentCard: View {
  let moment: ProudMoment
  @State private var isFavorited = false

  var body: some View {
    HStack(spacing: 14) {
      HabitIconView(icon: moment.icon, color: moment.color, fontSize: 18, circleSize: 46)

      VStack(alignment: .leading, spacing: 4) {
        Text(moment.habitName)
          .font(.system(size: 15, weight: .semibold))
        Text(moment.message)
          .font(.caption)
          .foregroundStyle(.secondary)
          .lineLimit(2)
        HStack(spacing: 4) {
          Image(systemName: "flame.fill")
            .font(.caption2)
            .foregroundStyle(ProudlyTheme.pink)
          Text(moment.streak.proudlyStreakLabel)
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
      }

      Spacer()

      Button {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
          isFavorited.toggle()
          Haptics.impact(.light)
        }
      } label: {
        Image(systemName: isFavorited ? "heart.fill" : "heart")
          .foregroundStyle(isFavorited ? ProudlyTheme.pink : .secondary)
          .font(.system(size: 20))
      }
      .buttonStyle(.plain)
    }
    .padding(16)
    .proudlyGlass(cornerRadius: 18)
  }
}

#Preview {
  NavigationStack {
    ProudMomentsView()
  }
  .environment(ThemeViewModel())
  .environment(HabitRepository.preview)
}
