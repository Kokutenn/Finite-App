import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var appearanceManager: AppearanceManager
    
    @State private var notificationsEnabled = true
    @State private var hapticFeedbackEnabled = true
    @State private var soundEffectsEnabled = true
    @State private var showBlockedApps = false
    @State private var showSignOutConfirmation = false
    
    private var theme: Theme {
        Theme(appearance: appearanceManager)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                theme.background.ignoresSafeArea()
                
                List {
                    // Appearance section
                    Section {
                        HStack {
                            Image(systemName: appearanceManager.isDarkMode ? "moon.fill" : "sun.max.fill")
                                .foregroundColor(appearanceManager.isDarkMode ? .purple : .orange)
                            
                            Text("Appearance")
                                .foregroundColor(theme.primaryText)
                            
                            Spacer()
                            
                            Picker("", selection: $appearanceManager.currentMode) {
                                ForEach(AppearanceMode.allCases, id: \.self) { mode in
                                    Text(mode.displayName).tag(mode)
                                }
                            }
                            .pickerStyle(.segmented)
                            .frame(width: 120)
                        }
                        .listRowBackground(theme.cardBackground)
                    } header: {
                        Text("APPEARANCE")
                            .foregroundColor(theme.secondaryText)
                    }
                    
                    // Account section
                    Section {
                        HStack {
                            Text("Signed in with Apple")
                                .foregroundColor(theme.primaryText)
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                        .listRowBackground(theme.cardBackground)
                        
                        Button(action: { showSignOutConfirmation = true }) {
                            Text("Sign Out")
                                .foregroundColor(.red)
                        }
                        .listRowBackground(theme.cardBackground)
                    } header: {
                        Text("ACCOUNT")
                            .foregroundColor(theme.secondaryText)
                    }
                    
                    // Notifications section
                    Section {
                        Toggle(isOn: $notificationsEnabled) {
                            HStack {
                                Image(systemName: "bell.fill")
                                    .foregroundColor(.orange)
                                Text("Enable Notifications")
                                    .foregroundColor(theme.primaryText)
                            }
                        }
                        .listRowBackground(theme.cardBackground)
                        .onChange(of: notificationsEnabled) { _, newValue in
                            handleNotificationToggle(newValue)
                        }
                        
                        if notificationsEnabled {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Notification Schedule")
                                    .foregroundColor(theme.primaryText)
                                Text("• Morning (8 AM)\n• Afternoon (2 PM)\n• Evening (7 PM)")
                                    .font(.system(size: 13))
                                    .foregroundColor(theme.secondaryText)
                            }
                            .listRowBackground(theme.cardBackground)
                        }
                    } header: {
                        Text("NOTIFICATIONS")
                            .foregroundColor(theme.secondaryText)
                    }
                    
                    // App Blocking section
                    Section {
                        NavigationLink(destination: BlockedAppsView()) {
                            HStack {
                                Image(systemName: "hand.raised.fill")
                                    .foregroundColor(.red)
                                Text("Manage Blocked Apps")
                                    .foregroundColor(theme.primaryText)
                            }
                        }
                        .listRowBackground(theme.cardBackground)
                    } header: {
                        Text("APP BLOCKING")
                            .foregroundColor(theme.secondaryText)
                    }
                    
                    // Preferences section
                    Section {
                        Toggle(isOn: $hapticFeedbackEnabled) {
                            HStack {
                                Image(systemName: "hand.tap.fill")
                                    .foregroundColor(.purple)
                                Text("Haptic Feedback")
                                    .foregroundColor(theme.primaryText)
                            }
                        }
                        .listRowBackground(theme.cardBackground)
                        
                        Toggle(isOn: $soundEffectsEnabled) {
                            HStack {
                                Image(systemName: "speaker.wave.2.fill")
                                    .foregroundColor(.blue)
                                Text("Sound Effects")
                                    .foregroundColor(theme.primaryText)
                            }
                        }
                        .listRowBackground(theme.cardBackground)
                    } header: {
                        Text("PREFERENCES")
                            .foregroundColor(theme.secondaryText)
                    }
                    
                    // Your Time section
                    Section {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Productive years left")
                                    .foregroundColor(theme.primaryText)
                                Text("\(appState.totalProductiveDaysRemaining.formatted()) days")
                                    .font(.system(size: 13))
                                    .foregroundColor(theme.secondaryText)
                            }
                            
                            Spacer()
                            
                            Stepper(
                                "\(appState.productiveYearsRemaining)",
                                value: $appState.productiveYearsRemaining,
                                in: 1...80
                            )
                            .labelsHidden()
                            .frame(width: 120)
                        }
                        .listRowBackground(theme.cardBackground)
                    } header: {
                        Text("YOUR TIME")
                            .foregroundColor(theme.secondaryText)
                    }
                    
                    // About section
                    Section {
                        HStack {
                            Text("Version")
                                .foregroundColor(theme.primaryText)
                            Spacer()
                            Text("0.5.0")
                                .foregroundColor(theme.secondaryText)
                        }
                        .listRowBackground(theme.cardBackground)
                        
                        Button(action: {}) {
                            HStack {
                                Text("Privacy Policy")
                                    .foregroundColor(theme.primaryText)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(theme.secondaryText)
                                    .font(.system(size: 12))
                            }
                        }
                        .listRowBackground(theme.cardBackground)
                        
                        Button(action: {}) {
                            HStack {
                                Text("Terms of Service")
                                    .foregroundColor(theme.primaryText)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(theme.secondaryText)
                                    .font(.system(size: 12))
                            }
                        }
                        .listRowBackground(theme.cardBackground)
                        
                        Button(action: {}) {
                            HStack {
                                Image(systemName: "envelope.fill")
                                    .foregroundColor(.blue)
                                Text("Send Feedback")
                                    .foregroundColor(theme.primaryText)
                            }
                        }
                        .listRowBackground(theme.cardBackground)
                    } header: {
                        Text("ABOUT")
                            .foregroundColor(theme.secondaryText)
                    }
                }
                .scrollContentBackground(.hidden)
                .listStyle(.insetGrouped)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .confirmationDialog(
                "Sign Out",
                isPresented: $showSignOutConfirmation,
                titleVisibility: .visible
            ) {
                Button("Sign Out", role: .destructive) {
                    authViewModel.signOut()
                    appState.resetOnboarding()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to sign out?")
            }
        }
    }
    
    private func handleNotificationToggle(_ enabled: Bool) {
        if enabled {
            Task {
                let granted = await NotificationService.shared.requestPermission()
                if !granted {
                    await MainActor.run {
                        notificationsEnabled = false
                    }
                }
            }
        } else {
            NotificationService.shared.cancelAllNotifications()
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthViewModel())
        .environmentObject(AppState())
        .environmentObject(AppearanceManager.shared)
}
