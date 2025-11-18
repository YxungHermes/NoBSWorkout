# NoBSWorkout - System Design Document

## Overview
NoBSWorkout is a simple, fast workout tracking app for iOS that prioritizes speed and ease of use. The core philosophy is to minimize taps and maximize the speed of logging workouts while automatically tracking progress and personal records.

## Architecture

### Pattern: MVVM (Model-View-ViewModel)
- **Models**: Core Data entities (ExerciseTemplate, WorkoutSession, SetEntry, PersonalRecord)
- **ViewModels**: Business logic, data formatting, and state management
- **Views**: SwiftUI views that observe ViewModels
- **Services**: Reusable business logic (data persistence, PR calculations, timer management)

### Data Flow
```
User Input → View → ViewModel → Service → Core Data
                ↑                           ↓
                └─────── ObservableObject ←──┘
```

## Core Screens & Navigation

### 1. Home Screen (`HomeView`)
**Purpose**: Quick access to start workout and view recent activity

**Components**:
- **Start Workout Button**: Primary CTA, large and prominent
- **Recent Workout Summary**: Shows last workout date, type, and exercises
- **Today's Split Suggestion**: Simple badge showing recommended workout type
- **Navigation Tabs**: Home, History, PRs

**ViewModel**: `HomeViewModel`
- Fetches most recent workout
- Calculates suggested workout based on history (e.g., if last was Push, suggest Pull)
- Provides formatted data for display

**User Flow**:
1. User opens app → sees Home screen
2. Taps "Start Workout" → navigates to WorkoutTypeSelectionView
3. Or taps bottom tabs to see History/PRs

### 2. Workout Type Selection (`WorkoutTypeSelectionView`)
**Purpose**: Quick selection of workout category

**Components**:
- Grid of workout type buttons (Push, Pull, Legs, Upper, Lower, Full Body, Custom)
- Each button shows last workout date for that type

**User Flow**:
1. User taps workout type
2. Navigates to WorkoutLoggingView with selected type

### 3. Workout Logging Screen (`WorkoutLoggingView`)
**Purpose**: The main logging interface - optimized for speed and one-handed use

**Layout** (from top to bottom):
- **Header**: Current exercise name, workout type, session time elapsed
- **Exercise Selector**: Dropdown/button to change current exercise or add new
- **Sets Table**: List of completed sets with weight/reps/PR badge
- **Current Set Input**:
  - Weight input (numeric keypad)
  - Reps input (numeric keypad)
  - RPE slider (optional, can be hidden)
- **Action Buttons**:
  - "Copy Last Set" (quick button)
  - "Log Set" (large primary button)
  - "Start Rest Timer" (appears after logging set)
- **Bottom Bar**: Quick access to timer, finish workout

**ViewModel**: `WorkoutLoggingViewModel`
- Manages current workout session
- Handles set logging and validation
- Checks for PRs in real-time
- Manages exercise list and current exercise
- Provides "copy last set" functionality

**User Flow** (Critical Path - optimized for speed):
1. User completes a set in the gym
2. Opens app (already on logging screen or taps to return)
3. If exercise is already selected:
   - Optionally taps "Copy Last Set" (auto-fills weight/reps)
   - Adjusts weight/reps if needed (big number pads)
   - Taps "Log Set" (or Enter)
   - If PR detected, sees quick "🎉 New PR!" animation
   - Optionally taps rest timer preset (60s, 90s, etc.)
4. If changing exercise:
   - Taps exercise selector
   - Searches or scrolls to find exercise (or creates new)
   - Returns to logging
   - Logs set as above

**Optimization Notes**:
- Numeric inputs should auto-focus and show keypad
- "Copy Last Set" should be accessible with thumb on larger phones
- Logging a set should be ≤3 taps for same exercise
- Exercise switching should be ≤2 taps for recent exercises

### 4. Timer Screen (`TimerView`)
**Purpose**: Clean, distraction-free rest timer

**Layout**:
- **Large countdown display**: 2:00, 1:59, 1:58...
- **Preset buttons**: 30s, 60s, 90s, 120s
- **Custom time picker**: For non-standard rest times
- **Start/Pause/Reset controls**
- **Background notifications**: Alert when time's up (local notification)

**ViewModel**: `TimerViewModel`
- Manages countdown state
- Handles background timing (app can be backgrounded)
- Triggers local notifications

**User Flow**:
1. After logging a set, user taps "Start 90s Timer"
2. Timer appears as overlay or full screen
3. User can minimize/dismiss and it runs in background
4. User gets notification when complete

### 5. History Screen (`HistoryView`)
**Purpose**: Review past workouts

**Layout**:
- **Workout List**: Grouped by date (Today, Yesterday, This Week, etc.)
- Each workout card shows:
  - Date and time
  - Workout type
  - Exercise count
  - Total volume (optional)
  - PRs earned (badge count)
- **Filter options**: By workout type, date range

**ViewModel**: `HistoryViewModel`
- Fetches workout sessions from Core Data
- Groups by date
- Calculates summary stats

**User Flow**:
1. User taps "History" tab
2. Scrolls through past workouts
3. Taps a workout → navigates to WorkoutDetailView

### 6. Workout Detail View (`WorkoutDetailView`)
**Purpose**: See full details of a past workout

**Layout**:
- Workout metadata (date, type, duration)
- List of exercises with all sets
- Highlight PRs achieved
- Notes (if any)

### 7. PRs Screen (`PRsView`)
**Purpose**: View and celebrate progress

**Layout**:
- **Exercise List**: All exercises user has performed
- For each exercise:
  - Current max weight
  - Current estimated 1RM
  - Date of PR
  - Small trend indicator (↑ improving, → plateau, ↓ decreasing)
- **Tap exercise**: Navigate to ExerciseDetailView

**ViewModel**: `PRsViewModel`
- Fetches all PersonalRecord entries
- Groups by exercise
- Provides formatted display data

### 8. Exercise Detail View (`ExerciseDetailView`)
**Purpose**: Deep dive into a single exercise's progress

**Layout**:
- Exercise name and muscle group
- Current PRs
- **Chart**: Weight over time (simple line chart)
- **Chart**: Volume over time (sets × reps × weight)
- **Recent sets table**: Last 10-20 logged sets

**ViewModel**: `ExerciseDetailViewModel`
- Fetches all SetEntry records for exercise
- Calculates volume and trends
- Prepares chart data

## Data Model (Core Data)

### Entity: `ExerciseTemplate`
Represents a type of exercise (e.g., "Barbell Bench Press")

**Attributes**:
- `id`: UUID (primary key)
- `name`: String (e.g., "Barbell Bench Press")
- `muscleGroup`: String (e.g., "Chest", "Back", "Legs")
- `category`: String (e.g., "Push", "Pull", "Legs")
- `isFavorite`: Bool (for quick access)
- `isCustom`: Bool (user-created vs. built-in)
- `notes`: String (optional, user notes)
- `createdDate`: Date

**Relationships**:
- `sets`: One-to-many → SetEntry
- `personalRecords`: One-to-many → PersonalRecord

### Entity: `WorkoutSession`
Represents a single workout session

**Attributes**:
- `id`: UUID (primary key)
- `date`: Date
- `workoutType`: String (e.g., "Push", "Pull", "Legs")
- `startTime`: Date
- `endTime`: Date (optional, when user finishes)
- `notes`: String (optional)

**Relationships**:
- `sets`: One-to-many → SetEntry

**Computed Properties** (in ViewModel or extension):
- `duration`: endTime - startTime
- `totalVolume`: sum of (weight × reps) for all sets
- `exerciseCount`: distinct count of exercises

### Entity: `SetEntry`
Represents a single set within a workout

**Attributes**:
- `id`: UUID (primary key)
- `setNumber`: Int (1, 2, 3... within the exercise)
- `weight`: Double (in kg or lbs)
- `reps`: Int
- `rpe`: Double (optional, 1-10 scale)
- `timestamp`: Date (when logged)
- `isPR`: Bool (flag for easy querying)

**Relationships**:
- `workoutSession`: Many-to-one → WorkoutSession
- `exercise`: Many-to-one → ExerciseTemplate

### Entity: `PersonalRecord`
Tracks PRs for each exercise

**Attributes**:
- `id`: UUID (primary key)
- `recordType`: String (e.g., "max_weight", "max_reps", "estimated_1rm")
- `value`: Double (the record value)
- `reps`: Int (optional, context for the record)
- `dateAchieved`: Date
- `setEntryId`: UUID (reference to the set that achieved this PR)

**Relationships**:
- `exercise`: Many-to-one → ExerciseTemplate

**PR Tracking Logic**:
- When a set is logged, check against existing PRs
- **Max Weight PR**: If weight for any rep count is higher than previous max
- **Estimated 1RM**: Calculate using Epley formula: `weight × (1 + reps/30)`
- Update PersonalRecord entity if new PR achieved
- Set `isPR` flag on the SetEntry

## Services Layer

### `DataService`
**Purpose**: Centralized Core Data operations

**Methods**:
- `fetchExercises(searchTerm: String?, category: String?) -> [ExerciseTemplate]`
- `createExercise(name: String, muscleGroup: String, category: String) -> ExerciseTemplate`
- `fetchWorkoutSessions(limit: Int?, workoutType: String?) -> [WorkoutSession]`
- `createWorkoutSession(workoutType: String) -> WorkoutSession`
- `finishWorkoutSession(session: WorkoutSession)`
- `logSet(session: WorkoutSession, exercise: ExerciseTemplate, weight: Double, reps: Int, rpe: Double?) -> SetEntry`
- `fetchPRs(for exercise: ExerciseTemplate) -> [PersonalRecord]`
- `fetchRecentSets(for exercise: ExerciseTemplate, limit: Int) -> [SetEntry]`

**Implementation Notes**:
- Uses `NSFetchedResultsController` for live updates
- All operations on background context for performance
- Publishes changes via Combine for ViewModel observation

### `PRCalculatorService`
**Purpose**: Calculate and check for personal records

**Methods**:
- `checkForPR(exercise: ExerciseTemplate, weight: Double, reps: Int) -> PRResult`
- `calculateEstimated1RM(weight: Double, reps: Int) -> Double`
- `updatePRs(for setEntry: SetEntry)`

**PR Logic**:
```swift
// Epley formula for 1RM estimation
estimated1RM = weight × (1 + reps / 30)

// Check for max weight PR
if weight > previousMaxWeight:
    create new PersonalRecord(type: "max_weight", value: weight)

// Check for estimated 1RM PR
if estimated1RM > previousBest1RM:
    create new PersonalRecord(type: "estimated_1rm", value: estimated1RM)
```

### `TimerService`
**Purpose**: Manage rest timer with background support

**Methods**:
- `startTimer(duration: Int)`: Start countdown
- `pauseTimer()`: Pause countdown
- `resetTimer()`: Reset to initial duration
- `scheduleNotification(for duration: Int)`: Schedule local notification

**Properties**:
- `@Published var timeRemaining: Int`
- `@Published var isRunning: Bool`

**Implementation Notes**:
- Uses `Timer.publish()` with Combine
- Requests notification permissions on first use
- Continues in background using `BackgroundTasks` framework

## Data Persistence Strategy

### Core Data Stack
- **Container**: `NSPersistentContainer` with name "NoBSWorkout"
- **Model file**: `NoBSWorkout.xcdatamodeld`
- **Store type**: SQLite
- **Location**: App's documents directory (local-only in v1)

### Seeding Initial Data
On first launch, seed common exercises:
```swift
let defaultExercises = [
    ("Barbell Bench Press", "Chest", "Push"),
    ("Barbell Squat", "Legs", "Legs"),
    ("Barbell Deadlift", "Back", "Pull"),
    ("Barbell Overhead Press", "Shoulders", "Push"),
    ("Barbell Row", "Back", "Pull"),
    // ... more common exercises
]
```

## UI/UX Design Principles

### Speed Optimizations
1. **Auto-focus inputs**: When logging screen appears, weight input is auto-focused
2. **Smart defaults**: "Copy Last Set" pre-fills values
3. **Large tap targets**: All buttons minimum 44x44pt
4. **Minimal navigation**: Stay on logging screen during entire workout
5. **Keyboard shortcuts**: Support for external keyboards (future)

### One-Handed Usability
- All primary actions reachable in bottom 2/3 of screen
- Number pads positioned for thumb access
- Swipe gestures for secondary actions (e.g., swipe to delete set)

### Visual Feedback
- **PR Achievement**: Confetti animation + haptic feedback + "🎉 New PR!" badge
- **Set Logged**: Quick checkmark animation + haptic
- **Timer Complete**: Sound + vibration + notification

### Performance Considerations
- Lazy loading for history lists (pagination)
- Image caching for any future exercise images
- Debounced search for exercise selection
- Background context for Core Data operations

## Extension Ideas (Post-V1)

### iCloud Sync
- Use `NSPersistentCloudKitContainer` instead of `NSPersistentContainer`
- Enable CloudKit capability in Xcode
- Add iCloud entitlements
- Minimal code changes required for sync across devices

### Advanced Analytics
- **Charts**: Use Swift Charts (iOS 16+) for beautiful visualizations
- **Metrics**:
  - Total volume per workout type over time
  - Frequency analysis (workouts per week)
  - Muscle group balance (are you neglecting anything?)
  - Rest time analysis
  - RPE trends
- **Insights**: AI-generated suggestions based on patterns

### Workout Templates
- Save workout sessions as templates
- Quick-start from template
- Suggested templates based on goals (strength, hypertension, endurance)

### Social Features
- Share PR achievements
- Compare with friends
- Leaderboards for motivation

### Exercise Library Enhancements
- Exercise videos/GIFs
- Form tips and cues
- Equipment tagging
- Alternative exercises suggestions

### Export & Backup
- Export workout data as CSV
- PDF workout summaries
- Integration with Apple Health

### Apple Watch App
- Quick set logging from watch
- Rest timer on wrist
- PR notifications

## File Structure
```
NoBSWorkout/
├── NoBSWorkout.xcodeproj
├── NoBSWorkout/
│   ├── App/
│   │   ├── NoBSWorkoutApp.swift          # App entry point
│   │   └── AppDelegate.swift             # App lifecycle (if needed)
│   ├── Models/
│   │   ├── NoBSWorkout.xcdatamodeld      # Core Data model
│   │   └── Extensions/
│   │       ├── ExerciseTemplate+Extensions.swift
│   │       ├── WorkoutSession+Extensions.swift
│   │       └── SetEntry+Extensions.swift
│   ├── ViewModels/
│   │   ├── HomeViewModel.swift
│   │   ├── WorkoutLoggingViewModel.swift
│   │   ├── TimerViewModel.swift
│   │   ├── HistoryViewModel.swift
│   │   ├── PRsViewModel.swift
│   │   └── ExerciseDetailViewModel.swift
│   ├── Views/
│   │   ├── Home/
│   │   │   ├── HomeView.swift
│   │   │   └── Components/
│   │   │       └── RecentWorkoutCard.swift
│   │   ├── Workout/
│   │   │   ├── WorkoutTypeSelectionView.swift
│   │   │   ├── WorkoutLoggingView.swift
│   │   │   ├── ExerciseSelectorView.swift
│   │   │   └── Components/
│   │   │       ├── SetRowView.swift
│   │   │       └── QuickInputView.swift
│   │   ├── Timer/
│   │   │   └── TimerView.swift
│   │   ├── History/
│   │   │   ├── HistoryView.swift
│   │   │   ├── WorkoutDetailView.swift
│   │   │   └── Components/
│   │   │       └── WorkoutCard.swift
│   │   ├── PRs/
│   │   │   ├── PRsView.swift
│   │   │   ├── ExerciseDetailView.swift
│   │   │   └── Components/
│   │   │       ├── PRCard.swift
│   │   │       └── ProgressChart.swift
│   │   └── Common/
│   │       ├── MainTabView.swift
│   │       └── Components/
│   │           ├── PrimaryButton.swift
│   │           └── NumberInputField.swift
│   ├── Services/
│   │   ├── CoreData/
│   │   │   ├── PersistenceController.swift
│   │   │   └── DataService.swift
│   │   ├── PRCalculatorService.swift
│   │   └── TimerService.swift
│   ├── Resources/
│   │   ├── Assets.xcassets
│   │   └── SeedData.json
│   └── Utilities/
│       ├── Constants.swift
│       ├── Extensions/
│       │   ├── Date+Extensions.swift
│       │   ├── Double+Extensions.swift
│       │   └── View+Extensions.swift
│       └── Helpers/
│           └── HapticManager.swift
└── README.md
```

## Development Phases

### Phase 1: Core Infrastructure ✓
- Set up Xcode project
- Create Core Data model
- Implement PersistenceController
- Build DataService
- Seed initial exercises

### Phase 2: Workout Logging (MVP)
- WorkoutLoggingView + ViewModel
- Basic set entry (weight + reps)
- Exercise selection
- Save to Core Data

### Phase 3: PR Tracking
- PRCalculatorService
- Real-time PR detection
- PR notifications/animations
- PersonalRecord storage

### Phase 4: Timer
- TimerView + ViewModel
- Preset timers
- Background execution
- Local notifications

### Phase 5: History & Analytics
- HistoryView
- WorkoutDetailView
- PRsView
- Basic charts

### Phase 6: Polish
- Animations and haptics
- Dark mode support
- Accessibility
- Performance optimization
- Bug fixes

---

**Design Philosophy**: No BS. Fast logging. Clear progress. Everything else is secondary.
