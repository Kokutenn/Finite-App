import SwiftUI

struct CountdownBeginsStepView: View {
    let goalName: String
    let goalDeadline: Date
    let onComplete: () -> Void
    @EnvironmentObject var appearanceManager: AppearanceManager
    
    @State private var animateCountdown = false
    
    private var theme: Theme {
        Theme(appearance: appearanceManager)
    }
    
    private var daysRemaining: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: goalDeadline)
        return max(components.day ?? 0, 0)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Logo header
            Image(theme.logoName)
                .resizable()
                .scaledToFit()
                .frame(height: 40)
                .padding(.top, 20)
            
            Spacer()
            
            // Icon
            Text("⏰")
                .font(.system(size: 60))
                .padding(.bottom, 24)
            
            // Title
            Text("Your Countdown Begins")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(theme.primaryText)
                .padding(.bottom, 32)
            
            // Goal card
            VStack(spacing: 16) {
                Text("\"\(goalName)\"")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(theme.cardText)
                    .multilineTextAlignment(.center)
                
                Text("Due: \(goalDeadline.formatted(date: .long, time: .omitted))")
                    .font(.system(size: 15))
                    .foregroundColor(theme.cardSecondaryText)
                
                // Big countdown
                Text("\(daysRemaining)")
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .foregroundColor(theme.cardText)
                    .scaleEffect(animateCountdown ? 1.0 : 0.8)
                    .opacity(animateCountdown ? 1.0 : 0.5)
                
                Text("days remaining")
                    .font(.system(size: 17))
                    .foregroundColor(theme.cardSecondaryText)
            }
            .padding(32)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(theme.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(theme.divider, lineWidth: 1)
                    )
            )
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
            
            // Messages
            VStack(spacing: 16) {
                messageRow(text: "From this moment forward, Finite will remind you relentlessly that time is passing.")
                messageRow(text: "Through notifications.")
                messageRow(text: "Through widgets.")
                messageRow(text: "Through every distraction.")
            }
            .padding(.horizontal, 32)
            
            Spacer()
            
            // Final message
            VStack(spacing: 8) {
                Text("You can't pause time.")
                    .foregroundColor(theme.tertiaryText)
                Text("But you can use it wisely.")
                    .foregroundColor(theme.primaryText)
                    .fontWeight(.medium)
            }
            .font(.system(size: 16))
            .padding(.bottom, 24)
            
            // Start button
            Button(action: {
                HapticService.shared.heavyTap()
                onComplete()
            }) {
                Text("Start")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(theme.buttonText)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(theme.buttonBackground)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animateCountdown = true
            }
        }
    }
    
    private func messageRow(text: String) -> some View {
        Text(text)
            .font(.system(size: 15))
            .foregroundColor(theme.tertiaryText)
            .multilineTextAlignment(.center)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        CountdownBeginsStepView(
            goalName: "Launch my startup",
            goalDeadline: Date().addingTimeInterval(86400 * 161),
            onComplete: {}
        )
        .environmentObject(AppearanceManager.shared)
    }
}
