# 🚀 Quick Start - Get NoBSWorkout on Your iPhone (5 Minutes)

The fastest way to get the app running on your iPhone.

## ⚡ Super Quick Version

1. **Open Xcode** → New Project → iOS App
   - Name: `NoBSWorkout`
   - Storage: **Core Data** ✅
   - Save in repository folder

2. **Delete** auto-generated Swift files (keep `Assets.xcassets`)

3. **Drag** `NoBSWorkout/` folder into Xcode
   - Uncheck "Copy items"
   - Create groups
   - Add to target

4. **Configure Core Data**:
   - Open `.xcdatamodeld`
   - Set each entity's **Codegen** → **"Class Definition"**

5. **Select your iPhone** in device selector

6. **⌘R** (Run)

7. **Trust on iPhone**: Settings → General → Device Management → Trust

8. **Done!** 🎉

## 📋 Detailed Checklist

Use this checklist to make sure you don't miss anything:

### Part 1: Xcode Project Setup (2 min)

- [ ] Open Xcode
- [ ] File → New → Project
- [ ] Select: iOS → App
- [ ] Configure:
  - [ ] Product Name: `NoBSWorkout`
  - [ ] Team: Your Apple ID
  - [ ] Interface: SwiftUI
  - [ ] Language: Swift
  - [ ] **Storage: Core Data ← IMPORTANT!**
- [ ] Save in: `/Users/yxunghermes/Desktop/lvr-nextjs-pricing/NoBSWorkout/`
- [ ] Delete auto-generated files:
  - [ ] Delete `ContentView.swift`
  - [ ] Delete `NoBSWorkoutApp.swift`
  - [ ] Delete auto-generated `.xcdatamodeld`
  - [ ] Keep `Assets.xcassets`

### Part 2: Add Source Code (1 min)

- [ ] Right-click NoBSWorkout folder → "Add Files to 'NoBSWorkout'..."
- [ ] Navigate to `NoBSWorkout/` directory
- [ ] Select ALL folders: `App`, `Models`, `ViewModels`, `Views`, `Services`, `Utilities`
- [ ] **UNCHECK** "Copy items if needed"
- [ ] **CHECK** "Create groups"
- [ ] **CHECK** "Add to targets: NoBSWorkout"
- [ ] Click Add
- [ ] Also add `Info.plist` from `NoBSWorkout/` directory

### Part 3: Configure Core Data (1 min)

- [ ] Open `NoBSWorkout.xcdatamodeld`
- [ ] Select `ExerciseTemplate` → Data Model Inspector → Codegen: "Class Definition"
- [ ] Select `PersonalRecord` → Data Model Inspector → Codegen: "Class Definition"
- [ ] Select `SetEntry` → Data Model Inspector → Codegen: "Class Definition"
- [ ] Select `WorkoutSession` → Data Model Inspector → Codegen: "Class Definition"

### Part 4: Connect iPhone (30 sec)

- [ ] Connect iPhone to Mac with cable
- [ ] Unlock iPhone
- [ ] Tap "Trust This Computer" on iPhone
- [ ] In Xcode, select your iPhone from device selector (top toolbar)

### Part 5: Build & Run (1 min)

- [ ] Clean Build Folder: `⇧⌘K`
- [ ] Build: `⌘B`
- [ ] If build succeeds, Run: `⌘R`
- [ ] **On iPhone**: Settings → General → Device Management → Trust your Apple ID
- [ ] In Xcode, Run again: `⌘R`
- [ ] **App launches on iPhone!** 🎉

## 🎯 Success Criteria

You know it's working when:

✅ App icon appears on your iPhone home screen
✅ App launches without crashing
✅ You see the home screen with "Start Workout" button
✅ You can tap through and start a workout
✅ No error messages in Xcode console

## ⚠️ Common Issues & Quick Fixes

| Issue | Quick Fix |
|-------|-----------|
| "Cannot find type 'WorkoutSession'" | Core Data Codegen not set → See Part 3 |
| iPhone not in device list | Unplug/replug, unlock, trust computer |
| "Untrusted Developer" on iPhone | Settings → General → Device Management → Trust |
| Build errors | Clean build folder (`⇧⌘K`) and rebuild |
| "No such module 'CoreData'" | Recreate project with Core Data enabled |

## 🔄 Daily Workflow (After Setup)

Once set up, your daily workflow is simple:

1. Connect iPhone
2. Make changes in Xcode
3. `⌘R` to run on iPhone
4. Test and iterate

## 📖 Need More Details?

See `IPHONE_DEPLOYMENT.md` for comprehensive instructions and troubleshooting.

## 💡 Pro Tips

- **Keep iPhone connected**: Faster deployments, live debugging
- **Use breakpoints**: Debug on real device with real data
- **Check console**: Window → Show Debug Area (`⇧⌘Y`)
- **Test thoroughly**: Simulators ≠ real device behavior
- **Battery usage**: Disconnect when not actively testing

---

**Estimated total time: 5-7 minutes** ⏱️

Any issues? Check `IPHONE_DEPLOYMENT.md` for detailed troubleshooting.
