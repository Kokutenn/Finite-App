import WidgetKit
import SwiftUI

// MARK: - Timeline Provider
struct FiniteTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> FiniteTimelineEntry {
        FiniteTimelineEntry(
            date: Date(),
            goalName: "Your Goal",
            daysRemaining: 161,
            hoursRemaining: 3864,
            percentRemaining: 75,
            percentOfYear: 44.7,
            urgencyLevel: .medium
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (FiniteTimelineEntry) -> Void) {
        let entry = loadCurrentEntry()
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<FiniteTimelineEntry>) -> Void) {
        let entry = loadCurrentEntry()
        
        // Update every 15 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
    
    private func loadCurrentEntry() -> FiniteTimelineEntry {
        // Load goal data from shared UserDefaults (App Group)
        let sharedDefaults = UserDefaults(suiteName: "group.com.finite.app")
        
        let goalName = sharedDefaults?.string(forKey: "widget_goal_name") ?? "Set a goal"
        let deadlineTimestamp = sharedDefaults?.double(forKey: "widget_goal_deadline") ?? Date().addingTimeInterval(86400 * 30).timeIntervalSince1970
        let createdTimestamp = sharedDefaults?.double(forKey: "widget_goal_created") ?? Date().timeIntervalSince1970
        
        let deadline = Date(timeIntervalSince1970: deadlineTimestamp)
        let created = Date(timeIntervalSince1970: createdTimestamp)
        let now = Date()
        
        // Calculate time remaining
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .hour], from: now, to: deadline)
        let daysRemaining = max(components.day ?? 0, 0)
        let hoursRemaining = daysRemaining * 24 + (components.hour ?? 0)
        
        // Calculate percent remaining
        let totalDays = calendar.dateComponents([.day], from: created, to: deadline).day ?? 1
        let percentRemaining = totalDays > 0 ? Double(daysRemaining) / Double(totalDays) * 100 : 0
        
        // Calculate percent of year
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: now) ?? 1
        let daysInYear = calendar.range(of: .day, in: .year, for: now)?.count ?? 365
        let daysLeftInYear = daysInYear - dayOfYear
        let percentOfYear = daysLeftInYear > 0 ? Double(daysRemaining) / Double(daysLeftInYear) * 100 : 0
        
        // Determine urgency
        let urgency: WidgetUrgencyLevel
        switch percentRemaining {
        case 75...100: urgency = .low
        case 50..<75: urgency = .medium
        case 25..<50: urgency = .high
        default: urgency = .critical
        }
        
        return FiniteTimelineEntry(
            date: now,
            goalName: goalName,
            daysRemaining: daysRemaining,
            hoursRemaining: hoursRemaining,
            percentRemaining: percentRemaining,
            percentOfYear: min(percentOfYear, 100),
            urgencyLevel: urgency
        )
    }
}

// MARK: - Timeline Entry
struct FiniteTimelineEntry: TimelineEntry {
    let date: Date
    let goalName: String
    let daysRemaining: Int
    let hoursRemaining: Int
    let percentRemaining: Double
    let percentOfYear: Double
    let urgencyLevel: WidgetUrgencyLevel
}

enum WidgetUrgencyLevel {
    case low, medium, high, critical
    
    var color: Color {
        switch self {
        case .low: return .green
        case .medium: return .yellow
        case .high: return .orange
        case .critical: return .red
        }
    }
}

// MARK: - Small Widget View (Battery Style)
struct SmallWidgetView: View {
    let entry: FiniteTimelineEntry
    
    var body: some View {
        ZStack {
            Color.black
            
            VStack(spacing: 8) {
                // Battery visual
                BatteryWidgetView(
                    percentRemaining: entry.percentRemaining,
                    urgencyColor: entry.urgencyLevel.color
                )
                .frame(height: 50)
                
                // Days count
                Text("\(entry.daysRemaining)")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("days left")
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
                
                // Goal name (truncated)
                Text(entry.goalName)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(1)
            }
            .padding(12)
        }
    }
}

struct BatteryWidgetView: View {
    let percentRemaining: Double
    let urgencyColor: Color
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 2) {
                // Battery body
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                    
                    RoundedRectangle(cornerRadius: 3)
                        .fill(urgencyColor)
                        .frame(width: max((geometry.size.width - 10) * (percentRemaining / 100), 0))
                        .padding(2)
                }
                .frame(width: geometry.size.width - 6)
                
                // Battery cap
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 4, height: 16)
            }
        }
    }
}

// MARK: - Medium Widget View
struct MediumWidgetView: View {
    let entry: FiniteTimelineEntry
    
    var body: some View {
        ZStack {
            Color.black
            
            HStack(spacing: 16) {
                // Left: Battery + Days
                VStack(spacing: 8) {
                    BatteryWidgetView(
                        percentRemaining: entry.percentRemaining,
                        urgencyColor: entry.urgencyLevel.color
                    )
                    .frame(width: 80, height: 40)
                    
                    Text("\(entry.daysRemaining)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("days left")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                
                // Right: Details
                VStack(alignment: .leading, spacing: 6) {
                    Text(entry.goalName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                    
                    Spacer()
                    
                    detailRow(icon: "clock", text: "\(entry.hoursRemaining.formatted()) hours")
                    detailRow(icon: "calendar", text: "\(String(format: "%.0f", entry.percentOfYear))% of year")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(16)
        }
    }
    
    private func detailRow(icon: String, text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundColor(.gray)
            Text(text)
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.7))
        }
    }
}

// MARK: - Widget Configuration
struct FiniteWidget: Widget {
    let kind: String = "FiniteWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FiniteTimelineProvider()) { entry in
            FiniteWidgetEntryView(entry: entry)
                .containerBackground(.black, for: .widget)
        }
        .configurationDisplayName("Finite Countdown")
        .description("See how much time you have left.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct FiniteWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: FiniteTimelineEntry
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Widget Bundle
@main
struct FiniteWidgetBundle: WidgetBundle {
    var body: some Widget {
        FiniteWidget()
    }
}

#Preview("Small", as: .systemSmall) {
    FiniteWidget()
} timeline: {
    FiniteTimelineEntry(
        date: Date(),
        goalName: "Launch Startup",
        daysRemaining: 161,
        hoursRemaining: 3864,
        percentRemaining: 75,
        percentOfYear: 44.7,
        urgencyLevel: .medium
    )
}

#Preview("Medium", as: .systemMedium) {
    FiniteWidget()
} timeline: {
    FiniteTimelineEntry(
        date: Date(),
        goalName: "Launch Startup",
        daysRemaining: 161,
        hoursRemaining: 3864,
        percentRemaining: 75,
        percentOfYear: 44.7,
        urgencyLevel: .medium
    )
}
