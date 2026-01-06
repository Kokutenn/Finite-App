import SwiftUI

struct BlockedAppsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var appearanceManager: AppearanceManager
    @State private var blockedApps: Set<String> = []
    @State private var isLoading = false
    
    private var theme: Theme {
        Theme(appearance: appearanceManager)
    }
    
    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()
            
            List {
                Section {
                    Text("When you open these apps, you'll see a reminder of how much time you have left.")
                        .font(.system(size: 14))
                        .foregroundColor(theme.secondaryText)
                        .listRowBackground(Color.clear)
                }
                
                Section {
                    ForEach(CommonBlockableApp.all) { app in
                        Button(action: {
                            toggleApp(app)
                            HapticService.shared.selection()
                        }) {
                            HStack {
                                Image(systemName: app.icon)
                                    .font(.system(size: 20))
                                    .foregroundColor(theme.primaryText)
                                    .frame(width: 32)
                                
                                Text(app.name)
                                    .foregroundColor(theme.primaryText)
                                
                                Spacer()
                                
                                Image(systemName: blockedApps.contains(app.bundleId) ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(blockedApps.contains(app.bundleId) ? .green : theme.secondaryText)
                                    .font(.system(size: 22))
                            }
                        }
                        .listRowBackground(theme.cardBackground)
                    }
                } header: {
                    Text("COMMON APPS")
                        .foregroundColor(theme.secondaryText)
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.blue)
                            Text("How it works")
                                .foregroundColor(theme.primaryText)
                                .fontWeight(.medium)
                        }
                        
                        Text("When you open a blocked app, Finite will show you a reminder with all your deadlines and how much time you have left. You can choose to close the app or continue with a 2-minute timer.")
                            .font(.system(size: 13))
                            .foregroundColor(theme.secondaryText)
                    }
                    .listRowBackground(theme.cardBackground)
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.yellow)
                            Text("Note")
                                .foregroundColor(theme.primaryText)
                                .fontWeight(.medium)
                        }
                        
                        Text("Full app blocking requires Screen Time permissions. This is a soft reminder system for MVP.")
                            .font(.system(size: 13))
                            .foregroundColor(theme.secondaryText)
                    }
                    .listRowBackground(theme.cardBackground)
                }
            }
            .scrollContentBackground(.hidden)
            .listStyle(.insetGrouped)
        }
        .navigationTitle("Blocked Apps")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadBlockedApps()
        }
    }
    
    private func toggleApp(_ app: CommonBlockableApp) {
        if blockedApps.contains(app.bundleId) {
            blockedApps.remove(app.bundleId)
        } else {
            blockedApps.insert(app.bundleId)
        }
        saveBlockedApps()
    }
    
    private func loadBlockedApps() {
        if let saved = UserDefaults.standard.array(forKey: "blockedApps") as? [String] {
            blockedApps = Set(saved)
        }
    }
    
    private func saveBlockedApps() {
        UserDefaults.standard.set(Array(blockedApps), forKey: "blockedApps")
    }
}

#Preview {
    NavigationStack {
        BlockedAppsView()
            .environmentObject(AuthViewModel())
            .environmentObject(AppearanceManager.shared)
    }
}
