import SwiftUI

enum AppearanceMode: String, CaseIterable {
    case dark = "dark"
    case light = "light"
    
    var displayName: String {
        switch self {
        case .dark: return "Dark"
        case .light: return "Light"
        }
    }
    
    var colorScheme: ColorScheme {
        switch self {
        case .dark: return .dark
        case .light: return .light
        }
    }
}

@MainActor
class AppearanceManager: ObservableObject {
    static let shared = AppearanceManager()
    
    @Published var currentMode: AppearanceMode {
        didSet {
            UserDefaults.standard.set(currentMode.rawValue, forKey: "appearanceMode")
        }
    }
    
    init() {
        if let savedMode = UserDefaults.standard.string(forKey: "appearanceMode"),
           let mode = AppearanceMode(rawValue: savedMode) {
            self.currentMode = mode
        } else {
            self.currentMode = .dark // Default to dark mode
        }
    }
    
    var isDarkMode: Bool {
        currentMode == .dark
    }
    
    func toggle() {
        currentMode = isDarkMode ? .light : .dark
    }
}
