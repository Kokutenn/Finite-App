import Foundation
import UserNotifications

class NotificationService {
    static let shared = NotificationService()
    
    private init() {}
    
    // MARK: - Permission
    
    func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
            return granted
        } catch {
            print("Notification permission error: \(error)")
            return false
        }
    }
    
    func checkPermissionStatus() async -> UNAuthorizationStatus {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus
    }
    
    // MARK: - Schedule Notifications
    
    func scheduleAllNotifications(for goals: [Goal], productiveYearsRemaining: Int) {
        // Clear existing notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        guard !goals.isEmpty else { return }
        
        // Schedule morning notification (8 AM)
        scheduleDailyNotification(
            identifier: "morning",
            hour: 8,
            minute: 0,
            goals: goals,
            productiveYearsRemaining: productiveYearsRemaining,
            category: .timeDecay
        )
        
        // Schedule afternoon notification (2 PM)
        scheduleDailyNotification(
            identifier: "afternoon",
            hour: 14,
            minute: 0,
            goals: goals,
            productiveYearsRemaining: productiveYearsRemaining,
            category: .sunkCost
        )
        
        // Schedule evening notification (7 PM)
        scheduleDailyNotification(
            identifier: "evening",
            hour: 19,
            minute: 0,
            goals: goals,
            productiveYearsRemaining: productiveYearsRemaining,
            category: .yearProgress
        )
    }
    
    private func scheduleDailyNotification(
        identifier: String,
        hour: Int,
        minute: Int,
        goals: [Goal],
        productiveYearsRemaining: Int,
        category: NotificationCategory
    ) {
        let content = UNMutableNotificationContent()
        let message = generateMessage(for: goals, productiveYearsRemaining: productiveYearsRemaining, category: category)
        
        content.title = "⏰ FINITE"
        content.body = message
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            }
        }
    }
    
    // MARK: - Message Generation
    
    enum NotificationCategory {
        case timeDecay
        case yearProgress
        case sunkCost
        case lifeContext
    }
    
    private func generateMessage(for goals: [Goal], productiveYearsRemaining: Int, category: NotificationCategory) -> String {
        guard let primaryGoal = goals.first else {
            return "Time is passing. Set a goal to track."
        }
        
        let timeRemaining = primaryGoal.timeRemaining
        let timeElapsed = primaryGoal.timeElapsed
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let daysInYear = calendar.range(of: .day, in: .year, for: Date())?.count ?? 365
        let percentYearGone = Double(dayOfYear) / Double(daysInYear) * 100
        let daysLeftInYear = daysInYear - dayOfYear
        
        let messages: [String]
        
        switch category {
        case .timeDecay:
            messages = [
                "\(timeRemaining.days) days left. Time's ticking.",
                "\(timeRemaining.formattedHours) hours remaining. Make them count.",
                "You have \(Int(timeRemaining.weeks)) weeks. That's it.",
                "\(timeRemaining.formattedMinutes) minutes left. Each one matters.",
                "Another day gone. \(timeRemaining.days) days left.",
                "\(Int(Double(timeRemaining.days) / Double(daysLeftInYear) * 100))% of your year committed to \"\(primaryGoal.name)\".",
                "\(Int(timeRemaining.weeks)) Mondays remaining. How will you use them?",
                "\(timeRemaining.weekends) weekends left. Will they be productive or wasted?"
            ]
            
        case .yearProgress:
            messages = [
                "\(String(format: "%.1f", percentYearGone))% of \(calendar.component(.year, from: Date())) is already gone. \(daysLeftInYear) days remain.",
                "\(calendar.monthSymbols[calendar.component(.month, from: Date()) - 1]) is slipping away. Time flies.",
                "You have \(daysLeftInYear) days left in \(calendar.component(.year, from: Date())). What will you do with them?",
                "Every day, \(calendar.component(.year, from: Date())) becomes shorter. Make today count."
            ]
            
        case .sunkCost:
            messages = [
                "You've burned through \(timeElapsed.days) days already. Don't waste more. \(timeRemaining.days) left.",
                "\(String(format: "%.1f", timeElapsed.percentElapsed))% of your time is gone. Make the remaining \(String(format: "%.1f", 100 - timeElapsed.percentElapsed))% count.",
                "\(timeElapsed.days) days wasted. \(timeRemaining.days) remaining. Choose wisely.",
                "Time already lost: \(timeElapsed.days) days. Time you still have: \(timeRemaining.days). Act."
            ]
            
        case .lifeContext:
            let totalDays = productiveYearsRemaining * 365
            let percentOfLife = Double(timeRemaining.days) / Double(totalDays) * 100
            messages = [
                "This goal is \(String(format: "%.2f", percentOfLife))% of your remaining productive life.",
                "You have ~\(totalDays.formatted(.number.grouping(.automatic))) days left. \(timeRemaining.days) are for this goal. Worth it?",
                "This deadline = \(timeRemaining.days) of your finite days. Make them matter.",
                "Every day you delay is one less day in your productive life."
            ]
        }
        
        return messages.randomElement() ?? messages[0]
    }
    
    // MARK: - Cancel Notifications
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
}
