import SwiftUI

@main
struct FiniteApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var appState = AppState()
    @StateObject private var appearanceManager = AppearanceManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .environmentObject(appState)
                .environmentObject(appearanceManager)
                .preferredColorScheme(appearanceManager.currentMode.colorScheme)
        }
    }
}
