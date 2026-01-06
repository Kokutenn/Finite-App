import SwiftUI

struct AppBlockingView: View {
    let appName: String
    let goals: [Goal]
    let productiveYearsRemaining: Int
    let onClose: () -> Void
    let onContinue: () -> Void
    
    @State private var showTimer = false
    @State private var timeRemaining = 120 // 2 minutes in seconds
    @State private var timer: Timer?
    
    private var yearProgress: YearProgress {
        YearProgress()
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if showTimer {
                timerView
            } else {
                blockingView
            }
        }
    }
    
    private var blockingView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Warning icon
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.yellow)
            
            // Title
            Text("TIME IS FINITE")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
            
            // Message
            Text("You're about to open \(appName).")
                .font(.system(size: 17))
                .foregroundColor(.white.opacity(0.8))
            
            // Goals card
            VStack(spacing: 16) {
                Text("TIME YOU HAVE LEFT:")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.gray)
                    .tracking(1.5)
                
                ForEach(goals) { goal in
                    HStack {
                        Text(goal.name)
                            .foregroundColor(.white)
                            .lineLimit(1)
                        Spacer()
                        Text("\(goal.timeRemaining.days) days")
                            .foregroundColor(goal.urgencyLevel.color)
                            .fontWeight(.semibold)
                    }
                    .font(.system(size: 15))
                }
                
                Divider().background(Color.white.opacity(0.1))
                
                HStack {
                    Text("\(yearProgress.year):")
                        .foregroundColor(.gray)
                    Spacer()
                    Text("\(yearProgress.daysRemaining) days remaining")
                        .foregroundColor(.white)
                }
                .font(.system(size: 14))
                
                HStack {
                    Text("Your productive life:")
                        .foregroundColor(.gray)
                    Spacer()
                    Text("\((productiveYearsRemaining * 365).formatted()) days left")
                        .foregroundColor(.white)
                }
                .font(.system(size: 14))
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 24)
            
            // Warning message
            Text("Every minute scrolling is a minute you can't get back.")
                .font(.system(size: 15))
                .foregroundColor(.red.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Spacer()
            
            // Buttons
            VStack(spacing: 12) {
                Button(action: {
                    HapticService.shared.success()
                    onClose()
                }) {
                    Text("Close App")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color.green)
                        .cornerRadius(12)
                }
                
                Button(action: {
                    HapticService.shared.warning()
                    showTimer = true
                    startTimer()
                }) {
                    Text("I'll Be Quick (2 min timer)")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
    
    private var timerView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Timer display
            VStack(spacing: 8) {
                Text(formatTime(timeRemaining))
                    .font(.system(size: 72, weight: .bold, design: .monospaced))
                    .foregroundColor(timeRemaining <= 30 ? .red : .white)
                
                Text("remaining")
                    .font(.system(size: 17))
                    .foregroundColor(.gray)
            }
            
            // Progress ring
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 8)
                    .frame(width: 150, height: 150)
                
                Circle()
                    .trim(from: 0, to: CGFloat(timeRemaining) / 120)
                    .stroke(
                        timeRemaining <= 30 ? Color.red : Color.orange,
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 150, height: 150)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: timeRemaining)
            }
            
            // Goal reminder
            if let firstGoal = goals.first {
                Text("\(firstGoal.timeRemaining.days) days left on \(firstGoal.name)")
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            // Close button
            Button(action: {
                stopTimer()
                onClose()
            }) {
                Text("I'm Done")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
                
                // Haptic feedback at certain intervals
                if timeRemaining == 60 || timeRemaining == 30 || timeRemaining == 10 {
                    HapticService.shared.warning()
                }
            } else {
                stopTimer()
                // Time's up - show the time's up view
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - Time's Up View
struct TimesUpView: View {
    let goals: [Goal]
    let productiveYearsRemaining: Int
    let onClose: () -> Void
    
    private var yearProgress: YearProgress {
        YearProgress()
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                // Icon
                Image(systemName: "clock.badge.exclamationmark.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.red)
                
                // Title
                Text("TIME'S UP")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                // Message
                VStack(spacing: 8) {
                    Text("You said you'd be quick.")
                        .foregroundColor(.white.opacity(0.8))
                    Text("That was 2 minutes you'll never get back.")
                        .foregroundColor(.red)
                        .fontWeight(.medium)
                }
                .font(.system(size: 17))
                .multilineTextAlignment(.center)
                
                // Time remaining card
                VStack(spacing: 12) {
                    Text("You have:")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    ForEach(goals) { goal in
                        HStack {
                            Text("•")
                                .foregroundColor(.gray)
                            Text("\(goal.timeRemaining.days) days left on \(goal.name)")
                                .foregroundColor(.white)
                        }
                        .font(.system(size: 15))
                    }
                    
                    HStack {
                        Text("•")
                            .foregroundColor(.gray)
                        Text("\(yearProgress.daysRemaining) days left in \(yearProgress.year)")
                            .foregroundColor(.white)
                    }
                    .font(.system(size: 15))
                    
                    HStack {
                        Text("•")
                            .foregroundColor(.gray)
                        Text("\((productiveYearsRemaining * 365).formatted()) days left in life")
                            .foregroundColor(.white)
                    }
                    .font(.system(size: 15))
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.05))
                )
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Close button
                Button(action: {
                    HapticService.shared.heavyTap()
                    onClose()
                }) {
                    Text("Close App")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
}

#Preview("Blocking") {
    AppBlockingView(
        appName: "Instagram",
        goals: [
            Goal(userId: UUID(), name: "Launch Startup", deadline: Date().addingTimeInterval(86400 * 161)),
            Goal(userId: UUID(), name: "Lose 20 lbs", deadline: Date().addingTimeInterval(86400 * 84))
        ],
        productiveYearsRemaining: 30,
        onClose: {},
        onContinue: {}
    )
}

#Preview("Times Up") {
    TimesUpView(
        goals: [
            Goal(userId: UUID(), name: "Launch Startup", deadline: Date().addingTimeInterval(86400 * 161))
        ],
        productiveYearsRemaining: 30,
        onClose: {}
    )
}
