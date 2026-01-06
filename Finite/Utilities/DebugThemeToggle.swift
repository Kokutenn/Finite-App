import SwiftUI

struct DebugThemeToggle: View {
    @EnvironmentObject var appearanceManager: AppearanceManager
    @State private var isExpanded = false
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                
                Button(action: {
                    withAnimation(.spring(response: 0.3)) {
                        appearanceManager.currentMode = appearanceManager.isDarkMode ? .light : .dark
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: appearanceManager.isDarkMode ? "moon.fill" : "sun.max.fill")
                            .font(.system(size: 16, weight: .semibold))
                        
                        Text(appearanceManager.isDarkMode ? "Dark" : "Light")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(appearanceManager.isDarkMode ? Color.purple : Color.orange)
                            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                    )
                }
                .padding(.trailing, 16)
                .padding(.bottom, 80)
            }
        }
    }
}
