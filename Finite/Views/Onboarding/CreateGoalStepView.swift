import SwiftUI

struct CreateGoalStepView: View {
    @Binding var goalName: String
    @Binding var goalDeadline: Date
    @Binding var whyItMatters: String
    @Binding var whatYoullRegret: String
    let productiveYears: Int
    let onContinue: () -> Void
    @EnvironmentObject var appearanceManager: AppearanceManager
    
    @State private var showDatePicker = false
    
    private var theme: Theme {
        Theme(appearance: appearanceManager)
    }
    
    private var daysUntilDeadline: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: goalDeadline)
        return max(components.day ?? 0, 0)
    }
    
    private var yearProgress: YearProgress {
        YearProgress()
    }
    
    private var percentOfYear: Double {
        Double(daysUntilDeadline) / Double(yearProgress.daysRemaining) * 100
    }
    
    private var percentOfLife: Double {
        let totalDays = productiveYears * 365
        return Double(daysUntilDeadline) / Double(totalDays) * 100
    }
    
    private var weeksUntilDeadline: Double {
        Double(daysUntilDeadline) / 7.0
    }
    
    private var hoursUntilDeadline: Int {
        daysUntilDeadline * 24
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Logo header
                Image(theme.logoName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 40)
                    .padding(.top, 20)
                    .padding(.bottom, 20)
                
                // Title
                Text("What's Your Deadline?")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(theme.primaryText)
                    .padding(.bottom, 32)
                
                // Goal name field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Goal Name")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(theme.secondaryText)
                    
                    ZStack(alignment: .leading) {
                        if goalName.isEmpty {
                            Text("Launch my startup")
                                .font(.system(size: 17))
                                .foregroundColor(theme.inputPlaceholder)
                                .padding(.horizontal, 16)
                        }
                        TextField("", text: $goalName)
                            .font(.system(size: 17))
                            .foregroundColor(theme.inputText)
                            .padding(16)
                    }
                    .background(theme.inputBackground)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(theme.divider, lineWidth: 1)
                    )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
                
                // Deadline field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Deadline")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(theme.secondaryText)
                    
                    Button(action: { showDatePicker.toggle() }) {
                        HStack {
                            Text(goalDeadline.formatted(date: .long, time: .omitted))
                                .font(.system(size: 17))
                                .foregroundColor(theme.inputText)
                            
                            Spacer()
                            
                            Image(systemName: "calendar")
                                .foregroundColor(theme.cardSecondaryText)
                        }
                        .padding(16)
                        .background(theme.inputBackground)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(theme.divider, lineWidth: 1)
                        )
                    }
                    
                    if showDatePicker {
                        DatePicker(
                            "",
                            selection: $goalDeadline,
                            in: Date()...,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                        .colorScheme(appearanceManager.currentMode.colorScheme)
                        .padding(.top, 8)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
                
                // Time analysis card
                VStack(spacing: 16) {
                    Text("TIME ANALYSIS")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(theme.cardSecondaryText)
                        .tracking(1.5)
                    
                    Text("This goal represents:")
                        .font(.system(size: 15))
                        .foregroundColor(theme.cardSecondaryText)
                    
                    VStack(spacing: 10) {
                        analysisRow(bullet: "•", text: "\(daysUntilDeadline) days (from today)")
                        analysisRow(bullet: "•", text: "\(String(format: "%.1f", percentOfYear))% of your year")
                        analysisRow(bullet: "•", text: "\(String(format: "%.2f", percentOfLife))% of your life")
                        analysisRow(bullet: "•", text: "\(Int(weeksUntilDeadline)) weeks")
                        analysisRow(bullet: "•", text: "\(hoursUntilDeadline.formatted(.number.grouping(.automatic))) hours")
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(theme.secondaryBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(theme.divider, lineWidth: 1)
                        )
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
                
                // Optional fields
                VStack(alignment: .leading, spacing: 8) {
                    Text("Why this matters (optional)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(theme.secondaryText)
                    
                    ZStack(alignment: .leading) {
                        if whyItMatters.isEmpty {
                            Text("So I can be my own boss")
                                .font(.system(size: 17))
                                .foregroundColor(theme.inputPlaceholder)
                                .padding(.horizontal, 16)
                        }
                        TextField("", text: $whyItMatters)
                            .font(.system(size: 17))
                            .foregroundColor(theme.inputText)
                            .padding(16)
                    }
                    .background(theme.inputBackground)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(theme.divider, lineWidth: 1)
                    )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("What you'll regret if you don't (optional)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(theme.secondaryText)
                    
                    ZStack(alignment: .leading) {
                        if whatYoullRegret.isEmpty {
                            Text("Staying stuck in my job")
                                .font(.system(size: 17))
                                .foregroundColor(theme.inputPlaceholder)
                                .padding(.horizontal, 16)
                        }
                        TextField("", text: $whatYoullRegret)
                            .font(.system(size: 17))
                            .foregroundColor(theme.inputText)
                            .padding(16)
                    }
                    .background(theme.inputBackground)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(theme.divider, lineWidth: 1)
                    )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
                
                // Message
                Text("Every day you delay is time you'll never get back.")
                    .font(.system(size: 15))
                    .foregroundColor(.red.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 24)
                
                // Continue button
                Button(action: onContinue) {
                    Text("Create Goal")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(theme.buttonText)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(goalName.isEmpty ? theme.secondaryText : theme.buttonBackground)
                        .cornerRadius(12)
                }
                .disabled(goalName.isEmpty)
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .scrollDismissesKeyboard(.interactively)
    }
    
    private func analysisRow(bullet: String, text: String) -> some View {
        HStack {
            Text(bullet)
                .foregroundColor(theme.cardSecondaryText)
            Text(text)
                .foregroundColor(theme.cardText)
            Spacer()
        }
        .font(.system(size: 15))
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        CreateGoalStepView(
            goalName: .constant("Launch my startup"),
            goalDeadline: .constant(Date().addingTimeInterval(86400 * 161)),
            whyItMatters: .constant(""),
            whatYoullRegret: .constant(""),
            productiveYears: 30,
            onContinue: {}
        )
        .environmentObject(AppearanceManager.shared)
    }
}
