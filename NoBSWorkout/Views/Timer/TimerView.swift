//
//  TimerView.swift
//  NoBSWorkout
//
//  Rest timer view with preset durations and custom options
//

import SwiftUI

struct TimerView: View {

    @EnvironmentObject var timerService: TimerService
    @Environment(\.dismiss) private var dismiss

    @State private var showingCustomTimePicker = false
    @State private var customMinutes = 2
    @State private var customSeconds = 0

    var body: some View {
        NavigationView {
            VStack(spacing: UIConstants.spacingXL) {
                Spacer()

                // Large timer display
                ZStack {
                    // Progress circle
                    Circle()
                        .stroke(AppColors.backgroundTertiary, lineWidth: 20)
                        .frame(width: 250, height: 250)

                    Circle()
                        .trim(from: 0, to: CGFloat(timerService.progress))
                        .stroke(
                            timerService.isRunning ? AppColors.primary : AppColors.textTertiary,
                            style: StrokeStyle(lineWidth: 20, lineCap: .round)
                        )
                        .frame(width: 250, height: 250)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: timerService.progress)

                    // Time text
                    VStack(spacing: 8) {
                        Text(timerService.timeRemainingFormatted)
                            .font(.system(size: 60, weight: .bold, design: .rounded))
                            .monospacedDigit()

                        if timerService.isRunning {
                            Text("Rest Time")
                                .font(.caption)
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                }

                Spacer()

                // Control buttons
                if !timerService.isRunning && timerService.timeRemaining == 0 {
                    // Preset buttons
                    VStack(spacing: UIConstants.spacingM) {
                        Text("Quick Start")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.textSecondary)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: UIConstants.spacingM) {
                            ForEach(TimerPresets.durations, id: \.self) { duration in
                                Button(action: {
                                    timerService.startTimer(duration: duration)
                                }) {
                                    Text(TimerPresets.formatDuration(duration))
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 60)
                                        .background(AppColors.primary)
                                        .cornerRadius(UIConstants.cornerRadiusM)
                                }
                            }
                        }

                        Button(action: {
                            showingCustomTimePicker = true
                        }) {
                            Text("Custom Time")
                                .font(.headline)
                                .foregroundColor(AppColors.primary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(AppColors.backgroundSecondary)
                                .cornerRadius(UIConstants.cornerRadiusM)
                                .overlay(
                                    RoundedRectangle(cornerRadius: UIConstants.cornerRadiusM)
                                        .stroke(AppColors.primary, lineWidth: 2)
                                )
                        }
                    }
                } else {
                    // Timer controls
                    VStack(spacing: UIConstants.spacingM) {
                        // Play/Pause/Reset buttons
                        HStack(spacing: UIConstants.spacingL) {
                            Button(action: {
                                timerService.resetTimer()
                            }) {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.title2)
                                    .foregroundColor(AppColors.error)
                                    .frame(width: 60, height: 60)
                                    .background(AppColors.backgroundSecondary)
                                    .clipShape(Circle())
                            }

                            Button(action: {
                                if timerService.isRunning {
                                    timerService.pauseTimer()
                                } else {
                                    timerService.resumeTimer()
                                }
                            }) {
                                Image(systemName: timerService.isRunning ? "pause.fill" : "play.fill")
                                    .font(.title)
                                    .foregroundColor(.white)
                                    .frame(width: 80, height: 80)
                                    .background(AppColors.primary)
                                    .clipShape(Circle())
                            }

                            Button(action: {
                                timerService.stopTimer()
                            }) {
                                Image(systemName: "stop.fill")
                                    .font(.title2)
                                    .foregroundColor(AppColors.textSecondary)
                                    .frame(width: 60, height: 60)
                                    .background(AppColors.backgroundSecondary)
                                    .clipShape(Circle())
                            }
                        }

                        // Add time buttons
                        HStack(spacing: UIConstants.spacingM) {
                            ForEach([15, 30, 60], id: \.self) { seconds in
                                Button(action: {
                                    timerService.addTime(seconds: seconds)
                                }) {
                                    Text("+\(seconds)s")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(AppColors.primary)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 40)
                                        .background(AppColors.backgroundSecondary)
                                        .cornerRadius(UIConstants.cornerRadiusM)
                                }
                            }
                        }
                    }
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Rest Timer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingCustomTimePicker) {
                CustomTimePickerView(
                    minutes: $customMinutes,
                    seconds: $customSeconds,
                    onStart: {
                        let totalSeconds = customMinutes * 60 + customSeconds
                        timerService.startTimer(duration: totalSeconds)
                        showingCustomTimePicker = false
                    }
                )
            }
        }
    }
}

// MARK: - Custom Time Picker View

struct CustomTimePickerView: View {
    @Binding var minutes: Int
    @Binding var seconds: Int
    let onStart: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: UIConstants.spacingXL) {
                Text("Set Custom Time")
                    .font(.title2)
                    .fontWeight(.bold)

                HStack(spacing: 0) {
                    // Minutes picker
                    Picker("Minutes", selection: $minutes) {
                        ForEach(0..<60) { minute in
                            Text("\(minute)").tag(minute)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 100)

                    Text(":")
                        .font(.system(size: 40, weight: .bold))

                    // Seconds picker
                    Picker("Seconds", selection: $seconds) {
                        ForEach(0..<60) { second in
                            Text(String(format: "%02d", second)).tag(second)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 100)
                }

                PrimaryButton("Start Timer", icon: "play.fill") {
                    onStart()
                }
                .padding(.horizontal)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView()
            .environmentObject(TimerService())
    }
}
