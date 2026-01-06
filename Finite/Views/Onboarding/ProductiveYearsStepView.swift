import SwiftUI

struct ProductiveYearsStepView: View {
    @Binding var productiveYears: Int
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
            
            // Title
            VStack(spacing: 8) {
                Text("How Many Productive Years")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(theme.primaryText)
                
                Text("Do You Have Left?")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(theme.primaryText)
            }
            .padding(.bottom, 16)
            
            // Subtitle
            Text("Be realistic. If you're 28 and expect to stay sharp until 70, that's about 42 years.")
                .font(.system(size: 15))
                .foregroundColor(theme.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            
            // Year picker
            VStack(spacing: 24) {
                HStack(spacing: 20) {
                    // Minus button
                    Button(action: {
                        if productiveYears > 1 {
                            productiveYears -= 1
                            HapticService.shared.lightTap()
                        }
                    }) {
                        Image(systemName: "minus")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(theme.cardText)
                            .frame(width: 56, height: 56)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(28)
                    }
                    
                    // Number display
                    VStack(spacing: 4) {
                        Text("\(productiveYears)")
                            .font(.system(size: 64, weight: .bold, design: .rounded))
                            .foregroundColor(theme.cardText)
                        
                        Text("years")
                            .font(.system(size: 16))
                            .foregroundColor(theme.cardSecondaryText)
                    }
                    .frame(width: 120)
                    
                    // Plus button
                    Button(action: {
                        if productiveYears < 80 {
                            productiveYears += 1
                            HapticService.shared.lightTap()
                        }
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(theme.cardText)
                            .frame(width: 56, height: 56)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(28)
                    }
                }
                
                // Calculations
                VStack(spacing: 12) {
                    Text("That's approximately:")
                        .font(.system(size: 14))
                        .foregroundColor(theme.cardSecondaryText)
                    
                    VStack(spacing: 8) {
                        calculationRow(value: productiveYears * 365, unit: "days")
                        calculationRow(value: productiveYears * 52, unit: "weeks")
                        calculationRow(value: productiveYears * 12, unit: "months")
                    }
                }
                .padding(.top, 8)
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
            Text("Every goal you set is a fraction of this finite time.")
                .font(.system(size: 15))
                .foregroundColor(theme.tertiaryText)
                .multilineTextAlignment(.center)
                .padding(.top, 32)
                .padding(.horizontal, 32)
            
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
    
    private func calculationRow(value: Int, unit: String) -> some View {
        HStack {
            Text("•")
                .foregroundColor(theme.cardSecondaryText)
            Text("\(value.formatted(.number.grouping(.automatic))) \(unit)")
                .foregroundColor(theme.cardText)
            Spacer()
        }
        .font(.system(size: 16))
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        ProductiveYearsStepView(productiveYears: .constant(30), onContinue: {})
            .environmentObject(AppearanceManager.shared)
    }
}
