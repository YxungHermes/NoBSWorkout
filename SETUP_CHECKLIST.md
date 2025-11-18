# NoBSWorkout - Project Setup Checklist

Use this checklist when setting up your Xcode project to ensure all files are properly added.

## ✅ Step-by-Step Setup Checklist

### 1. Create Xcode Project
- [ ] Open Xcode
- [ ] File → New → Project
- [ ] iOS → App
- [ ] Product Name: `NoBSWorkout`
- [ ] Interface: **SwiftUI**
- [ ] Storage: **Use Core Data** ✓ (IMPORTANT!)
- [ ] Save project

### 2. Create Folder Groups in Xcode
Create these folder groups (right-click project → New Group):

- [ ] App
- [ ] Models
- [ ] ViewModels
- [ ] Views
  - [ ] Common
  - [ ] Home
  - [ ] Workout
  - [ ] History
  - [ ] PRs
- [ ] Services
  - [ ] CoreData
- [ ] Utilities

### 3. Add Files - App (1 file)
- [ ] `App/NoBSWorkoutApp.swift`

### 4. Add Files - Models (8 Core Data files)
- [ ] `Models/ExerciseTemplate+CoreDataClass.swift`
- [ ] `Models/ExerciseTemplate+CoreDataProperties.swift`
- [ ] `Models/WorkoutSession+CoreDataClass.swift`
- [ ] `Models/WorkoutSession+CoreDataProperties.swift`
- [ ] `Models/SetEntry+CoreDataClass.swift`
- [ ] `Models/SetEntry+CoreDataProperties.swift`
- [ ] `Models/PersonalRecord+CoreDataClass.swift`
- [ ] `Models/PersonalRecord+CoreDataProperties.swift`

### 5. Configure Core Data Model
- [ ] Open `NoBSWorkout.xcdatamodeld` in Xcode
- [ ] Verify or create 4 entities:
  - [ ] ExerciseTemplate (with 8 attributes, 2 relationships)
  - [ ] WorkoutSession (with 6 attributes, 1 relationship)
  - [ ] SetEntry (with 7 attributes, 2 relationships)
  - [ ] PersonalRecord (with 6 attributes, 1 relationship)
- [ ] Set codegen to "Manual/None" for all entities (if using provided files)

### 6. Add Files - ViewModels (2 files)
- [ ] `ViewModels/HomeViewModel.swift`
- [ ] `ViewModels/WorkoutLoggingViewModel.swift`

### 7. Add Files - Views/Common (1 file)
- [ ] `Views/Common/MainTabView.swift`

### 8. Add Files - Views/Home (1 file)
- [ ] `Views/Home/HomeView.swift`

### 9. Add Files - Views/Workout (3 files)
- [ ] `Views/Workout/WorkoutTypeSelectionView.swift`
- [ ] `Views/Workout/WorkoutLoggingView.swift`
- [ ] `Views/Workout/ExerciseSelectorView.swift`

### 10. Add Files - Views/History (2 files)
- [ ] `Views/History/HistoryView.swift`
- [ ] `Views/History/WorkoutDetailView.swift`

### 11. Add Files - Views/PRs (1 file)
- [ ] `Views/PRs/PRsView.swift`

### 12. Add Files - Services (1 file)
- [ ] `Services/CoreData/PersistenceController.swift`

### 13. Add Files - Utilities (1 file)
- [ ] `Utilities/Constants.swift`

### 14. Delete Default Files
- [ ] Delete `ContentView.swift` (Xcode's default)
- [ ] Delete default `Persistence.swift` (if present)

### 15. Project Configuration
- [ ] Select project in navigator
- [ ] General tab:
  - [ ] Minimum Deployments: iOS 17.0
  - [ ] Orientation: Portrait (or add Landscape if desired)
- [ ] Signing & Capabilities:
  - [ ] Select your development team
  - [ ] Automatic signing enabled

### 16. Verify Build Settings
- [ ] Product → Clean Build Folder (Cmd + Shift + K)
- [ ] Build project (Cmd + B)
- [ ] Fix any compilation errors
  - Most common: Missing imports or target membership
  - Solution: Check File Inspector → Target Membership

### 17. First Run Test
- [ ] Select simulator (iPhone 15 recommended)
- [ ] Run app (Cmd + R)
- [ ] App launches successfully
- [ ] Home screen appears
- [ ] No console errors

### 18. Functional Tests
- [ ] **Home Screen**:
  - [ ] "Start Workout" button visible
  - [ ] "No workouts yet" message shows
  - [ ] All three tabs visible at bottom
  
- [ ] **Start Workout Flow**:
  - [ ] Tap "Start Workout"
  - [ ] Workout type selection screen appears
  - [ ] Tap "Push"
  - [ ] Workout logging screen appears
  - [ ] Exercise is pre-selected (e.g., "Barbell Bench Press")
  - [ ] Timer starts counting
  
- [ ] **Log Set Flow**:
  - [ ] Enter weight: "135"
  - [ ] Enter reps: "8"
  - [ ] Tap "Log Set"
  - [ ] Set appears in the list
  - [ ] Success haptic feedback occurs
  
- [ ] **Copy Last Set**:
  - [ ] Tap "Copy Last" button
  - [ ] Weight and reps auto-fill
  - [ ] Tap "Log Set" again
  - [ ] Second set logged
  
- [ ] **PR Detection**:
  - [ ] Enter higher weight (e.g., "145")
  - [ ] Enter reps (e.g., "6")
  - [ ] Tap "Log Set"
  - [ ] PR animation appears (🎉)
  - [ ] Set is marked with trophy icon
  
- [ ] **Change Exercise**:
  - [ ] Tap exercise selector
  - [ ] Sheet appears with exercise list
  - [ ] Search for "Squat"
  - [ ] Select "Barbell Squat"
  - [ ] Exercise changes
  - [ ] Previous sets remain
  
- [ ] **Finish Workout**:
  - [ ] Tap "Finish" button
  - [ ] Confirmation dialog appears
  - [ ] Tap "Finish" in dialog
  - [ ] Returns to home screen
  - [ ] Recent workout now shows
  
- [ ] **History Tab**:
  - [ ] Tap "History" tab
  - [ ] Workout appears in list
  - [ ] Shows correct workout type
  - [ ] Shows exercise count
  - [ ] Tap workout
  - [ ] Detail view shows all sets
  
- [ ] **PRs Tab**:
  - [ ] Tap "PRs" tab
  - [ ] Exercises with PRs appear
  - [ ] Shows max weight
  - [ ] Shows estimated 1RM
  - [ ] Date is correct

### 19. Data Persistence Test
- [ ] Close app (stop in Xcode)
- [ ] Run app again
- [ ] Home screen shows last workout
- [ ] History tab shows previous workouts
- [ ] PRs tab shows previous PRs
- [ ] Data persisted correctly

### 20. Edge Cases
- [ ] Try logging set with empty fields → Button disabled ✓
- [ ] Try logging set with zero weight → Button disabled ✓
- [ ] Try changing exercise mid-workout → Works ✓
- [ ] Try finishing workout with no sets → Allows but warns ✓

## 🎉 Setup Complete!

If all checkboxes are checked, your app is ready to use!

## 🐛 Common Issues & Solutions

### Issue: "Cannot find 'PersistenceController' in scope"
**Solution**: Check that `PersistenceController.swift` is:
- Added to your project
- Added to your target (check File Inspector → Target Membership)
- In the correct location: `Services/CoreData/`

### Issue: "Failed to load model named 'NoBSWorkout'"
**Solution**:
- Ensure `.xcdatamodeld` file is named exactly `NoBSWorkout.xcdatamodeld`
- Check it's added to your target
- Verify the model name matches in `PersistenceController.swift`

### Issue: Core Data crash on launch
**Solution**:
- Delete app from simulator/device
- Clean Build Folder (Cmd + Shift + K)
- Rebuild and run
- Check entity names match class names exactly

### Issue: "Cannot find type 'ExerciseTemplate' in scope"
**Solution**:
- Ensure all Core Data model files are added to target
- Verify entity names in `.xcdatamodeld` match class names
- Set Codegen to "Manual/None" in entity inspector

### Issue: Views not showing data
**Solution**:
- Check that managed object context is being passed through environment
- Verify `@FetchRequest` predicates are correct
- Check Core Data model relationships are set up correctly

### Issue: No exercises in selector
**Solution**:
- Check console for seeding errors
- Verify `seedDefaultExercisesIfNeeded()` is being called
- Check Core Data save is successful

## 📞 Still Having Issues?

1. Check the console output for error messages
2. Review the `QUICKSTART.md` guide
3. Verify all files are added to the target
4. Clean build folder and rebuild
5. Delete app from device/simulator and reinstall

## 🚀 Next Steps After Setup

1. **Customize exercises**: Edit `PersistenceController.swift` to add your favorites
2. **Change colors**: Edit `Constants.swift` for custom theme
3. **Add rest timer**: Implement `TimerView.swift` (Phase 4)
4. **Add charts**: Use Swift Charts for analytics (Phase 5)
5. **Test on device**: Deploy to your iPhone for real workout testing

---

**Happy lifting! 💪**

