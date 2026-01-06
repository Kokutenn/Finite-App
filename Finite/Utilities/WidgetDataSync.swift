import Foundation
import WidgetKit

/// Handles syncing data between the main app and widgets via App Groups
class WidgetDataSync {
    static let shared = WidgetDataSync()
    
    private let suiteName = "group.com.finite.app"
    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: suiteName)
    }
    
    private init() {}
    
    // MARK: - Sync Goal Data to Widget
    
    func syncGoalToWidget(_ goal: Goal) {
        guard let defaults = sharedDefaults else { return }
        
        defaults.set(goal.name, forKey: "widget_goal_name")
        defaults.set(goal.deadline.timeIntervalSince1970, forKey: "widget_goal_deadline")
        defaults.set(goal.createdAt.timeIntervalSince1970, forKey: "widget_goal_created")
        
        // Refresh widgets
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func syncGoalsToWidget(_ goals: [Goal]) {
        guard let primaryGoal = goals.first else {
            clearWidgetData()
            return
        }
        
        syncGoalToWidget(primaryGoal)
    }
    
    func clearWidgetData() {
        guard let defaults = sharedDefaults else { return }
        
        defaults.removeObject(forKey: "widget_goal_name")
        defaults.removeObject(forKey: "widget_goal_deadline")
        defaults.removeObject(forKey: "widget_goal_created")
        
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    // MARK: - Refresh Widgets
    
    func refreshWidgets() {
        WidgetCenter.shared.reloadAllTimelines()
    }
}
