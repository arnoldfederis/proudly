//
//  OnboardingFlowView.swift
//  Proudly
//
//  Created by Arnolfo Federis on 6/16/26.
//

import SwiftUI

struct OnboardingFlowView: View {
  @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
  @Environment(ThemeViewModel.self) private var theme
  @Environment(HabitRepository.self) private var repository

  @State private var viewModel = OnboardingViewModel()
  @State private var isSFSymbolPickerPresented = false
  @State private var customColor: Color = ProudlyTheme.purple
  @State private var navigationDirection = 1
  @FocusState private var focusedField: OnboardingFocusField?

  var body: some View {
    ZStack {
      theme.activeTheme.backgroundGradient.ignoresSafeArea()

      VStack(spacing: 0) {
        if viewModel.currentStep != .celebration {
          header
            .padding(.horizontal, 20)
            .padding(.top, 14)
            .padding(.bottom, 10)
        }

        content
          .id(viewModel.currentStep)
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .contentTransition(.opacity)
          .transition(stepTransition)

        if viewModel.currentStep != .celebration {
          controls
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 22)
        }
      }
    }
    .animation(.spring(response: 0.42, dampingFraction: 0.82), value: viewModel.currentStep)
    .sheet(isPresented: $isSFSymbolPickerPresented) {
      SFSymbolPickerView(
        selectedSymbol: $viewModel.selectedIcon,
        symbolTint: viewModel.selectedColor,
        excludedSymbols: Set(viewModel.iconOptions)
      )
      .environment(theme)
    }
    .onAppear {
      customColor = viewModel.selectedColor
    }
    .onChange(of: viewModel.currentStep) { oldValue, newValue in
      navigationDirection = stepOrderIndex(for: newValue) >= stepOrderIndex(for: oldValue) ? 1 : -1
    }
    .onChange(of: viewModel.selectedFrequency) { _, newValue in
      if newValue == 0 {
        if viewModel.reminderOption != .none {
          viewModel.reminderOption = .custom
        }
      } else if viewModel.reminderOption == .custom {
        viewModel.reminderOption = .morning
      }
    }
  }

  private var header: some View {
    VStack(alignment: .leading, spacing: 14) {
      HStack {
        Text(viewModel.currentStep.title)
          .font(.headline)
        Spacer()
        Text("\(Int((viewModel.progressValue * 100).rounded()))%")
          .font(.caption.weight(.semibold))
          .foregroundStyle(.secondary)
          .contentTransition(.numericText())
      }

      HStack(spacing: 8) {
        ForEach(OnboardingStep.inputSteps, id: \.self) { step in
          RoundedRectangle(cornerRadius: 999)
            .fill(
              viewModel.hasReachedStep(step)
                ? theme.activeTheme.accentColor : Color.white.opacity(0.22)
            )
            .frame(height: 8)
            .overlay {
              RoundedRectangle(cornerRadius: 999)
                .stroke(Color.white.opacity(0.14), lineWidth: 0.5)
            }
        }
      }
    }
  }

  @ViewBuilder
  private var content: some View {
    switch viewModel.currentStep {
    case .welcome:
      EmptyView()
    case .icon:
      stepContainer(
        title: "Pick something that feels like your habit.",
        subtitle: "Choose an icon to make it feel personal."
      ) {
        LazyVGrid(
          columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12
        ) {
          ForEach(viewModel.iconOptions, id: \.self) { icon in
            iconButton(icon)
          }
          sfSymbolPickerButton
        }
      }
    case .name:
      stepContainer(
        title: "What habit do you want to start with?",
        subtitle: "Keep it small enough to do today."
      ) {
        TextField("Drink water", text: $viewModel.habitName)
          .textInputAutocapitalization(.words)
          .padding(18)
          .proudlyGlass(cornerRadius: 20)
          .focused($focusedField, equals: .habitName)
          .onAppear {
            Task { @MainActor in
              try? await Task.sleep(for: .milliseconds(350))
              focusedField = .habitName
            }
          }
      }
    case .userName:
      stepContainer(
        title: "What should Proudly call you?",
        subtitle: "We'll keep it personal and gentle."
      ) {
        TextField("John Doe", text: $viewModel.userName)
          .textInputAutocapitalization(.words)
          .padding(18)
          .proudlyGlass(cornerRadius: 20)
          .focused($focusedField, equals: .userName)
          .onAppear {
            Task { @MainActor in
              try? await Task.sleep(for: .milliseconds(350))
              focusedField = .userName
            }
          }
      }
    case .description:
      stepContainer(
        title: "Why does this habit matter to you?",
        subtitle: "This is optional, but it helps the habit feel meaningful."
      ) {
        TextField(
          "Stay hydrated and feel better every day",
          text: $viewModel.habitDescription,
          axis: .vertical
        )
        .lineLimit(4, reservesSpace: true)
        .padding(18)
        .proudlyGlass(cornerRadius: 20)
        .focused($focusedField, equals: .habitDescription)
        .onAppear {
          Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(350))
            focusedField = .habitDescription
          }
        }
        .toolbar {
          ToolbarItemGroup(placement: .keyboard) {
            Spacer()
            Button("Done") { focusedField = nil }
          }
        }
      }
    case .color:
      stepContainer(
        title: "Choose a color that feels good to see every day.",
        subtitle: "Your habit card will use this accent."
      ) {
        LazyVGrid(
          columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 4), spacing: 16
        ) {
          ForEach(viewModel.colorOptions.indices, id: \.self) { index in
            colorButton(viewModel.colorOptions[index])
          }
          customColorButton
        }
      }
    case .frequency:
      stepContainer(
        title: "How often should this happen each day?",
        subtitle: "You can keep it simple or track a few check-ins."
      ) {
        VStack(spacing: 12) {
          ForEach([1, 2, 3, 4], id: \.self) { value in
            frequencyButton(value: value, label: frequencyLabel(for: value))
          }

          HStack {
            VStack(alignment: .leading, spacing: 4) {
              Text("Custom")
                .font(.system(size: 16, weight: .semibold))
              Text("\(viewModel.dailyTargetCount) times each day")
                .font(.caption)
                .foregroundStyle(.secondary)
                .contentTransition(.numericText())
            }
            Spacer()
            Stepper("", value: $viewModel.customFrequency, in: 1...8)
              .labelsHidden()
          }
          .padding(18)
          .frame(maxWidth: .infinity)
          .background(
            viewModel.selectedFrequency == 0
              ? theme.activeTheme.accentColor.opacity(0.18) : .clear
          )
          .overlay {
            RoundedRectangle(cornerRadius: 20)
              .stroke(
                viewModel.selectedFrequency == 0
                  ? theme.activeTheme.accentColor : Color.white.opacity(0.14), lineWidth: 1.2)
          }
          .clipShape(RoundedRectangle(cornerRadius: 20))
          .contentShape(Rectangle())
          .proudlyGlass(cornerRadius: 20)
          .onTapGesture {
            withAnimation(.spring(response: 0.32, dampingFraction: 0.76)) {
              viewModel.selectedFrequency = 0
              if viewModel.reminderOption != .none {
                viewModel.reminderOption = .custom
              }
              Haptics.selection()
            }
          }
        }
      }
    case .reminder:
      stepContainer(
        title: "When should Proudly remind you?",
        subtitle: viewModel.selectedFrequency == 0
          ? "Choose the first reminder time. Proudly will space the rest across the day."
          : viewModel.dailyTargetCount > 1
            ? "For habits with a few check-ins, Proudly can spread reminders through the day."
            : "Pick a gentle time, or skip reminders for now."
      ) {
        VStack(spacing: 12) {
          ForEach(reminderOptions) { option in
            reminderButton(option)
          }

          if showsCustomReminderPicker {
            DatePicker(
              "Reminder time",
              selection: $viewModel.customReminderTime,
              displayedComponents: .hourAndMinute
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .proudlyGlass(cornerRadius: 20)
            .transition(.opacity.combined(with: .move(edge: .bottom)))
          }

          if !viewModel.resolvedReminderTimes.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
              Text("Planned reminders")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
              Text(viewModel.resolvedReminderTimes.joined(separator: "  •  "))
                .font(.subheadline.weight(.medium))
                .contentTransition(.numericText())
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .proudlyGlass(cornerRadius: 18)
          }
        }
      }
    case .permission:
      stepContainer(
        title: "Let Proudly send gentle reminders?",
        subtitle: "We'll only use notifications for the habit times you choose."
      ) {
        VStack(spacing: 14) {
          HStack(spacing: 14) {
            ZStack {
              Circle()
                .fill(theme.activeTheme.accentColor.opacity(0.18))
                .frame(width: 54, height: 54)
              Image(systemName: "bell.badge.fill")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(theme.activeTheme.accentColor)
            }

            VStack(alignment: .leading, spacing: 4) {
              Text("Gentle reminders")
                .font(.system(size: 17, weight: .semibold))
              Text("You can change this later in Settings.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }

            Spacer()
          }
          .padding(18)
          .proudlyGlass(cornerRadius: 20)

          if let permissionDeniedMessage = viewModel.permissionDeniedMessage {
            Text(permissionDeniedMessage)
              .font(.footnote.weight(.medium))
              .foregroundStyle(.secondary)
              .frame(maxWidth: .infinity, alignment: .leading)
              .padding(16)
              .proudlyGlass(cornerRadius: 18)
          }
        }
      }
    case .celebration:
      OnboardingCelebrationView(message: viewModel.permissionDeniedMessage) {
        hasCompletedOnboarding = true
      }
      .transition(.opacity.combined(with: .scale(scale: 0.98)))
    }
  }

  private var controls: some View {
    HStack(spacing: 12) {
      if viewModel.currentStep != OnboardingStep.inputSteps.first {
        Button(action: handleBack) {
          Image(systemName: "chevron.left")
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(.primary)
            .frame(width: 52, height: 52)
            .background(Color.white.opacity(0.08))
            .clipShape(Circle())
            .proudlyGlass(cornerRadius: 26)
        }
        .buttonStyle(.plain)
        .opacity(viewModel.currentStep == OnboardingStep.inputSteps.first ? 0 : 1)
        .allowsHitTesting(viewModel.currentStep != OnboardingStep.inputSteps.first)
      }

      Button(action: handleContinue) {
        HStack(spacing: 8) {
          if viewModel.isSaving {
            ProgressView()
              .tint(.white)
          } else {
            Text(viewModel.continueTitle)
              .font(.system(size: 17, weight: .semibold))
          }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 17)
        .background(
          viewModel.canContinue
            ? ProudlyTheme.purplePinkGradient
            : LinearGradient(
              colors: [Color.gray.opacity(0.4), Color.gray.opacity(0.35)], startPoint: .leading,
              endPoint: .trailing)
        )
        .foregroundStyle(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .opacity(viewModel.canContinue ? 1 : 0.6)
      }
      .buttonStyle(.plain)
      .disabled(!viewModel.canContinue || viewModel.isSaving)
      .animation(.spring(response: 0.28, dampingFraction: 0.8), value: viewModel.canContinue)
    }
  }

  private func stepContainer<Content: View>(
    title: String,
    subtitle: String,
    @ViewBuilder content: () -> Content
  ) -> some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 22) {
        VStack(alignment: .leading, spacing: 10) {
          Text(title)
            .font(.system(size: 30, weight: .bold, design: .rounded))
            .fixedSize(horizontal: false, vertical: true)
          Text(subtitle)
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
        }

        content()
      }
      .padding(.horizontal, 20)
      .padding(.top, 24)
      .padding(.bottom, 28)
    }
  }

  private func iconButton(_ icon: String) -> some View {
    Button {
      withAnimation(.spring(response: 0.34, dampingFraction: 0.72)) {
        viewModel.selectedIcon = icon
        Haptics.selection()
      }
    } label: {
      ZStack {
        RoundedRectangle(cornerRadius: 22)
          .fill(
            viewModel.selectedIcon == icon
              ? viewModel.selectedColor.opacity(0.2) : Color.white.opacity(0.05)
          )
          .overlay {
            RoundedRectangle(cornerRadius: 22)
              .stroke(
                viewModel.selectedIcon == icon
                  ? viewModel.selectedColor : Color.white.opacity(0.12), lineWidth: 1.2)
          }

        Image(systemName: icon)
          .font(.system(size: 24, weight: .semibold))
          .foregroundStyle(
            viewModel.selectedIcon == icon ? viewModel.selectedColor : .primary
          )
          .symbolEffect(.bounce, value: viewModel.selectedIcon == icon)
      }
      .frame(height: 74)
      .scaleEffect(viewModel.selectedIcon == icon ? 1 : 0.96)
      .contentShape(Rectangle())
      .proudlyGlass(cornerRadius: 22)
    }
    .buttonStyle(.plain)
  }

  private var sfSymbolPickerButton: some View {
    Button {
      Haptics.selection()
      isSFSymbolPickerPresented = true
    } label: {
      ZStack {
        RoundedRectangle(cornerRadius: 22)
          .fill(
            isUsingCustomPickerIcon
              ? viewModel.selectedColor.opacity(0.2) : Color.white.opacity(0.05)
          )
          .overlay {
            RoundedRectangle(cornerRadius: 22)
              .stroke(
                isUsingCustomPickerIcon
                  ? viewModel.selectedColor : Color.white.opacity(0.12),
                lineWidth: 1.2
              )
          }

        if isUsingCustomPickerIcon {
          Group {
            if viewModel.selectedIcon.isHabitSFSymbol {
              Image(systemName: viewModel.selectedIcon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(viewModel.selectedColor)
            } else {
              Text(viewModel.selectedIcon)
                .font(.system(size: 24))
            }
          }
          .overlay(alignment: .bottomTrailing) {
            if viewModel.selectedIcon.isHabitSFSymbol {
              ZStack {
                Circle()
                  .fill(Color.white.opacity(0.92))
                  .frame(width: 18, height: 18)
                Image(systemName: "plus")
                  .font(.system(size: 9, weight: .bold))
                  .foregroundStyle(viewModel.selectedColor)
              }
              .offset(x: 8, y: 8)
            } else if viewModel.selectedIcon.isHabitEmoji {
              Image(systemName: "plus")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.18), radius: 3, y: 1)
                .offset(x: 8, y: 8)
            }
          }
        } else {
          Image(systemName: "plus")
            .font(.system(size: 24, weight: .semibold))
            .foregroundStyle(.primary)
        }
      }
      .frame(height: 74)
      .contentShape(Rectangle())
      .proudlyGlass(cornerRadius: 22)
    }
    .buttonStyle(.plain)
  }

  private func colorButton(_ color: Color) -> some View {
    Button {
      withAnimation(.spring(response: 0.34, dampingFraction: 0.72)) {
        viewModel.selectedColor = color
        Haptics.selection()
      }
    } label: {
      ZStack {
        Circle()
          .fill(color)
          .frame(width: 56, height: 56)

        if color.toHex() == viewModel.selectedColor.toHex() {
          Image(systemName: "checkmark")
            .font(.system(size: 16, weight: .bold))
            .foregroundStyle(.white)
            .symbolEffect(.bounce, value: color.toHex() == viewModel.selectedColor.toHex())
        }
      }
      .padding(8)
      .frame(maxWidth: .infinity)
      .background(color.toHex() == viewModel.selectedColor.toHex() ? color.opacity(0.18) : .clear)
      .clipShape(RoundedRectangle(cornerRadius: 22))
      .contentShape(Rectangle())
      .proudlyGlass(cornerRadius: 22)
    }
    .buttonStyle(.plain)
  }

  private var customColorButton: some View {
    ZStack {
      ColorPicker("", selection: $customColor, supportsOpacity: false)
        .labelsHidden()
        .frame(width: 72, height: 72)
        .opacity(0.015)
        .onChange(of: customColor) { _, newValue in
          viewModel.selectedColor = newValue
          Haptics.selection()
        }

      ZStack {
        Circle()
          .fill(isUsingCustomColor ? customColor : Color.gray.opacity(0.15))
          .frame(width: 56, height: 56)

        if isUsingCustomColor {
          Image(systemName: "checkmark")
            .font(.system(size: 16, weight: .bold))
            .foregroundStyle(.white)
        } else {
          Image(systemName: "plus")
            .font(.system(size: 16, weight: .bold))
            .foregroundStyle(.gray)
        }
      }
      .padding(8)
      .frame(maxWidth: .infinity)
      .background(isUsingCustomColor ? customColor.opacity(0.18) : .clear)
      .clipShape(RoundedRectangle(cornerRadius: 22))
      .contentShape(Rectangle())
      .proudlyGlass(cornerRadius: 22)
      .allowsHitTesting(false)
    }
  }

  private func frequencyButton(value: Int, label: String) -> some View {
    Button {
      withAnimation(.spring(response: 0.32, dampingFraction: 0.76)) {
        viewModel.selectedFrequency = value
        Haptics.selection()
      }
    } label: {
      HStack {
        VStack(alignment: .leading, spacing: 4) {
          Text(label)
            .font(.system(size: 16, weight: .semibold))
          Text(value == 1 ? "A single daily check-in." : "Track your progress through the day.")
            .font(.caption)
            .foregroundStyle(.secondary)
        }

        Spacer()

        Image(systemName: viewModel.selectedFrequency == value ? "checkmark.circle.fill" : "circle")
          .font(.system(size: 20, weight: .semibold))
          .foregroundStyle(
            viewModel.selectedFrequency == value ? theme.activeTheme.accentColor : .secondary)
      }
      .padding(18)
      .frame(maxWidth: .infinity)
      .background(
        viewModel.selectedFrequency == value ? theme.activeTheme.accentColor.opacity(0.18) : .clear
      )
      .clipShape(RoundedRectangle(cornerRadius: 20))
      .contentShape(Rectangle())
      .proudlyGlass(cornerRadius: 20)
    }
    .buttonStyle(.plain)
  }

  private func reminderButton(_ option: OnboardingReminderOption) -> some View {
    Button {
      withAnimation(.spring(response: 0.32, dampingFraction: 0.76)) {
        viewModel.reminderOption = option
        Haptics.selection()
      }
    } label: {
      HStack {
        VStack(alignment: .leading, spacing: 4) {
          Text(option.title)
            .font(.system(size: 16, weight: .semibold))
          Text(option.subtitle)
            .font(.caption)
            .foregroundStyle(.secondary)
        }

        Spacer()

        Image(systemName: viewModel.reminderOption == option ? "checkmark.circle.fill" : "circle")
          .font(.system(size: 20, weight: .semibold))
          .foregroundStyle(
            viewModel.reminderOption == option ? theme.activeTheme.accentColor : .secondary)
      }
      .padding(18)
      .frame(maxWidth: .infinity)
      .background(
        viewModel.reminderOption == option ? theme.activeTheme.accentColor.opacity(0.18) : .clear
      )
      .clipShape(RoundedRectangle(cornerRadius: 20))
      .contentShape(Rectangle())
      .proudlyGlass(cornerRadius: 20)
    }
    .buttonStyle(.plain)
  }

  private func handleBack() {
    Haptics.selection()
    viewModel.goBack()
  }

  private func handleContinue() {
    Haptics.selection()
    Task {
      await viewModel.advance(using: repository)
    }
  }

  private func frequencyLabel(for value: Int) -> String {
    switch value {
    case 1:
      return "Once a day"
    case 2:
      return "Twice a day"
    default:
      return "\(value) times a day"
    }
  }

  private var isUsingCustomPickerIcon: Bool {
    (viewModel.selectedIcon.isHabitSFSymbol || viewModel.selectedIcon.isHabitEmoji)
      && !viewModel.iconOptions.contains(viewModel.selectedIcon)
  }

  private var isUsingCustomColor: Bool {
    !viewModel.colorOptions.map({ $0.toHex() }).contains(viewModel.selectedColor.toHex())
  }

  private func stepOrderIndex(for step: OnboardingStep) -> Int {
    OnboardingStep.inputSteps.firstIndex(of: step) ?? step.rawValue
  }

  private var reminderOptions: [OnboardingReminderOption] {
    viewModel.selectedFrequency == 0 ? [.none, .custom] : OnboardingReminderOption.allCases
  }

  private var showsCustomReminderPicker: Bool {
    viewModel.remindersEnabled
      && (viewModel.selectedFrequency == 0 || viewModel.reminderOption == .custom)
  }

  private var stepTransition: AnyTransition {
    .asymmetric(
      insertion: .move(edge: navigationDirection > 0 ? .trailing : .leading).combined(
        with: .opacity),
      removal: .move(edge: navigationDirection > 0 ? .leading : .trailing).combined(with: .opacity)
    )
  }
}

private enum OnboardingFocusField: Hashable {
  case userName, habitName, habitDescription
}

#Preview {
  OnboardingFlowView()
    .environment(ThemeViewModel())
    .environment(SubscriptionStore())
    .environment(HabitRepository.preview)
}
