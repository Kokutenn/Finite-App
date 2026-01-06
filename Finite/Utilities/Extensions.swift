import SwiftUI

// MARK: - Color Extensions
extension Color {
    static let finiteBackground = Color.black
    static let finiteCardBackground = Color.white.opacity(0.05)
    static let finiteBorder = Color.white.opacity(0.1)
    
    static let urgencyGreen = Color.green
    static let urgencyYellow = Color.yellow
    static let urgencyOrange = Color.orange
    static let urgencyRed = Color.red
}

// MARK: - View Extensions
extension View {
    func glassBackground() -> some View {
        self.background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    func cardStyle() -> some View {
        self
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.finiteCardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.finiteBorder, lineWidth: 1)
                    )
            )
    }
    
    func pulsingAnimation(isActive: Bool, scale: CGFloat = 1.05) -> some View {
        self.modifier(PulsingModifier(isActive: isActive, scale: scale))
    }
}

struct PulsingModifier: ViewModifier {
    let isActive: Bool
    let scale: CGFloat
    @State private var isPulsing = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? scale : 1.0)
            .onAppear {
                guard isActive else { return }
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    isPulsing = true
                }
            }
    }
}

// MARK: - Date Extensions
extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date {
        Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: self) ?? self
    }
    
    func daysUntil(_ date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: self.startOfDay, to: date.startOfDay)
        return components.day ?? 0
    }
    
    func hoursUntil(_ date: Date) -> Int {
        let components = Calendar.current.dateComponents([.hour], from: self, to: date)
        return components.hour ?? 0
    }
    
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    
    var isTomorrow: Bool {
        Calendar.current.isDateInTomorrow(self)
    }
    
    var isThisWeek: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .weekOfYear)
    }
    
    var isThisMonth: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .month)
    }
    
    var isThisYear: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .year)
    }
    
    var relativeDescription: String {
        if isToday {
            return "Today"
        } else if isTomorrow {
            return "Tomorrow"
        } else if isThisWeek {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            return formatter.string(from: self)
        } else {
            return self.formatted(date: .abbreviated, time: .omitted)
        }
    }
}

// MARK: - Int Extensions
extension Int {
    var formattedWithCommas: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

// MARK: - String Extensions
extension String {
    var isNotEmpty: Bool {
        !isEmpty
    }
}
