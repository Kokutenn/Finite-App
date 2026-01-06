import SwiftUI

struct YearProgressCard: View {
    let yearProgress: YearProgress
    @EnvironmentObject var appearanceManager: AppearanceManager
    
    private var theme: Theme {
        Theme(appearance: appearanceManager)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text("\(yearProgress.year) PROGRESS")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(theme.cardSecondaryText)
                .tracking(1.5)
            
            // Progress bar (filling up = time gone)
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.white.opacity(0.2))
                    
                    // Progress (time gone)
                    RoundedRectangle(cornerRadius: 6)
                        .fill(yearProgress.urgencyColor)
                        .frame(width: geometry.size.width * (yearProgress.percentGone / 100))
                }
            }
            .frame(height: 12)
            
            // Stats
            VStack(spacing: 6) {
                Text("\(String(format: "%.1f", yearProgress.percentGone))% GONE")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(theme.cardText)
                
                Text("\(yearProgress.daysRemaining) days remaining")
                    .font(.system(size: 14))
                    .foregroundColor(theme.cardSecondaryText)
            }
            
            // Message
            Text("Every day this bar gets fuller, that's time you'll never get back.")
                .font(.system(size: 13))
                .foregroundColor(theme.cardSecondaryText)
                .multilineTextAlignment(.center)
                .padding(.top, 4)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(theme.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(theme.divider, lineWidth: 1)
                )
        )
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        YearProgressCard(yearProgress: YearProgress())
            .padding()
            .environmentObject(AppearanceManager.shared)
    }
}
