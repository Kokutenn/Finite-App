import SwiftUI
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published var goals: [Goal] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentTime = Date()
    
    private let supabase = SupabaseService.shared
    private var timer: Timer?
    
    init() {
        startTimer()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.currentTime = Date()
            }
        }
    }
    
    func loadGoals(userId: UUID) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            goals = try await supabase.getGoals(forUserId: userId)
            
            // Schedule notifications with updated goals
            let productiveYears = UserDefaults.standard.integer(forKey: "productiveYearsRemaining")
            NotificationService.shared.scheduleAllNotifications(
                for: goals,
                productiveYearsRemaining: productiveYears > 0 ? productiveYears : 30
            )
        } catch {
            errorMessage = "Failed to load goals: \(error.localizedDescription)"
            print("Load goals error: \(error)")
        }
    }
    
    func createGoal(_ goal: Goal) async {
        do {
            try await supabase.createGoal(goal)
            goals.append(goal)
            goals.sort { $0.deadline < $1.deadline }
            
            // Reschedule notifications
            let productiveYears = UserDefaults.standard.integer(forKey: "productiveYearsRemaining")
            NotificationService.shared.scheduleAllNotifications(
                for: goals,
                productiveYearsRemaining: productiveYears > 0 ? productiveYears : 30
            )
        } catch {
            errorMessage = "Failed to create goal: \(error.localizedDescription)"
        }
    }
    
    func deleteGoal(_ goal: Goal) async {
        do {
            try await supabase.deleteGoal(goal.id)
            goals.removeAll { $0.id == goal.id }
            
            // Reschedule notifications
            let productiveYears = UserDefaults.standard.integer(forKey: "productiveYearsRemaining")
            NotificationService.shared.scheduleAllNotifications(
                for: goals,
                productiveYearsRemaining: productiveYears > 0 ? productiveYears : 30
            )
        } catch {
            errorMessage = "Failed to delete goal: \(error.localizedDescription)"
        }
    }
    
    func updateGoal(_ goal: Goal) async {
        do {
            try await supabase.updateGoal(goal)
            if let index = goals.firstIndex(where: { $0.id == goal.id }) {
                goals[index] = goal
            }
        } catch {
            errorMessage = "Failed to update goal: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Year Progress Calculations
    
    var yearProgress: YearProgress {
        YearProgress()
    }
}

struct YearProgress {
    let year: Int
    let dayOfYear: Int
    let daysInYear: Int
    let daysRemaining: Int
    let percentGone: Double
    let percentRemaining: Double
    
    init(date: Date = Date()) {
        let calendar = Calendar.current
        self.year = calendar.component(.year, from: date)
        self.dayOfYear = calendar.ordinality(of: .day, in: .year, for: date) ?? 1
        self.daysInYear = calendar.range(of: .day, in: .year, for: date)?.count ?? 365
        self.daysRemaining = daysInYear - dayOfYear
        self.percentGone = Double(dayOfYear) / Double(daysInYear) * 100
        self.percentRemaining = 100 - percentGone
    }
    
    var urgencyColor: Color {
        let month = Calendar.current.component(.month, from: Date())
        switch month {
        case 1...3: return .green
        case 4...6: return .yellow
        case 7...9: return .orange
        default: return .red
        }
    }
}
