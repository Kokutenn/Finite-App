import Foundation
import Supabase

class SupabaseService {
    static let shared = SupabaseService()
    
    let client: SupabaseClient
    
    private init() {
        // Configure with your Supabase credentials
        // Create Secrets.swift from Secrets.swift.template with your actual values
        let supabaseURL = URL(string: "https://ffaweygbnomydvqhpgys.supabase.co")!  // e.g., "https://xxxx.supabase.co"
        let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZmYXdleWdibm9teWR2cWhwZ3lzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc2MjQ0MjMsImV4cCI6MjA4MzIwMDQyM30.6QRX1uiC1QwiQO_M3sF8xcZgtof5G-YzP4nW3f4kUzU"
        
        self.client = SupabaseClient(
            supabaseURL: supabaseURL,
            supabaseKey: supabaseKey
        )
    }
    
    // MARK: - User Operations
    
    func createUser(_ user: User) async throws {
        try await client
            .from("users")
            .insert(user)
            .execute()
    }
    
    func getUser(byAppleId appleId: String) async throws -> User? {
        let response: [User] = try await client
            .from("users")
            .select()
            .eq("apple_id", value: appleId)
            .execute()
            .value
        
        return response.first
    }
    
    func updateUser(_ user: User) async throws {
        try await client
            .from("users")
            .update(user)
            .eq("id", value: user.id.uuidString)
            .execute()
    }
    
    // MARK: - Goal Operations
    
    func createGoal(_ goal: Goal) async throws {
        try await client
            .from("goals")
            .insert(goal)
            .execute()
    }
    
    func getGoals(forUserId userId: UUID) async throws -> [Goal] {
        let response: [Goal] = try await client
            .from("goals")
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("deadline", ascending: true)
            .execute()
            .value
        
        return response
    }
    
    func updateGoal(_ goal: Goal) async throws {
        try await client
            .from("goals")
            .update(goal)
            .eq("id", value: goal.id.uuidString)
            .execute()
    }
    
    func deleteGoal(_ goalId: UUID) async throws {
        try await client
            .from("goals")
            .delete()
            .eq("id", value: goalId.uuidString)
            .execute()
    }
    
    // MARK: - Blocked Apps Operations
    
    func createBlockedApp(_ blockedApp: BlockedApp) async throws {
        try await client
            .from("blocked_apps")
            .insert(blockedApp)
            .execute()
    }
    
    func getBlockedApps(forUserId userId: UUID) async throws -> [BlockedApp] {
        let response: [BlockedApp] = try await client
            .from("blocked_apps")
            .select()
            .eq("user_id", value: userId.uuidString)
            .execute()
            .value
        
        return response
    }
    
    func updateBlockedApp(_ blockedApp: BlockedApp) async throws {
        try await client
            .from("blocked_apps")
            .update(blockedApp)
            .eq("id", value: blockedApp.id.uuidString)
            .execute()
    }
    
    func deleteBlockedApp(_ blockedAppId: UUID) async throws {
        try await client
            .from("blocked_apps")
            .delete()
            .eq("id", value: blockedAppId.uuidString)
            .execute()
    }
}
