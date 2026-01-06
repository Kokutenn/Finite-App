import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var appearanceManager: AppearanceManager
    @StateObject private var viewModel = HomeViewModel()
    
    @State private var showAddGoal = false
    @State private var selectedGoal: Goal?
    
    private var theme: Theme {
        Theme(appearance: appearanceManager)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                theme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerView
                        
                        // Add goal button (if less than 3 goals)
                        if viewModel.goals.count < 3 {
                            addGoalButton
                        }
                        
                        // Goals list
                        ForEach(viewModel.goals) { goal in
                            GoalCardView(
                                goal: goal,
                                currentTime: viewModel.currentTime,
                                productiveYears: appState.productiveYearsRemaining
                            )
                            .onTapGesture {
                                selectedGoal = goal
                                HapticService.shared.lightTap()
                            }
                        }
                        
                        // Year progress (always visible)
                        YearProgressCard(yearProgress: viewModel.yearProgress)
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }
                .refreshable {
                    if let userId = authViewModel.currentUserId {
                        await viewModel.loadGoals(userId: userId)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showAddGoal) {
                AddGoalSheet(viewModel: viewModel, userId: authViewModel.currentUserId)
            }
            .sheet(item: $selectedGoal) { goal in
                GoalDetailView(
                    goal: goal,
                    currentTime: viewModel.currentTime,
                    productiveYears: appState.productiveYearsRemaining,
                    onDelete: {
                        Task {
                            await viewModel.deleteGoal(goal)
                        }
                        selectedGoal = nil
                    }
                )
            }
            .task {
                if let userId = authViewModel.currentUserId {
                    await viewModel.loadGoals(userId: userId)
                }
            }
            .overlay(DebugThemeToggle())
        }
    }
    
    private var headerView: some View {
        HStack(spacing: 10) {
            Image(theme.logoName)
                .resizable()
                .scaledToFit()
                .frame(height: 42)
            
            Text("FINITE")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(theme.primaryText)
            
            Spacer()
        }
        .padding(.horizontal, 8)
    }
    
    private var addGoalButton: some View {
        Button(action: {
            showAddGoal = true
            HapticService.shared.lightTap()
        }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 20))
                Text("Add Goal")
                    .font(.system(size: 16, weight: .medium))
            }
            .foregroundColor(theme.tertiaryText)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(theme.divider, style: StrokeStyle(lineWidth: 1, dash: [8]))
            )
        }
    }
}

// MARK: - Add Goal Sheet
struct AddGoalSheet: View {
    @ObservedObject var viewModel: HomeViewModel
    let userId: UUID?
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appearanceManager: AppearanceManager
    
    @State private var goalName = ""
    @State private var goalDeadline = Calendar.current.date(byAdding: .month, value: 3, to: Date()) ?? Date()
    @State private var whyItMatters = ""
    @State private var whatYoullRegret = ""
    
    private var theme: Theme {
        Theme(appearance: appearanceManager)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                theme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Goal name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Goal Name")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(theme.secondaryText)
                            
                            TextField("Launch my startup", text: $goalName)
                                .font(.system(size: 17))
                                .foregroundColor(theme.primaryText)
                                .padding(16)
                                .background(theme.cardBackground)
                                .cornerRadius(12)
                        }
                        
                        // Deadline
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Deadline")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(theme.secondaryText)
                            
                            DatePicker(
                                "",
                                selection: $goalDeadline,
                                in: Date()...,
                                displayedComponents: .date
                            )
                            .datePickerStyle(.graphical)
                            .colorScheme(appearanceManager.currentMode.colorScheme)
                        }
                        
                        // Optional fields
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Why this matters (optional)")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(theme.secondaryText)
                            
                            TextField("So I can be my own boss", text: $whyItMatters)
                                .font(.system(size: 17))
                                .foregroundColor(theme.primaryText)
                                .padding(16)
                                .background(theme.cardBackground)
                                .cornerRadius(12)
                        }
                    }
                    .padding(24)
                }
            }
            .navigationTitle("New Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(theme.primaryText)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createGoal()
                    }
                    .foregroundColor(goalName.isEmpty ? theme.secondaryText : theme.primaryText)
                    .fontWeight(.semibold)
                    .disabled(goalName.isEmpty)
                }
            }
        }
    }
    
    private func createGoal() {
        guard let userId = userId, !goalName.isEmpty else { return }
        
        let goal = Goal(
            userId: userId,
            name: goalName,
            deadline: goalDeadline,
            whyItMatters: whyItMatters.isEmpty ? nil : whyItMatters,
            whatYoullRegret: whatYoullRegret.isEmpty ? nil : whatYoullRegret
        )
        
        Task {
            await viewModel.createGoal(goal)
            dismiss()
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthViewModel())
        .environmentObject(AppState())
        .environmentObject(AppearanceManager.shared)
}
