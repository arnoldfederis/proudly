//
//  SFSymbolPickerView.swift
//  Proudly
//
//  Created by Arnolfo Federis on 6/16/26.
//

import SwiftUI

private enum SFSymbolCategory: String, CaseIterable, Identifiable {
  case wellness
  case movement
  case focus
  case home
  case objects
  case nature
  case routines
  case health

  var id: String { rawValue }

  var title: String {
    switch self {
    case .wellness:
      return "Wellness"
    case .movement:
      return "Movement"
    case .focus:
      return "Focus"
    case .home:
      return "Home"
    case .objects:
      return "Objects"
    case .nature:
      return "Nature"
    case .routines:
      return "Routines"
    case .health:
      return "Health"
    }
  }

  var symbols: [String] {
    switch self {
    case .wellness:
      return [
        "heart.fill",
        "drop.fill",
        "leaf.fill",
        "moon.stars.fill",
        "sparkles",
        "flame.fill",
        "hands.clap.fill",
        "face.smiling.fill",
        "sun.max.fill",
        "figure.mind.and.body",
        "bed.double.fill",
        "cup.and.saucer.fill",
      ]
    case .movement:
      return [
        "figure.walk",
        "figure.run",
        "dumbbell.fill",
        "bicycle",
        "figure.cooldown",
        "figure.strengthtraining.traditional",
        "figure.yoga",
        "figure.pickleball",
        "figure.hiking",
        "figure.dance",
        "figure.outdoor.cycle",
        "figure.pool.swim",
      ]
    case .focus:
      return [
        "book.fill",
        "pencil",
        "brain.head.profile",
        "timer",
        "checklist",
        "target",
        "lightbulb.fill",
        "graduationcap.fill",
        "document.fill",
        "note.text",
        "bookmark.fill",
        "hourglass",
      ]
    case .home:
      return [
        "house.fill",
        "fork.knife",
        "bed.double.fill",
        "washer.fill",
        "shower.fill",
        "lamp.table.fill",
        "sofa.fill",
        "refrigerator.fill",
        "dishwasher.fill",
        "chair.lounge.fill",
        "cabinet.fill",
        "toilet.fill",
      ]
    case .objects:
      return [
        "cup.and.saucer.fill",
        "backpack.fill",
        "laptopcomputer",
        "headphones",
        "camera.fill",
        "briefcase.fill",
        "bag.fill",
        "cart.fill",
        "waterbottle.fill",
        "fork.knife.circle.fill",
        "book.closed.fill",
        "pill.fill",
      ]
    case .nature:
      return [
        "sun.max.fill",
        "cloud.rain.fill",
        "tree.fill",
        "bird.fill",
        "mountain.2.fill",
        "globe.americas.fill",
        "water.waves",
        "wind",
        "snowflake",
        "hurricane",
        "tornado",
        "sun.horizon.fill",
      ]
    case .routines:
      return [
        "calendar",
        "alarm.fill",
        "bell.fill",
        "medal.fill",
        "bookmark.fill",
        "list.bullet.clipboard.fill",
        "checkmark.seal.fill",
        "repeat",
        "calendar.badge.clock",
        "timer.circle.fill",
        "list.clipboard.fill",
        "flag.checkered",
      ]
    case .health:
      return [
        "cross.case.fill",
        "pills.fill",
        "stethoscope",
        "lungs.fill",
        "heart.text.square.fill",
        "cross.vial.fill",
        "bandage.fill",
        "apple.meditate",
        "bed.double.circle.fill",
        "allergens.fill",
        "hare.fill",
        "waveform.path.ecg",
      ]
    }
  }
}

struct SFSymbolPickerView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(ThemeViewModel.self) private var theme

  @Binding var selectedSymbol: String
  let symbolTint: Color
  let excludedSymbols: Set<String>
  @State private var selectedCategory: SFSymbolCategory = .wellness
  @State private var isEmojiEntryPresented = false

  init(
    selectedSymbol: Binding<String>,
    symbolTint: Color,
    excludedSymbols: Set<String> = []
  ) {
    _selectedSymbol = selectedSymbol
    self.symbolTint = symbolTint
    self.excludedSymbols = excludedSymbols
  }

  private var availableSymbols: [String] {
    selectedCategory.symbols.filter { !excludedSymbols.contains($0) }
  }

  var body: some View {
    NavigationStack {
      ZStack {
        theme.activeTheme.backgroundGradient.ignoresSafeArea()

        ScrollView {
          VStack(alignment: .leading, spacing: 20) {
            Text("Category")
              .font(.subheadline)
              .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
              LazyHStack(spacing: 10) {
                ForEach(SFSymbolCategory.allCases) { category in
                  Button {
                    selectedCategory = category
                    Haptics.selection()
                  } label: {
                    Text(category.title)
                      .font(.system(size: 14, weight: .semibold))
                      .foregroundStyle(selectedCategory == category ? .white : .primary)
                      .padding(.horizontal, 14)
                      .padding(.vertical, 10)
                      .background(
                        selectedCategory == category
                          ? AnyShapeStyle(theme.activeTheme.accentGradient)
                          : AnyShapeStyle(Color.primary.opacity(0.08))
                      )
                      .clipShape(Capsule())
                  }
                  .buttonStyle(.plain)
                }

                Button {
                  Haptics.selection()
                  isEmojiEntryPresented = true
                } label: {
                  Text("Type Emoji")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(selectedSymbol.isHabitEmoji ? .white : .primary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                      selectedSymbol.isHabitEmoji
                        ? AnyShapeStyle(theme.activeTheme.accentGradient)
                        : AnyShapeStyle(Color.primary.opacity(0.08))
                    )
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
              }
            }

            Text("Symbol")
              .font(.subheadline)
              .foregroundStyle(.secondary)

            LazyVGrid(
              columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4),
              spacing: 12
            ) {
              ForEach(availableSymbols, id: \.self) { symbol in
                Button {
                  selectedSymbol = symbol
                  Haptics.selection()
                  dismiss()
                } label: {
                  ZStack {
                    RoundedRectangle(cornerRadius: 22)
                      .fill(
                        selectedSymbol == symbol
                          ? symbolTint.opacity(0.16) : .clear
                      )
                      .overlay {
                        RoundedRectangle(cornerRadius: 22)
                          .stroke(
                            selectedSymbol == symbol
                              ? symbolTint : Color.white.opacity(0.12),
                            lineWidth: 1.2
                          )
                      }

                    Circle()
                      .fill(
                        selectedSymbol == symbol
                          ? symbolTint
                          : symbolTint.opacity(0.12)
                      )
                      .frame(width: 52, height: 52)

                    Image(systemName: symbol)
                      .font(.system(size: 20, weight: .semibold))
                      .foregroundStyle(
                        selectedSymbol == symbol ? .white : symbolTint)
                  }
                  .frame(maxWidth: .infinity)
                  .frame(height: 74)
                  .contentShape(Rectangle())
                  .proudlyGlass(cornerRadius: 22)
                }
                .buttonStyle(.plain)
              }
            }
          }
          .padding(20)
        }
      }
      .navigationTitle("Habit Icon")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button("Done") { dismiss() }
        }
      }
      .sheet(isPresented: $isEmojiEntryPresented) {
        EmojiInputView { emoji in
          selectedSymbol = emoji
          Haptics.selection()
          dismiss()
        }
        .environment(theme)
      }
    }
  }
}

private struct EmojiInputView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(ThemeViewModel.self) private var theme
  @FocusState private var isEmojiFieldFocused: Bool

  @State private var emojiText = ""

  let onSelect: (String) -> Void

  var body: some View {
    NavigationStack {
      ZStack {
        theme.activeTheme.backgroundGradient.ignoresSafeArea()

        VStack(alignment: .leading, spacing: 18) {
          Text("Type an emoji for your habit icon.")
            .font(.system(size: 28, weight: .bold, design: .rounded))
            .fixedSize(horizontal: false, vertical: true)

          TextField("Type an emoji", text: $emojiText)
            .font(.system(size: 40))
            .multilineTextAlignment(.center)
            .focused($isEmojiFieldFocused)
            .padding(.vertical, 22)
            .padding(.horizontal, 18)
            .proudlyGlass(cornerRadius: 24)
            .onChange(of: emojiText) { _, newValue in
              guard let emoji = newValue.firstHabitEmoji else {
                return
              }
              emojiText = emoji
              onSelect(emoji)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
      }
      .navigationTitle("Type Emoji")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button("Cancel") { dismiss() }
        }
      }
      .onAppear {
        isEmojiFieldFocused = true
      }
    }
  }
}

#Preview {
  SFSymbolPickerView(selectedSymbol: .constant("sparkles"), symbolTint: ProudlyTheme.purple)
    .environment(ThemeViewModel())
}
