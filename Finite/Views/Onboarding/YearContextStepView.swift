import SwiftUI

struct YearContextStepView: View {
    let onContinue: () -> Void
    @EnvironmentObject var appearanceManager: AppearanceManager
    
    private let yearProgress = YearProgress()
    
    private var theme: Theme {
        Theme(appearance: appearanceManager)
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
            
            // Title
            VStack(spacing: 8) {
                Text("First, Let's Acknowledge")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(theme.primaryText)
                
                Text("Where We Are")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(theme.primaryText)
            }
            .padding(.bottom, 40)
            
            // Year progress card
            VStack(spacing: 20) {
                Text("\(yearProgress.year) PROGRESS")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(theme.cardSecondaryText)
                    .tracking(1.5)
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.white.opacity(0.2))
                            .frame(height: 12)
                        
                        // Progress (filling up = time gone)
                        RoundedRectangle(cornerRadius: 6)
                            .fill(yearProgress.urgencyColor)
                            .frame(width: geometry.size.width * (yearProgress.percentGone / 100), height: 12)
                    }
                }
                .frame(height: 12)
                
                VStack(spacing: 8) {
                    Text("\(String(format: "%.1f", yearProgress.percentGone))% of the year GONE")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(theme.cardText)
                    
                    Text("\(yearProgress.daysRemaining) days remaining")
                        .font(.system(size: 16))
                        .foregroundColor(theme.cardSecondaryText)
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(theme.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(theme.divider, lineWidth: 1)
                    )
            )
            .padding(.horizontal, 24)
            
            // Message
            Text("You can't get those \(yearProgress.dayOfYear) days back.\nMake the next \(yearProgress.daysRemaining) count.")
                .font(.system(size: 16))
                .foregroundColor(theme.tertiaryText)
                .multilineTextAlignment(.center)
                .padding(.top, 32)
                .padding(.horizontal, 24)
            
            Spacer()
            
            // Continue button
            Button(action: onContinue) {
                Text("Next")
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
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        YearContextStepView(onContinue: {})
            .environmentObject(AppearanceManager.shared)
    }
}
