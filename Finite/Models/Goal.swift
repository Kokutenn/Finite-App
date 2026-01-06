import Foundation
import SwiftUI

struct Goal: Codable, Identifiable {
    let id: UUID
    var userId: UUID
    var name: String
    var deadline: Date
    var whyItMatters: String?
    var whatYoullRegret: String?
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case deadline
        case whyItMatters = "why_it_matters"
        case whatYoullRegret = "what_youll_regret"
        case createdAt = "created_at"
    }
    
    init(
        id: UUID = UUID(),
        userId: UUID,
        name: String,
        deadline: Date,
        whyItMatters: String? = nil,
        whatYoullRegret: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.name = name
        self.deadline = deadline
        self.whyItMatters = whyItMatters
        self.whatYoullRegret = whatYoullRegret
        self.createdAt = createdAt
    }
}

// MARK: - Time Calculations
extension Goal {
    var timeRemaining: TimeRemaining {
        TimeRemaining(from: Date(), to: deadline)
    }
    
    var timeElapsed: TimeElapsed {
        TimeElapsed(from: createdAt, to: Date(), deadline: deadline)
    }
    
    var urgencyLevel: UrgencyLevel {
        let percentRemaining = timeRemaining.percentRemaining(totalDays: daysBetween(createdAt, deadline))
        return UrgencyLevel.from(percentRemaining: percentRemaining)
    }
    
    private func daysBetween(_ start: Date, _ end: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: start, to: end)
        return max(components.day ?? 0, 1)
    }
}

// MARK: - Time Remaining
struct TimeRemaining {
    let days: Int
    let hours: Int
    let minutes: Int
    let seconds: Int
    let totalHours: Int
    let totalMinutes: Int
    let totalSeconds: Int
    let weeks: Double
    let months: Double
    let weekdays: Int
    let weekends: Int
    
    init(from start: Date, to end: Date) {
        let calendar = Calendar.current
        let now = start
        let components = calendar.dateComponents([.day, .hour, .minute, .second], from: now, to: end)
        
        self.days = max(components.day ?? 0, 0)
        self.hours = max(components.hour ?? 0, 0)
        self.minutes = max(components.minute ?? 0, 0)
        self.seconds = max(components.second ?? 0, 0)
        
        let totalSecondsCalc = max(Int(end.timeIntervalSince(now)), 0)
        self.totalSeconds = totalSecondsCalc
        self.totalMinutes = totalSecondsCalc / 60
        self.totalHours = totalSecondsCalc / 3600
        
        self.weeks = Double(self.days) / 7.0
        self.months = Double(self.days) / 30.44
        
        // Calculate weekdays and weekends
        var weekdayCount = 0
        var weekendCount = 0
        var currentDate = now
        while currentDate < end {
            let weekday = calendar.component(.weekday, from: currentDate)
            if weekday == 1 || weekday == 7 {
                weekendCount += 1
            } else {
                weekdayCount += 1
            }
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? end
        }
        self.weekdays = weekdayCount
        self.weekends = weekendCount / 2
    }
    
    func percentRemaining(totalDays: Int) -> Double {
        guard totalDays > 0 else { return 0 }
        return min(Double(days) / Double(totalDays) * 100, 100)
    }
    
    var formattedCountdown: String {
        if days > 0 {
            return "\(days) days \(hours)h \(minutes)m \(seconds)s"
        } else if hours > 0 {
            return "\(hours)h \(minutes)m \(seconds)s"
        } else if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }
    
    var formattedDays: String {
        "\(days)"
    }
    
    var formattedHours: String {
        "\(totalHours.formatted(.number.grouping(.automatic)))"
    }
    
    var formattedMinutes: String {
        "\(totalMinutes.formatted(.number.grouping(.automatic)))"
    }
    
    var formattedSeconds: String {
        "\(totalSeconds.formatted(.number.grouping(.automatic)))"
    }
    
    var formattedWeeks: String {
        String(format: "%.1f", weeks)
    }
    
    var formattedMonths: String {
        String(format: "%.1f", months)
    }
}

// MARK: - Time Elapsed
struct TimeElapsed {
    let days: Int
    let percentElapsed: Double
    
    init(from start: Date, to now: Date, deadline: Date) {
        let calendar = Calendar.current
        let elapsedComponents = calendar.dateComponents([.day], from: start, to: now)
        let totalComponents = calendar.dateComponents([.day], from: start, to: deadline)
        
        self.days = max(elapsedComponents.day ?? 0, 0)
        let totalDays = max(totalComponents.day ?? 1, 1)
        self.percentElapsed = min(Double(self.days) / Double(totalDays) * 100, 100)
    }
}

// MARK: - Urgency Level
enum UrgencyLevel {
    case low        // 75-100% remaining (green)
    case medium     // 50-75% remaining (yellow)
    case high       // 25-50% remaining (orange)
    case critical   // 0-25% remaining (red)
    
    static func from(percentRemaining: Double) -> UrgencyLevel {
        switch percentRemaining {
        case 75...100: return .low
        case 50..<75: return .medium
        case 25..<50: return .high
        default: return .critical
        }
    }
    
    var color: Color {
        switch self {
        case .low: return .green
        case .medium: return .yellow
        case .high: return .orange
        case .critical: return .red
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .low: return Color.green.opacity(0.15)
        case .medium: return Color.yellow.opacity(0.15)
        case .high: return Color.orange.opacity(0.15)
        case .critical: return Color.red.opacity(0.15)
        }
    }
    
    var icon: String {
        switch self {
        case .low: return "🟢"
        case .medium: return "🟡"
        case .high: return "🟠"
        case .critical: return "🔴"
        }
    }
    
    var pulseAnimation: Bool {
        self == .critical || self == .high
    }
}
