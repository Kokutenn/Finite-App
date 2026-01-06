import UIKit

class HapticService {
    static let shared = HapticService()
    
    private let lightGenerator = UIImpactFeedbackGenerator(style: .light)
    private let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let heavyGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    private let selectionGenerator = UISelectionFeedbackGenerator()
    
    private init() {
        // Prepare generators for faster response
        lightGenerator.prepare()
        mediumGenerator.prepare()
        heavyGenerator.prepare()
    }
    
    func lightTap() {
        lightGenerator.impactOccurred()
    }
    
    func mediumTap() {
        mediumGenerator.impactOccurred()
    }
    
    func heavyTap() {
        heavyGenerator.impactOccurred()
    }
    
    func success() {
        notificationGenerator.notificationOccurred(.success)
    }
    
    func warning() {
        notificationGenerator.notificationOccurred(.warning)
    }
    
    func error() {
        notificationGenerator.notificationOccurred(.error)
    }
    
    func selection() {
        selectionGenerator.selectionChanged()
    }
    
    // Urgency-based haptic feedback
    func urgencyFeedback(for level: UrgencyLevel) {
        switch level {
        case .low:
            lightTap()
        case .medium:
            mediumTap()
        case .high:
            heavyTap()
        case .critical:
            heavyTap()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.heavyTap()
            }
        }
    }
}
