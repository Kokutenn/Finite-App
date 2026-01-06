# Finite - Time Pressure App

**MVP v0.5** - A relentless time scarcity reminder app that motivates action through constant awareness of how little time you have left.

## 🎯 Core Concept

Every second you're alive, you have less time. Finite makes this truth visceral, constant, and unavoidable through every interaction with your phone.

## ✨ Features

### Time Pressure at Every Touchpoint
- **Home Screen**: Shows time left in 10+ formats (days, hours, minutes, weeks, % of year, % of life)
- **Notifications**: 3x daily reminders (morning, afternoon, evening) about diminishing time
- **Widgets**: Persistent countdown on your home screen (Battery visual style)
- **App Blocking**: Soft reminders when opening distracting apps

### Onboarding
- Year progress awareness
- Productive years calculation (mortality framing)
- Goal creation with time analysis

### Visual Design
- Dark mode by default (time feels heavier)
- Battery-style countdown visual
- Color-coded urgency (green → yellow → orange → red)
- Pulsing animations for critical deadlines

## 🛠 Tech Stack

- **Frontend**: Swift 5.9+ / SwiftUI
- **Backend**: Supabase (PostgreSQL + Auth)
- **Authentication**: Apple Sign In
- **Widgets**: WidgetKit
- **Notifications**: UserNotifications

## 📁 Project Structure

```
Finite/
├── FiniteApp.swift           # App entry point
├── App/
│   ├── ContentView.swift     # Root view controller
│   └── AppState.swift        # Global app state
├── Models/
│   ├── User.swift
│   ├── Goal.swift
│   └── BlockedApp.swift
├── Views/
│   ├── Auth/
│   │   └── SignInView.swift
│   ├── Onboarding/
│   │   ├── OnboardingContainerView.swift
│   │   ├── WelcomeStepView.swift
│   │   ├── YearContextStepView.swift
│   │   ├── ProductiveYearsStepView.swift
│   │   ├── CreateGoalStepView.swift
│   │   └── CountdownBeginsStepView.swift
│   ├── Home/
│   │   ├── MainTabView.swift
│   │   ├── HomeView.swift
│   │   ├── GoalCardView.swift
│   │   ├── GoalDetailView.swift
│   │   └── YearProgressCard.swift
│   ├── Settings/
│   │   ├── SettingsView.swift
│   │   └── BlockedAppsView.swift
│   └── AppBlocking/
│       └── AppBlockingView.swift
├── ViewModels/
│   ├── AuthViewModel.swift
│   └── HomeViewModel.swift
├── Services/
│   ├── SupabaseService.swift
│   ├── NotificationService.swift
│   └── HapticService.swift
├── Utilities/
│   ├── Extensions.swift
│   └── WidgetDataSync.swift
└── Resources/
    └── Assets.xcassets

FiniteWidget/
└── FiniteWidget.swift        # Widget extension
```

## 🚀 Setup Instructions

### 1. Supabase Setup

Create the following tables in your Supabase project:

```sql
-- Users table
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  apple_id TEXT UNIQUE NOT NULL,
  productive_years_remaining INTEGER NOT NULL DEFAULT 30,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Goals table
CREATE TABLE goals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  deadline TIMESTAMP NOT NULL,
  why_it_matters TEXT,
  what_youll_regret TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Blocked apps table
CREATE TABLE blocked_apps (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  app_bundle_id TEXT NOT NULL,
  app_name TEXT,
  is_enabled BOOLEAN DEFAULT TRUE
);

-- Enable Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE blocked_apps ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can read own data" ON users FOR SELECT USING (true);
CREATE POLICY "Users can insert own data" ON users FOR INSERT WITH CHECK (true);
CREATE POLICY "Users can update own data" ON users FOR UPDATE USING (true);

CREATE POLICY "Users can read own goals" ON goals FOR SELECT USING (true);
CREATE POLICY "Users can insert own goals" ON goals FOR INSERT WITH CHECK (true);
CREATE POLICY "Users can update own goals" ON goals FOR UPDATE USING (true);
CREATE POLICY "Users can delete own goals" ON goals FOR DELETE USING (true);

CREATE POLICY "Users can manage blocked apps" ON blocked_apps FOR ALL USING (true);
```

### 2. Configure Supabase Credentials

Update `SupabaseService.swift` with your credentials:

```swift
let supabaseURL = URL(string: "YOUR_SUPABASE_URL")!
let supabaseKey = "YOUR_SUPABASE_ANON_KEY"
```

### 3. Xcode Setup

1. Open Xcode and create a new iOS App project named "Finite"
2. Add the Supabase Swift package: `https://github.com/supabase/supabase-swift.git`
3. Copy all Swift files from this repo into the project
4. Add Widget Extension target named "FiniteWidget"
5. Configure App Groups: `group.com.finite.app`
6. Enable capabilities:
   - Sign in with Apple
   - Push Notifications
   - App Groups

### 4. Build & Run

```bash
# Open in Xcode
open Finite.xcodeproj

# Or build from command line
xcodebuild -scheme Finite -destination 'platform=iOS Simulator,name=iPhone 15'
```

## 📱 Notification Schedule

- **8:00 AM** - Time decay message (days/hours remaining)
- **2:00 PM** - Sunk cost message (time already wasted)
- **7:00 PM** - Year progress message (% of year gone)

## 🎨 Design System

### Colors
- Background: Pure black (#000000)
- Text: White (#FFFFFF)
- Urgency levels:
  - 75-100% remaining: Green
  - 50-75% remaining: Yellow
  - 25-50% remaining: Orange
  - 0-25% remaining: Red

### Typography
- Primary countdown: 72pt, Bold, Rounded
- Secondary metrics: 17pt, Semibold
- Labels: 13pt, Regular

## 📊 Success Criteria

- [ ] 50+ beta testers
- [ ] 70%+ report "uncomfortably aware of time passing"
- [ ] 60%+ took action due to time pressure
- [ ] <5% crash rate
- [ ] Users open app 3+ times/day

## 🔜 Future (MVP v1.0)

- AI-generated personalized messages
- Chat interface with goal
- "Done for Today" functionality
- Goal archiving/restart
- Premium features
- Sub-goals/milestones

---

**Remember**: Time is the only truly non-renewable resource. Make every day count. ⏰
