//
//  ProudMomentsView.swift
//  Proudly
//
//  Created by Arnolfo Federis on 6/11/26.
//

import SwiftUI

struct ProudMomentsView: View {
  @Environment(ThemeViewModel.self) private var theme
  private let moments = ProudMoment.samples

  private var grouped: [(String, [ProudMoment])] {
    var groups: [String: [ProudMoment]] = [:]
    var keyOrder: [String] = []

    for moment in moments {
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

      ScrollView {
        VStack(spacing: 0) {
          ForEach(grouped, id: \.0) { section, items in
            VStack(alignment: .leading, spacing: 10) {
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
    .navigationTitle("Proud Moments")
    .navigationBarTitleDisplayMode(.large)
    .tint(theme.activeTheme.accentColor)
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
      ZStack {
        Circle()
          .fill(ProudlyTheme.purple.opacity(0.15))
          .frame(width: 46, height: 46)
        Image(systemName: moment.icon)
          .font(.system(size: 18))
          .foregroundStyle(ProudlyTheme.purple)
      }

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
          Text("\(moment.streak)-day streak")
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
}
