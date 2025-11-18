# Quick Start Guide - Running NoBSWorkout

## Option 1: Create New Xcode Project (Recommended)

### Step 1: Create the Project
1. Open Xcode
2. Select **File → New → Project**
3. Choose **iOS → App**
4. Configure:
   - **Product Name**: `NoBSWorkout`
   - **Team**: Your development team
   - **Organization Identifier**: `com.yourname` (or your identifier)
   - **Interface**: **SwiftUI**
   - **Language**: **Swift**
   - **Storage**: ⚠️ **IMPORTANT: Check "Use Core Data"**
   - **Include Tests**: Optional (you can uncheck these)
5. Click **Next** and save to your desired location

### Step 2: Delete Default Files
Xcode will create some default files. Delete these:
- `ContentView.swift` (we have our own views)
- The default `Persistence.swift` (we have `PersistenceController.swift`)

### Step 3: Organize Your Project
Create folder groups in Xcode (right-click project → New Group):
- App
- Models
- ViewModels
- Views
  - Common
  - Home
  - Workout
  - History
  - PRs
- Services
  - CoreData
- Utilities

### Step 4: Add All Source Files

Copy these files into their respective groups:

**App/**
- `NoBSWorkoutApp.swift`

**Models/**
- `ExerciseTemplate+CoreDataClass.swift`
- `ExerciseTemplate+CoreDataProperties.swift`
- `WorkoutSession+CoreDataClass.swift`
- `WorkoutSession+CoreDataProperties.swift`
- `SetEntry+CoreDataClass.swift`
- `SetEntry+CoreDataProperties.swift`
- `PersonalRecord+CoreDataClass.swift`
- `PersonalRecord+CoreDataProperties.swift`

**Models/ (Core Data Model)**
- Replace the default `.xcdatamodeld` with `NoBSWorkout.xcdatamodeld`
- Or manually edit the Core Data model to match our schema (see Step 5)

**ViewModels/**
- `HomeViewModel.swift`
- `WorkoutLoggingViewModel.swift`

**Views/Common/**
- `MainTabView.swift`

**Views/Home/**
- `HomeView.swift`

**Views/Workout/**
- `WorkoutTypeSelectionView.swift`
- `WorkoutLoggingView.swift`
- `ExerciseSelectorView.swift`

**Views/History/**
- `HistoryView.swift`
- `WorkoutDetailView.swift`

**Views/PRs/**
- `PRsView.swift`

**Services/CoreData/**
- `PersistenceController.swift`

**Utilities/**
- `Constants.swift`

### Step 5: Configure Core Data Model

If you need to manually configure the Core Data model:

1. Open `NoBSWorkout.xcdatamodeld` in Xcode
2. Create 4 entities:

**ExerciseTemplate Entity**
- Attributes:
  - `id` (UUID)
  - `name` (String)
  - `muscleGroup` (String)
  - `category` (String)
  - `isFavorite` (Boolean, default: NO)
  - `isCustom` (Boolean, default: NO)
  - `notes` (String, optional)
  - `createdDate` (Date)
- Relationships:
  - `sets` → SetEntry (To Many, Cascade)
  - `personalRecords` → PersonalRecord (To Many, Cascade)

**WorkoutSession Entity**
- Attributes:
  - `id` (UUID)
  - `date` (Date)
  - `workoutType` (String)
  - `startTime` (Date)
  - `endTime` (Date, optional)
  - `notes` (String, optional)
- Relationships:
  - `sets` → SetEntry (To Many, Cascade)

**SetEntry Entity**
- Attributes:
  - `id` (UUID)
  - `setNumber` (Integer 16)
  - `weight` (Double)
  - `reps` (Integer 16)
  - `rpe` (Double)
  - `timestamp` (Date)
  - `isPR` (Boolean, default: NO)
- Relationships:
  - `workoutSession` → WorkoutSession (To One, Nullify)
  - `exercise` → ExerciseTemplate (To One, Nullify)

**PersonalRecord Entity**
- Attributes:
  - `id` (UUID)
  - `recordType` (String)
  - `value` (Double)
  - `reps` (Integer 16)
  - `dateAchieved` (Date)
  - `setEntryId` (UUID, optional)
- Relationships:
  - `exercise` → ExerciseTemplate (To One, Nullify)

### Step 6: Update App Entry Point

Make sure `NoBSWorkoutApp.swift` is set as the `@main` app entry point.

### Step 7: Build Settings

1. Select your project in the navigator
2. Select your target
3. **General** tab:
   - Minimum Deployments: **iOS 17.0**
   - iPhone Orientation: **Portrait** only (or add landscape if desired)
4. **Signing & Capabilities**:
   - Select your development team
   - Xcode should automatically manage signing

### Step 8: Run the App! 🚀

1. Select a simulator or device (iPhone 15 recommended for testing)
2. Press **Cmd + R** or click the **Play** button
3. The app should build and launch!

## What You Should See

When the app launches for the first time:

1. **Home Screen**: Shows "No workouts yet" with a large "Start Workout" button
2. **24 pre-loaded exercises** in the database (automatically seeded)
3. **Three tabs**: Home, History, PRs

### Test the App

1. **Tap "Start Workout"**
2. **Select "Push"** workout type
3. **The logging screen appears** with exercises pre-selected
4. **Enter weight and reps** (e.g., 135 lbs, 8 reps)
5. **Tap "Log Set"** - you'll see it appear in the sets list
6. **Log a few more sets**, then tap **"Finish"**
7. **Check the History tab** - your workout is there!
8. **Check the PRs tab** - your personal records are tracked!

## Troubleshooting

### "Cannot find 'PersistenceController' in scope"
- Make sure `PersistenceController.swift` is added to your target
- Check it's in the correct location: `Services/CoreData/`

### "Failed to load model named 'NoBSWorkout'"
- Ensure your `.xcdatamodeld` file is named exactly `NoBSWorkout.xcdatamodeld`
- Make sure it's added to your target (check File Inspector)

### Core Data Errors on Launch
- Delete the app from simulator/device
- Clean Build Folder (Cmd + Shift + K)
- Rebuild and run

### "Cannot find type 'ExerciseTemplate' in scope"
- Make sure all the Core Data model files are added to your target
- Make sure the entity names in the `.xcdatamodeld` match the class names

### App Crashes on Launch
- Check the console for error messages
- Most likely a Core Data configuration issue
- Verify all entity names and relationships are correct

## Next Steps

Once the app is running:

1. **Log some workouts** to test the full flow
2. **Try to beat a PR** - change the weight to something higher and see the celebration!
3. **Customize the exercises** - add your own favorites
4. **Explore the code** - it's well-organized and commented

## File Checklist ✅

Make sure you have all these files in your Xcode project:

- [ ] NoBSWorkoutApp.swift
- [ ] PersistenceController.swift
- [ ] NoBSWorkout.xcdatamodeld (Core Data model)
- [ ] 8 Core Data model files (Exercise, Workout, Set, PR classes & properties)
- [ ] HomeViewModel.swift
- [ ] WorkoutLoggingViewModel.swift
- [ ] MainTabView.swift
- [ ] HomeView.swift
- [ ] WorkoutTypeSelectionView.swift
- [ ] WorkoutLoggingView.swift
- [ ] ExerciseSelectorView.swift
- [ ] HistoryView.swift
- [ ] WorkoutDetailView.swift
- [ ] PRsView.swift
- [ ] Constants.swift

## Project Configuration Summary

- **Platform**: iOS 17.0+
- **Language**: Swift 5.9+
- **UI Framework**: SwiftUI
- **Persistence**: Core Data
- **Architecture**: MVVM
- **Bundle ID**: `com.yourname.NoBSWorkout` (change to yours)

---

🎉 **You're all set!** Enjoy your new workout tracking app!

If you run into any issues, double-check:
1. Core Data model is properly configured
2. All files are added to the target
3. Deployment target is iOS 17.0+
4. All imports are correct

