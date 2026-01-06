import SwiftUI

struct GoalDetailView: View {
    let goal: Goal
    let currentTime: Date
    let productiveYears: Int
    let onDelete: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appearanceManager: AppearanceManager
    @State private var showAllFormats = true
    @State private var showDeleteConfirmation = false
    
    private var theme: Theme {
        Theme(appearance: appearanceManager)
    }
    
    private var timeRemaining: TimeRemaining {
        TimeRemaining(from: currentTime, to: goal.deadline)
    }
    
    private var timeElapsed: TimeElapsed {
        TimeElapsed(from: goal.createdAt, to: currentTime, deadline: goal.deadline)
    }
    
    private var yearProgress: YearProgress {
        YearProgress()
    }
    
    private var percentOfYear: Double {
        guard yearProgress.daysRemaining > 0 else { return 0 }
        return min(Double(timeRemaining.days) / Double(yearProgress.daysRemaining) * 100, 100)
    }
    
    private var percentOfLife: Double {
        let totalDays = productiveYears * 365
        guard totalDays > 0 else { return 0 }
        return Double(timeRemaining.days) / Double(totalDays) * 100
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                theme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Primary countdown card
                        primaryCountdownCard
                        
                        // All time formats
                        if showAllFormats {
                            allTimeFormatsCard
                        }
                        
                        // Delete button
                        Button(action: { showDeleteConfirmation = true }) {
                            HStack {
                                Image(systemName: "trash")
                                Text("Delete Goal")
                            }
                            .foregroundColor(.red)
                            .font(.system(size: 16, weight: .medium))
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(12)
                        }
                        .padding(.top, 16)
                        
                        Spacer(minLength: 50)
                    }
                    .padding(20)
                }
            }
            .navigationTitle(goal.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(theme.primaryText)
                }
            }
            .confirmationDialog(
                "Delete Goal",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    onDelete()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to delete \"\(goal.name)\"? This cannot be undone.")
            }
        }
    }
    
    private var primaryCountdownCard: some View {
        VStack(spacing: 16) {
            Text("PRIMARY COUNTDOWN")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(theme.secondaryText)
                .tracking(1.5)
            
            // Big countdown
            Text("\(timeRemaining.days)")
                .font(.system(size: 72, weight: .bold, design: .rounded))
                .foregroundColor(theme.primaryText)
            
            Text("days \(timeRemaining.hours)h \(timeRemaining.minutes)m \(timeRemaining.seconds)s")
                .font(.system(size: 16, weight: .medium, design: .monospaced))
                .foregroundColor(theme.tertiaryText)
            
            // Battery visual
            BatteryVisual(
                daysRemaining: timeRemaining.days,
                percentRemaining: 100 - timeElapsed.percentElapsed,
                urgencyLevel: goal.urgencyLevel
            )
            .frame(height: 80)
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            
            // Progress info
            HStack {
                Text("Time elapsed: \(String(format: "%.1f", timeElapsed.percentElapsed))%")
                    .font(.system(size: 13))
                    .foregroundColor(theme.secondaryText)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(glassBackground)
    }
    
    private var allTimeFormatsCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Goal deadline section
            sectionHeader("YOUR GOAL DEADLINE")
            VStack(alignment: .leading, spacing: 8) {
                formatRow("Days left", "\(timeRemaining.days)")
                formatRow("Hours left", timeRemaining.formattedHours)
                formatRow("Minutes left", timeRemaining.formattedMinutes)
                formatRow("Seconds left", timeRemaining.formattedSeconds)
                formatRow("Weeks left", timeRemaining.formattedWeeks)
                formatRow("Months left", timeRemaining.formattedMonths)
            }
            
            Divider().background(theme.divider)
            
            // Temporal landmarks section
            sectionHeader("TEMPORAL LANDMARKS")
            VStack(alignment: .leading, spacing: 8) {
                formatRow("Mondays remaining", "\(timeRemaining.days / 7)")
                formatRow("Weekends remaining", "\(timeRemaining.weekends)")
                formatRow("Work weeks left", "\(timeRemaining.days / 7)")
            }
            
            Divider().background(theme.divider)
            
            // Year context section
            sectionHeader("YOUR YEAR (\(yearProgress.year))")
            VStack(alignment: .leading, spacing: 8) {
                formatRow("% of your year", "\(String(format: "%.1f", percentOfYear))%")
                formatRow("Days left in \(yearProgress.year)", "\(yearProgress.daysRemaining)")
                formatRow("% of year already gone", "\(String(format: "%.1f", yearProgress.percentGone))%")
            }
            
            Divider().background(theme.divider)
            
            // Life context section
            sectionHeader("YOUR LIFE")
            VStack(alignment: .leading, spacing: 8) {
                formatRow("% of productive life", "\(String(format: "%.2f", percentOfLife))%")
                formatRow("This goal uses", "\(timeRemaining.days) of your \(productiveYears * 365) remaining days")
            }
            
            Divider().background(theme.divider)
            
            // Sunk cost section
            sectionHeader("TIME ALREADY WASTED")
            VStack(alignment: .leading, spacing: 8) {
                formatRow("Started", "\(timeElapsed.days) days ago")
                formatRow("% of goal time used", "\(String(format: "%.1f", timeElapsed.percentElapsed))%")
                formatRow("Days gone forever", "\(timeElapsed.days)")
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(glassBackground)
    }
    
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(theme.secondaryText)
            .tracking(1)
    }
    
    private func formatRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text("•")
                .foregroundColor(theme.secondaryText)
            Text(label)
                .foregroundColor(theme.tertiaryText)
            Spacer()
            Text(value)
                .foregroundColor(theme.primaryText)
                .fontWeight(.medium)
        }
        .font(.system(size: 15))
    }
    
    private var glassBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(theme.secondaryBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(theme.divider, lineWidth: 1)
            )
    }
}

#Preview {
    GoalDetailView(
        goal: Goal(
            userId: UUID(),
            name: "Launch my startup",
            deadline: Date().addingTimeInterval(86400 * 161)
        ),
        currentTime: Date(),
        productiveYears: 30,
        onDelete: {}
    )
    .environmentObject(AppearanceManager.shared)
}
