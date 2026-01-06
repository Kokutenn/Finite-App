import SwiftUI
import AuthenticationServices

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = true
    @Published var currentUserId: UUID?
    @Published var errorMessage: String?
    
    private let supabase = SupabaseService.shared
    
    init() {
        Task {
            await checkAuthStatus()
        }
    }
    
    func checkAuthStatus() async {
        isLoading = true
        defer { isLoading = false }
        
        // Check if we have a stored user ID
        if let storedUserId = UserDefaults.standard.string(forKey: "currentUserId"),
           let userId = UUID(uuidString: storedUserId) {
            self.currentUserId = userId
            self.isAuthenticated = true
        }
    }
    
    func handleSignInWithApple(_ result: Result<ASAuthorization, Error>) async {
        switch result {
        case .success(let authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                let userId = appleIDCredential.user
                
                do {
                    // Check if user exists
                    if let existingUser = try await supabase.getUser(byAppleId: userId) {
                        self.currentUserId = existingUser.id
                        UserDefaults.standard.set(existingUser.id.uuidString, forKey: "currentUserId")
                    } else {
                        // Create new user
                        let newUser = User(
                            appleId: userId,
                            productiveYearsRemaining: 30
                        )
                        try await supabase.createUser(newUser)
                        self.currentUserId = newUser.id
                        UserDefaults.standard.set(newUser.id.uuidString, forKey: "currentUserId")
                    }
                    
                    self.isAuthenticated = true
                    self.errorMessage = nil
                } catch {
                    self.errorMessage = "Failed to sign in: \(error.localizedDescription)"
                    print("Sign in error: \(error)")
                }
            }
            
        case .failure(let error):
            self.errorMessage = "Apple Sign In failed: \(error.localizedDescription)"
            print("Apple Sign In error: \(error)")
        }
    }
    
    func signOut() {
        UserDefaults.standard.removeObject(forKey: "currentUserId")
        UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
        self.currentUserId = nil
        self.isAuthenticated = false
        NotificationService.shared.cancelAllNotifications()
    }
    
    #if DEBUG
    /// Bypass for simulator testing - creates a test user without Apple Sign In
    func simulatorSignIn() async {
        let testAppleId = "simulator_test_user_\(UUID().uuidString.prefix(8))"
        
        do {
            let newUser = User(
                appleId: testAppleId,
                productiveYearsRemaining: 30
            )
            try await supabase.createUser(newUser)
            self.currentUserId = newUser.id
            UserDefaults.standard.set(newUser.id.uuidString, forKey: "currentUserId")
            self.isAuthenticated = true
            self.errorMessage = nil
        } catch {
            self.errorMessage = "Simulator sign in failed: \(error.localizedDescription)"
            print("Simulator sign in error: \(error)")
        }
    }
    #endif
}
