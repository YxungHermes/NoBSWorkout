# NoBSWorkout 💪

A fast, simple, and effective workout tracking app for iOS. No BS - just log your workouts and track your progress.

## Features ✨

- **Lightning-Fast Logging**: Log sets in 3 taps or less
- **Automatic PR Tracking**: Celebrates your personal records automatically
- **Smart Workout Suggestions**: Suggests your next workout based on history
- **Clean History**: Review all your past workouts
- **PR Dashboard**: See all your personal records in one place
- **Pre-loaded Exercises**: 24+ common exercises included
- **Custom Exercises**: Add your own exercises anytime

## Tech Stack 🛠

- **Language**: Swift 5.9+
- **UI Framework**: SwiftUI
- **Persistence**: Core Data
- **Architecture**: MVVM
- **Minimum iOS Version**: iOS 17.0+

## Getting Started 🚀

### Prerequisites

- Xcode 15.0 or later
- iOS 17.0+ device or simulator
- macOS Sonoma or later

### Installation

1. **Clone or download this repository**

2. **Create an Xcode project**:
   - Open Xcode
   - File → New → Project
   - Choose "iOS" → "App"
   - Product Name: `NoBSWorkout`
   - Interface: SwiftUI
   - Storage: Core Data (Important!)
   - Click "Next" and choose a location

3. **Add the source files**:
   - Copy all the `.swift` files from this repository into your Xcode project
   - Make sure to organize them according to the folder structure:
     - `App/`
     - `Models/`
     - `ViewModels/`
     - `Views/`
     - `Services/`
     - `Utilities/`

4. **Set up Core Data**:
   - Replace the default `.xcdatamodeld` file with the one provided
   - Make sure the model name is `NoBSWorkout.xcdatamodeld`

5. **Build and Run**:
   - Select your target device (simulator or physical device)
   - Press Cmd+R or click the Play button
   - The app will launch with pre-seeded exercises!

## Project Structure 📁

```
NoBSWorkout/
├── App/
│   └── NoBSWorkoutApp.swift              # App entry point
├── Models/
│   ├── NoBSWorkout.xcdatamodeld/         # Core Data model
│   ├── ExerciseTemplate+CoreData...      # Exercise entity
│   ├── WorkoutSession+CoreData...        # Workout session entity
│   ├── SetEntry+CoreData...              # Set entry entity
│   └── PersonalRecord+CoreData...        # PR entity
├── ViewModels/
│   ├── HomeViewModel.swift               # Home screen logic
│   └── WorkoutLoggingViewModel.swift     # Workout logging logic
├── Views/
│   ├── Common/
│   │   └── MainTabView.swift             # Main tab navigation
│   ├── Home/
│   │   └── HomeView.swift                # Home screen
│   ├── Workout/
│   │   ├── WorkoutTypeSelectionView.swift
│   │   ├── WorkoutLoggingView.swift      # Main logging screen
│   │   └── ExerciseSelectorView.swift
│   ├── History/
│   │   ├── HistoryView.swift             # Workout history
│   │   └── WorkoutDetailView.swift       # Individual workout details
│   └── PRs/
│       └── PRsView.swift                 # Personal records
├── Services/
│   └── CoreData/
│       └── PersistenceController.swift   # Core Data stack
└── Utilities/
    └── Constants.swift                   # App constants
```

## Usage Guide 📖

### Starting a Workout

1. Open the app
2. Tap "Start Workout"
3. Select your workout type (Push/Pull/Legs/etc.)
4. You'll land on the workout logging screen

### Logging Sets

1. Select an exercise (or keep the pre-selected one)
2. Enter weight and reps
3. Tap "Log Set"
4. Repeat for each set
5. Change exercises as needed
6. Tap "Finish" when done

### Quick Features

- **Copy Last Set**: Tap the "Copy Last" button to auto-fill weight and reps from your previous set
- **PR Detection**: The app automatically detects and celebrates new personal records
- **Smart Suggestions**: The home screen suggests your next workout based on your history

### Viewing History

1. Tap the "History" tab
2. Browse your past workouts
3. Tap any workout to see full details

### Checking PRs

1. Tap the "PRs" tab
2. See all your personal records organized by exercise
3. Track your max weight and estimated 1RM

## Core Data Model 🗄

### Entities

- **ExerciseTemplate**: Exercise definitions (e.g., "Barbell Bench Press")
- **WorkoutSession**: Individual workout sessions
- **SetEntry**: Individual sets within a workout
- **PersonalRecord**: PR tracking for each exercise

### Relationships

- WorkoutSession has many SetEntries
- ExerciseTemplate has many SetEntries
- ExerciseTemplate has many PersonalRecords

## Customization 🎨

### Adding More Exercises

Edit `PersistenceController.swift` and add to the `defaultExercises` array:

```swift
("Exercise Name", "Muscle Group", "Category"),
```

### Changing Colors

Edit `Constants.swift` to customize the app's color scheme:

```swift
extension Color {
    static let appBlue = Color.blue      // Change to your color
    static let appPurple = Color.purple  // Change to your color
}
```

## Future Enhancements 🔮

Potential features for future versions:

- ✅ Rest timer with background notifications
- ✅ Charts and analytics (using Swift Charts)
- ✅ iCloud sync across devices
- ✅ Apple Watch companion app
- ✅ Exercise videos/instructions
- ✅ Workout templates
- ✅ Export to CSV
- ✅ Apple Health integration

## Architecture 🏗

This app follows the MVVM (Model-View-ViewModel) pattern:

- **Models**: Core Data entities
- **Views**: SwiftUI views (UI layer)
- **ViewModels**: Business logic and state management
- **Services**: Reusable business logic (data, calculations)

### Key Design Decisions

1. **Core Data over SwiftData**: For maximum compatibility and control
2. **MVVM over MVC**: Better separation of concerns and testability
3. **No third-party dependencies**: Pure Swift and native frameworks
4. **Speed-first design**: Minimize taps and maximize logging speed

## Performance ⚡️

- Background Core Data contexts for all write operations
- Lazy loading for history lists
- Efficient FetchRequests with predicates and sort descriptors
- Debounced search in exercise selector

## Contributing 🤝

This is a personal project, but feel free to fork and customize for your own use!

## License 📄

This project is available for personal use. Feel free to modify and adapt it to your needs.

## Credits 👏

Built with ❤️ using Swift and SwiftUI

---

**Remember**: No BS. Fast logging. Clear progress. Everything else is secondary.

