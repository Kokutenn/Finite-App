import SwiftUI

struct WelcomeStepView: View {
    let onContinue: () -> Void
    @EnvironmentObject var appearanceManager: AppearanceManager
    
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
            
            // Icon
            Text("⏰")
                .font(.system(size: 80))
                .padding(.bottom, 32)
            
            // Title
            Text("Time Is Running Out")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(theme.primaryText)
                .padding(.bottom, 24)
            
            // Description
            VStack(spacing: 16) {
                Text("This app won't track your habits or celebrate your progress.")
                    .foregroundColor(theme.tertiaryText)
                
                Text("It will constantly remind you how little time you have left.")
                    .foregroundColor(theme.primaryText)
                    .fontWeight(.medium)
                
                Text("That's the point.")
                    .foregroundColor(.red)
                    .fontWeight(.bold)
                    .padding(.top, 8)
            }
            .font(.system(size: 17))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 32)
            
            Spacer()
            
            // Continue button
            Button(action: onContinue) {
                Text("I Understand")
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
        WelcomeStepView(onContinue: {})
            .environmentObject(AppearanceManager.shared)
    }
}
