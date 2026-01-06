import SwiftUI

struct OnboardingContainerView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var appearanceManager: AppearanceManager
    @StateObject private var homeViewModel = HomeViewModel()
    
    @State private var currentStep = 0
    @State private var productiveYears: Int = 30
    @State private var goalName: String = ""
    @State private var goalDeadline: Date = Calendar.current.date(byAdding: .month, value: 6, to: Date()) ?? Date()
    @State private var whyItMatters: String = ""
    @State private var whatYoullRegret: String = ""
    
    private let totalSteps = 5
    
    private var theme: Theme {
        Theme(appearance: appearanceManager)
    }
    
    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()
            
            VStack {
                // Progress indicator
                HStack(spacing: 8) {
                    ForEach(0..<totalSteps, id: \.self) { index in
                        Capsule()
                            .fill(index <= currentStep ? theme.primaryText : theme.cardBackground)
                            .frame(height: 4)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                // Content
                TabView(selection: $currentStep) {
                    WelcomeStepView(onContinue: nextStep)
                        .tag(0)
                    
                    YearContextStepView(onContinue: nextStep)
                        .tag(1)
                    
                    ProductiveYearsStepView(
                        productiveYears: $productiveYears,
                        onContinue: nextStep
                    )
                    .tag(2)
                    
                    CreateGoalStepView(
                        goalName: $goalName,
                        goalDeadline: $goalDeadline,
                        whyItMatters: $whyItMatters,
                        whatYoullRegret: $whatYoullRegret,
                        productiveYears: productiveYears,
                        onContinue: nextStep
                    )
                    .tag(3)
                    
                    CountdownBeginsStepView(
                        goalName: goalName,
                        goalDeadline: goalDeadline,
                        onComplete: completeOnboarding
                    )
                    .tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: currentStep)
            }
            
            DebugThemeToggle()
        }
    }
    
    private func nextStep() {
        if currentStep < totalSteps - 1 {
            withAnimation {
                currentStep += 1
            }
        }
    }
    
    private func previousStep() {
        if currentStep > 0 {
            withAnimation {
                currentStep -= 1
            }
        }
    }
    
    private func completeOnboarding() {
        // Save productive years
        appState.productiveYearsRemaining = productiveYears
        
        // Create goal
        if let userId = authViewModel.currentUserId, !goalName.isEmpty {
            let goal = Goal(
                userId: userId,
                name: goalName,
                deadline: goalDeadline,
                whyItMatters: whyItMatters.isEmpty ? nil : whyItMatters,
                whatYoullRegret: whatYoullRegret.isEmpty ? nil : whatYoullRegret
            )
            
            Task {
                await homeViewModel.createGoal(goal)
                
                // Request notification permission
                _ = await NotificationService.shared.requestPermission()
                
                // Complete onboarding
                appState.completeOnboarding()
            }
        }
    }
}

#Preview {
    OnboardingContainerView()
        .environmentObject(AppState())
        .environmentObject(AuthViewModel())
}
