import SwiftUI

@MainActor
struct Theme {
    let isDark: Bool
    
    init(appearance: AppearanceManager) {
        self.isDark = appearance.isDarkMode
    }
    
    init(isDark: Bool = true) {
        self.isDark = isDark
    }
    
    // MARK: - Logo
    
    var logoName: String {
        isDark ? "FiniteLogo" : "FiniteLogoLight"
    }
    
    // MARK: - Background Colors
    
    var background: Color {
        isDark ? .black : .white
    }
    
    var secondaryBackground: Color {
        isDark ? Color.white.opacity(0.05) : .black
    }
    
    var cardBackground: Color {
        isDark ? Color.white.opacity(0.1) : .black
    }
    
    var cardStroke: Color {
        isDark ? Color.white.opacity(0.1) : Color.black.opacity(0.2)
    }
    
    // MARK: - Text Colors
    
    var primaryText: Color {
        isDark ? .white : .black
    }
    
    var secondaryText: Color {
        .gray
    }
    
    var tertiaryText: Color {
        isDark ? Color.white.opacity(0.7) : Color.black.opacity(0.7)
    }
    
    var mutedText: Color {
        isDark ? Color.white.opacity(0.5) : Color.black.opacity(0.5)
    }
    
    // Text inside cards (inverted in light mode)
    var cardText: Color {
        isDark ? .white : .white
    }
    
    var cardSecondaryText: Color {
        isDark ? .gray : Color.white.opacity(0.9)
    }
    
    var inputPlaceholder: Color {
        isDark ? Color.white.opacity(0.5) : Color.white.opacity(0.5)
    }
    
    // MARK: - UI Element Colors
    
    var divider: Color {
        isDark ? Color.white.opacity(0.1) : Color.white.opacity(0.3)
    }
    
    var buttonBackground: Color {
        isDark ? .white : .black
    }
    
    var buttonText: Color {
        isDark ? .black : .white
    }
    
    var inputBackground: Color {
        isDark ? Color.white.opacity(0.1) : .black
    }
    
    var inputText: Color {
        isDark ? .white : .white
    }
    
    var tabBarBackground: Color {
        isDark ? Color.white.opacity(0.1) : Color.black.opacity(0.08)
    }
    
    // MARK: - Accent Colors (same in both modes)
    
    static let urgencyGreen = Color.green
    static let urgencyYellow = Color.yellow
    static let urgencyOrange = Color.orange
    static let urgencyRed = Color.red
    static let accent = Color.red
}

// MARK: - Environment Key

@MainActor
private struct ThemeKey: EnvironmentKey {
    static let defaultValue = Theme(isDark: true)
}

extension EnvironmentValues {
    var theme: Theme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}

// MARK: - View Extension for easy access

@MainActor
extension View {
    func themed(_ appearance: AppearanceManager) -> some View {
        self.environment(\.theme, Theme(appearance: appearance))
    }
}
