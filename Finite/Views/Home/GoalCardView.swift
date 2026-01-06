import SwiftUI

struct GoalCardView: View {
    let goal: Goal
    let currentTime: Date
    let productiveYears: Int
    @EnvironmentObject var appearanceManager: AppearanceManager
    
    @State private var isPulsing = false
    
    private var theme: Theme {
        Theme(appearance: appearanceManager)
    }
    
    private var timeRemaining: TimeRemaining {
        TimeRemaining(from: currentTime, to: goal.deadline)
    }
    
    private var urgencyLevel: UrgencyLevel {
        goal.urgencyLevel
    }
    
    private var percentOfYear: Double {
        let yearProgress = YearProgress()
        guard yearProgress.daysRemaining > 0 else { return 0 }
        return min(Double(timeRemaining.days) / Double(yearProgress.daysRemaining) * 100, 100)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("⏰")
                    .font(.system(size: 16))
                
                Text(goal.name)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(theme.primaryText)
                    .lineLimit(1)
                
                Spacer()
                
                Text(urgencyLevel.icon)
                    .font(.system(size: 14))
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 8)
            
            // Due date
            Text("Due: \(goal.deadline.formatted(date: .abbreviated, time: .omitted))")
                .font(.system(size: 13))
                .foregroundColor(theme.secondaryText)
                .padding(.bottom, 16)
            
            // Main countdown - Battery Visual
            BatteryVisual(
                daysRemaining: timeRemaining.days,
                percentRemaining: percentRemaining,
                urgencyLevel: urgencyLevel
            )
            .frame(height: 100)
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
            
            // Time remaining text
            Text("\(timeRemaining.days) days \(timeRemaining.hours)h \(timeRemaining.minutes)m")
                .font(.system(size: 14, weight: .medium, design: .monospaced))
                .foregroundColor(theme.tertiaryText)
                .padding(.bottom, 12)
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 4)
                        .fill(theme.cardBackground)
                    
                    // Progress (showing time remaining, depleting)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(urgencyLevel.color)
                        .frame(width: geometry.size.width * (percentRemaining / 100))
                        .scaleEffect(x: 1, y: isPulsing && urgencyLevel.pulseAnimation ? 1.1 : 1.0)
                }
            }
            .frame(height: 8)
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
            
            // Stats row
            HStack {
                Text("\(String(format: "%.0f", percentOfYear))% of year")
                    .font(.system(size: 12))
                    .foregroundColor(theme.secondaryText)
                
                Spacer()
                
                Text("\(timeRemaining.formattedHours) hours left")
                    .font(.system(size: 12))
                    .foregroundColor(theme.secondaryText)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(urgencyLevel.backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(urgencyLevel.color.opacity(0.3), lineWidth: 1)
                )
        )
        .onAppear {
            if urgencyLevel.pulseAnimation {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    isPulsing = true
                }
            }
        }
    }
    
    private var percentRemaining: Double {
        let totalDays = daysBetween(goal.createdAt, goal.deadline)
        guard totalDays > 0 else { return 0 }
        return min(Double(timeRemaining.days) / Double(totalDays) * 100, 100)
    }
    
    private func daysBetween(_ start: Date, _ end: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: start, to: end)
        return max(components.day ?? 0, 1)
    }
}

// MARK: - Battery Visual
struct BatteryVisual: View {
    let daysRemaining: Int
    let percentRemaining: Double
    let urgencyLevel: UrgencyLevel
    
    @State private var isPulsing = false
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 4) {
                // Battery body
                ZStack(alignment: .leading) {
                    // Battery outline
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white.opacity(0.3), lineWidth: 2)
                    
                    // Battery fill
                    RoundedRectangle(cornerRadius: 6)
                        .fill(urgencyLevel.color)
                        .frame(width: max((geometry.size.width - 20) * (percentRemaining / 100), 0))
                        .padding(4)
                        .scaleEffect(isPulsing && urgencyLevel.pulseAnimation ? 1.02 : 1.0)
                    
                    // Days text overlay
                    VStack(spacing: 2) {
                        Text("\(daysRemaining)")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("days left")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(width: geometry.size.width - 12)
                
                // Battery cap
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 6, height: 30)
            }
        }
        .onAppear {
            if urgencyLevel.pulseAnimation {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    isPulsing = true
                }
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        VStack(spacing: 16) {
            GoalCardView(
                goal: Goal(
                    userId: UUID(),
                    name: "Launch my startup",
                    deadline: Date().addingTimeInterval(86400 * 161)
                ),
                currentTime: Date(),
                productiveYears: 30
            )
            
            GoalCardView(
                goal: Goal(
                    userId: UUID(),
                    name: "Lose 20 pounds",
                    deadline: Date().addingTimeInterval(86400 * 30)
                ),
                currentTime: Date(),
                productiveYears: 30
            )
        }
        .padding()
    }
}
