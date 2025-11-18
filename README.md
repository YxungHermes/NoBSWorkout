# NoBSWorkout - Simple, Fast Workout Tracking for iOS

A no-nonsense workout tracking app built with SwiftUI that prioritizes speed and simplicity. Log sets in seconds, track your PRs automatically, and see your progress over time.

![iOS](https://img.shields.io/badge/iOS-15.0+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)
![SwiftUI](https://img.shields.io/badge/SwiftUI-3.0-green.svg)

## ✨ Features

### 🚀 Lightning-Fast Logging
- Log a set in **≤3 taps** for the same exercise
- One-tap "Copy Last Set" to duplicate weight/reps
- Numeric keypads optimized for quick entry
- Large, thumb-friendly buttons for one-handed use

### 💪 Automatic PR Tracking
- Real-time PR detection when you log sets
- Tracks max weight and estimated 1RM (Epley formula)
- Celebration animations when you hit a new PR
- Full PR history for every exercise

### ⏱️ Built-in Rest Timer
- Quick preset timers (30s, 60s, 90s, 120s, 180s)
- Custom timer option
- Background execution support
- Local notifications when time's up

### 📊 Progress Analytics
- Workout history with detailed stats
- Exercise-specific progress tracking
- Volume calculations (weight × reps)
- Frequency analytics (workouts per week)

### 🎯 Smart Features
- Suggested workout type based on history (Push/Pull/Legs rotation)
- Exercise search and custom exercise creation
- Workout type categorization (Push, Pull, Legs, Upper, Lower, Full Body)
- Seeded database with 25+ common exercises

## 🏗️ Architecture

The app follows **MVVM (Model-View-ViewModel)** architecture with clear separation of concerns:

```
NoBSWorkout/
├── App/                    # App entry point
├── Models/                 # Core Data entities + extensions
├── ViewModels/             # Business logic & state management
├── Views/                  # SwiftUI views
├── Services/               # Reusable business logic
│   ├── CoreData/           # Persistence layer
│   ├── PRCalculatorService # PR detection & calculation
│   └── TimerService        # Rest timer management
├── Utilities/              # Helpers, extensions, constants
└── Resources/              # Assets
```

### Data Model

#### Core Data Entities:
1. **ExerciseTemplate** - Exercise definitions (Bench Press, Squat, etc.)
2. **WorkoutSession** - Individual workout sessions
3. **SetEntry** - Individual sets (weight, reps, RPE)
4. **PersonalRecord** - PR history for each exercise

See `DESIGN.md` for detailed system design documentation.

## 📱 Screens

### Home Screen
- Start workout button
- Suggested workout type
- Recent workout summary
- This week's workout count

### Workout Logging Screen
- Exercise selector with search
- Quick weight/reps input
- Set history for current exercise
- PR celebrations
- Copy last set functionality
- Access to rest timer

### Timer Screen
- Large countdown display
- Preset duration buttons
- Custom time picker
- Play/pause/reset controls
- Add time on the fly

### History Screen
- Grouped workout list (Today, Yesterday, This Week, etc.)
- Filter by workout type
- Workout stats (exercises, sets, duration, volume)
- Tap to see detailed workout view

### PRs Screen
- All exercises with PRs
- Current max weight and estimated 1RM
- Recent PR highlights
- Sort by name, recent PR, or max weight
- Tap for detailed exercise analytics

## 🚀 Getting Started

### Prerequisites

- **macOS** 13.0 or later
- **Xcode** 15.0 or later
- **iOS Simulator** or physical device running iOS 15.0+

### Installation Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/YxungHermes/NoBSWorkout.git
   cd NoBSWorkout
   ```

2. **Open Xcode and create a new project**
   - Open Xcode
   - Select "Create a new Xcode project"
   - Choose "iOS" → "App"
   - Product Name: `NoBSWorkout`
   - Interface: **SwiftUI**
   - Storage: **Core Data** ✅ (Important!)
   - Language: **Swift**
   - Save in the repository root directory

3. **Add the Core Data model**
   - In Xcode, locate the `NoBSWorkout.xcdatamodeld` file
   - Follow the instructions in `NoBSWorkout/NoBSWorkout/Models/CoreDataSchema.md`
   - Create all 4 entities: ExerciseTemplate, WorkoutSession, SetEntry, PersonalRecord
   - Add attributes and relationships as specified

4. **Add all Swift files to the project**
   - In Xcode's Project Navigator, delete the default files except:
     - `Assets.xcassets`
     - `NoBSWorkout.xcdatamodeld`
   - Drag all folders from `NoBSWorkout/NoBSWorkout/` into Xcode
   - Make sure "Copy items if needed" is checked
   - Select "Create groups" (not folder references)
   - Verify all files appear in the Project Navigator

5. **Configure Info.plist**
   Add notification permissions:
   ```xml
   <key>NSUserNotificationsUsageDescription</key>
   <string>NoBSWorkout needs notification permission to alert you when rest timers complete.</string>
   ```

6. **Build and run**
   - Select a simulator or device
   - Press `Cmd+R` or click the Play button
   - The app will launch with seeded exercise data

### File Structure in Xcode

After adding files, your Xcode project should look like this:

```
NoBSWorkout/
├── App/
│   └── NoBSWorkoutApp.swift
├── Models/
│   ├── NoBSWorkout.xcdatamodeld
│   ├── CoreDataSchema.md
│   └── Extensions/
│       ├── ExerciseTemplate+Extensions.swift
│       ├── WorkoutSession+Extensions.swift
│       └── SetEntry+Extensions.swift
├── ViewModels/
│   ├── HomeViewModel.swift
│   ├── WorkoutLoggingViewModel.swift
│   ├── HistoryViewModel.swift
│   ├── PRsViewModel.swift
│   └── ExerciseDetailViewModel.swift
├── Views/
│   ├── Common/
│   │   ├── MainTabView.swift
│   │   └── Components/
│   │       ├── PrimaryButton.swift
│   │       └── NumberInputField.swift
│   ├── Home/
│   │   ├── HomeView.swift
│   │   └── Components/
│   │       └── RecentWorkoutCard.swift
│   ├── Workout/
│   │   ├── WorkoutTypeSelectionView.swift
│   │   ├── WorkoutLoggingView.swift
│   │   ├── ExerciseSelectorView.swift
│   │   └── Components/
│   │       ├── SetRowView.swift
│   │       └── QuickInputView.swift
│   ├── Timer/
│   │   └── TimerView.swift
│   ├── History/
│   │   ├── HistoryView.swift
│   │   ├── WorkoutDetailView.swift
│   │   └── Components/
│   │       └── WorkoutCard.swift
│   └── PRs/
│       ├── PRsView.swift
│       ├── ExerciseDetailView.swift
│       └── Components/
│           └── PRCard.swift
├── Services/
│   ├── CoreData/
│   │   ├── PersistenceController.swift
│   │   └── DataService.swift
│   ├── PRCalculatorService.swift
│   └── TimerService.swift
├── Utilities/
│   ├── Constants.swift
│   ├── Extensions/
│   │   ├── Date+Extensions.swift
│   │   ├── Double+Extensions.swift
│   │   └── View+Extensions.swift
│   └── Helpers/
│       └── HapticManager.swift
└── Resources/
    └── Assets.xcassets
```

## 🎮 Usage

### Starting a Workout

1. Open the app and tap **"Start Workout"**
2. Select a workout type (Push, Pull, Legs, etc.)
3. Tap **"Select Exercise"** to choose or create an exercise
4. Enter weight and reps
5. Tap **"Log Set"**
6. Repeat for all sets

### Quick Logging Tips

- Tap **"Copy Last Set"** to auto-fill the previous set's values
- Inputs stay populated after logging - just adjust and log again
- Swipe to delete a set if you made a mistake
- Use the menu (•••) to access the timer or finish the workout

### Using the Timer

1. After logging a set, access timer from the menu
2. Tap a preset duration (30s, 60s, etc.) or custom time
3. Timer runs in background - you can return to logging
4. Get a notification when time's up

### Tracking Progress

- **History Tab**: See all past workouts, filter by type, tap for details
- **PRs Tab**: View personal records for all exercises
- Tap any exercise to see detailed progress, charts, and history

## 🔧 Customization

### Adding New Workout Types

Edit `Utilities/Constants.swift`:

```swift
enum WorkoutType: String, CaseIterable {
    case push = "Push"
    case pull = "Pull"
    case legs = "Legs"
    case myCustomType = "My Custom Type"  // Add here

    var icon: String {
        switch self {
        case .myCustomType: return "figure.whatever"
        // ...
        }
    }
}
```

### Changing Timer Presets

Edit `Utilities/Constants.swift`:

```swift
struct TimerPresets {
    static let durations = [30, 45, 60, 90, 120, 180] // in seconds
}
```

### Modifying PR Formula

The app uses the Epley formula by default. To change it, edit `Services/PRCalculatorService.swift`:

```swift
func calculateEstimated1RM(weight: Double, reps: Int) -> Double {
    // Current: Epley formula
    return weight * (1.0 + Double(reps) / 30.0)

    // Alternative: Brzycki formula
    // return weight * (36.0 / (37.0 - Double(reps)))
}
```

## 🚀 Future Enhancements

### Easy Additions (v1.1)

- **Dark Mode**: Already supported by SwiftUI
- **Exercise Images**: Add `imageURL` field to ExerciseTemplate
- **Notes on Workouts**: `notes` field already exists in WorkoutSession
- **Export to CSV**: Add export functionality in HistoryViewModel
- **Favorite Exercises**: Toggle `isFavorite` in ExerciseTemplate

### Medium Additions (v1.2)

- **iCloud Sync**
  - Replace `NSPersistentContainer` with `NSPersistentCloudKitContainer`
  - Enable CloudKit in Capabilities
  - Add iCloud entitlements

  ```swift
  // In PersistenceController.swift
  let container = NSPersistentCloudKitContainer(name: "NoBSWorkout")
  ```

- **Charts**
  - Use Swift Charts (iOS 16+)
  - Already have data ready in ViewModels (e.g., `weightProgressionData`)

  ```swift
  import Charts

  Chart(viewModel.weightProgressionData, id: \.date) { item in
      LineMark(
          x: .value("Date", item.date),
          y: .value("Weight", item.weight)
      )
  }
  ```

- **Workout Templates**
  - Create `WorkoutTemplate` entity
  - Link to exercises and suggested sets/reps
  - Quick-start from saved templates

### Major Additions (v2.0)

- **Apple Watch App**
  - Quick set logging from wrist
  - Timer on watch face
  - PR notifications

- **Social Features**
  - Share PRs to social media
  - Friend leaderboards
  - Workout challenges

- **Advanced Analytics**
  - AI-generated insights
  - Muscle group balance analysis
  - Progressive overload tracking
  - Deload week suggestions

- **Exercise Library Enhancements**
  - Video demonstrations
  - Form tips and cues
  - Equipment tagging
  - Alternative exercise suggestions

## 📊 Data & Privacy

- **Local-Only Storage**: All data stored in Core Data on device
- **No Account Required**: No login, no servers, no tracking
- **Your Data, Your Device**: Export functionality coming soon

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Built with ❤️ and SwiftUI
- PR calculation uses the Epley formula
- Designed for lifters, by a lifter

## 📧 Support

Have questions or issues? Open an issue on GitHub!

---

**No BS. Just gains.** 💪
