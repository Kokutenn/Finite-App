import SwiftUI
import Combine

class AppState: ObservableObject {
    @Published var hasCompletedOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
        }
    }
    
    @Published var productiveYearsRemaining: Int {
        didSet {
            UserDefaults.standard.set(productiveYearsRemaining, forKey: "productiveYearsRemaining")
        }
    }
    
    @Published var goals: [Goal] = []
    @Published var currentUser: User?
    
    init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        self.productiveYearsRemaining = UserDefaults.standard.integer(forKey: "productiveYearsRemaining")
        if self.productiveYearsRemaining == 0 {
            self.productiveYearsRemaining = 30
        }
    }
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
    }
    
    func resetOnboarding() {
        hasCompletedOnboarding = false
        goals = []
    }
    
    var totalProductiveDaysRemaining: Int {
        productiveYearsRemaining * 365
    }
    
    var totalProductiveWeeksRemaining: Int {
        productiveYearsRemaining * 52
    }
    
    var totalProductiveMonthsRemaining: Int {
        productiveYearsRemaining * 12
    }
}
