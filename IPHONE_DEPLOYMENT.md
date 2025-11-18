# iPhone Deployment Workflow Guide

Complete guide to get NoBSWorkout running on your iPhone.

## Prerequisites

- ✅ Mac with Xcode 15.0+
- ✅ iPhone running iOS 15.0+
- ✅ Lightning/USB-C cable to connect iPhone to Mac
- ⚠️ **Apple Developer Account** (Free account works for personal device testing)

## Step-by-Step iPhone Deployment

### 1. Connect Your iPhone

1. Connect your iPhone to your Mac with a cable
2. **Unlock your iPhone**
3. If prompted, tap **"Trust This Computer"** on your iPhone
4. Enter your iPhone passcode

### 2. Set Up Xcode Project

#### A. Create/Open the Xcode Project

Since the repository doesn't include an `.xcodeproj` file, you need to create one:

1. Open **Xcode**
2. File → **New → Project**
3. Choose **iOS** → **App**
4. Configure:
   - **Product Name**: `NoBSWorkout`
   - **Team**: Select your Apple ID team (or "Add Account" if needed)
   - **Organization Identifier**: `com.yourname` (e.g., `com.yxunghermes`)
   - **Bundle Identifier**: Will be `com.yourname.NoBSWorkout`
   - **Interface**: **SwiftUI**
   - **Language**: **Swift**
   - **Storage**: **Core Data** ✅ (Important!)
5. **Save in**: `/Users/yxunghermes/Desktop/lvr-nextjs-pricing/NoBSWorkout/`
   - This creates `NoBSWorkout.xcodeproj` in that directory

#### B. Add Source Files to Xcode

1. In Xcode, delete the auto-generated files:
   - `ContentView.swift` (delete)
   - `NoBSWorkoutApp.swift` (delete - we have our own)
   - Keep `Assets.xcassets`
   - Delete the auto-generated `.xcdatamodeld` file

2. **Add all source folders**:
   - Right-click on **NoBSWorkout** (yellow folder) in Project Navigator
   - Select **"Add Files to 'NoBSWorkout'..."**
   - Navigate to: `/Users/yxunghermes/Desktop/lvr-nextjs-pricing/NoBSWorkout/NoBSWorkout/`
   - Select these folders:
     - `App/`
     - `Models/`
     - `ViewModels/`
     - `Views/`
     - `Services/`
     - `Utilities/`
   - **IMPORTANT**:
     - ❌ **Uncheck** "Copy items if needed"
     - ✅ **Check** "Create groups"
     - ✅ **Check** "Add to targets: NoBSWorkout"
   - Click **Add**

3. **Add Info.plist**:
   - Right-click on **NoBSWorkout** folder
   - Select **"Add Files to 'NoBSWorkout'..."**
   - Select `Info.plist` from `NoBSWorkout/` directory
   - ❌ **Uncheck** "Copy items if needed"
   - ✅ **Check** "Add to targets: NoBSWorkout"

### 3. Configure Core Data Auto-Generation

1. Open `NoBSWorkout.xcdatamodeld` in Xcode
2. **For each entity** (ExerciseTemplate, PersonalRecord, SetEntry, WorkoutSession):
   - Select the entity
   - Open **Data Model Inspector** (⌥⌘4)
   - Set **Codegen** to **"Class Definition"**

### 4. Configure Project Settings

#### A. Set Deployment Target

1. Click **NoBSWorkout** project (blue icon) in Project Navigator
2. Select **NoBSWorkout** target
3. **General** tab:
   - **Minimum Deployments**: iOS 15.0
   - **Supported Destinations**: iPhone

#### B. Configure Signing & Capabilities

1. Still in **General** tab
2. **Signing** section:
   - ✅ **Check** "Automatically manage signing"
   - **Team**: Select your Apple ID
   - **Bundle Identifier**: Should be `com.yourname.NoBSWorkout`

3. **Signing & Capabilities** tab:
   - Verify no errors appear
   - If you see "Failed to register bundle identifier":
     - Change bundle ID to something unique: `com.yourname.NoBSWorkout2`

### 5. Select Your iPhone as Destination

1. At the top of Xcode, click the **device selector** (shows "iPhone 15 Pro" or similar)
2. Select your **physical iPhone** from the list (should show your device name)
3. If your iPhone doesn't appear:
   - Make sure it's connected and unlocked
   - Trust the computer on your iPhone
   - Window → Devices and Simulators → Check your device is listed

### 6. Build and Run on iPhone

1. **Clean Build Folder**: `⇧⌘K` (Shift + Command + K)
2. **Build**: `⌘B` (Command + B)
   - Fix any errors that appear
3. **Run on iPhone**: `⌘R` (Command + R)

#### First-Time Device Installation

When you first run on your iPhone, you'll see an error:

**"Could not launch NoBSWorkout. Verify the Developer App certificate..."**

**Fix:**
1. On your **iPhone**, go to:
   - Settings → General → **VPN & Device Management**
   - Or: Settings → General → **Profiles & Device Management**
2. Find your **Apple ID** under "Developer App"
3. Tap it → **Trust "[Your Name]"**
4. Tap **Trust** again to confirm
5. Go back to Xcode and **Run** again (`⌘R`)

### 7. Test on Your iPhone

The app should now launch on your iPhone! 🎉

**Test these features:**
- ✅ Home screen loads
- ✅ Can start a workout
- ✅ Can select exercises
- ✅ Can log sets
- ✅ Timer works
- ✅ History shows workouts
- ✅ PRs are tracked

## Troubleshooting

### "No such module 'CoreData'" or Similar Errors

- Make sure Storage was set to **Core Data** when creating the project
- Check that `.xcdatamodeld` file is in your target

### Build Errors About Missing Types

- Verify Core Data Codegen is set to "Class Definition" for all entities
- Clean build folder and rebuild

### "Cannot find 'PersistenceController' in scope"

- Make sure all files in `Services/CoreData/` are added to the target
- Check Build Phases → Compile Sources includes all Swift files

### iPhone Not Appearing in Device List

1. Unplug and replug iPhone
2. Unlock iPhone
3. Trust computer
4. Window → Devices and Simulators → Check device status

### App Crashes on Launch

1. Check Xcode console for error messages
2. Common issues:
   - Core Data model not loading → Check `.xcdatamodeld` is in bundle
   - Persistence initialization failed → Check seeding code

## Quick Deployment Workflow (After Initial Setup)

Once everything is configured, your workflow is:

1. **Connect iPhone** (keep it connected)
2. **Make code changes** in Xcode
3. **⌘R** to build and run on iPhone
4. **Test** on device
5. **Repeat**

## Keeping Changes in Sync with Git

After you create the `.xcodeproj` file:

```bash
cd /Users/yxunghermes/Desktop/lvr-nextjs-pricing/NoBSWorkout
git status
# You'll see NoBSWorkout.xcodeproj/

# DO NOT commit the xcodeproj if you want to keep the repo structure as-is
# OR commit it if you want others to have it:
git add NoBSWorkout.xcodeproj/
git commit -m "Add Xcode project file"
git push origin claude/review-repo-organization-019FdxLBc1u55jmqxjnRYNxv
```

**Note**: The repository is currently designed to NOT include the `.xcodeproj` file. Each developer creates their own. This is an alternative approach to standard iOS projects.

## Advanced: TestFlight Distribution (Optional)

If you want to test on multiple devices or distribute to others:

1. **Join Apple Developer Program** ($99/year)
2. **Archive** the app (Product → Archive)
3. **Upload to App Store Connect**
4. **Create TestFlight build**
5. **Invite testers via email**

See Apple's TestFlight documentation for details.

## Need Help?

Common resources:
- **Apple Developer Documentation**: developer.apple.com
- **Xcode Help**: Help → Xcode Help
- **Device Console**: Window → Devices and Simulators → View Device Logs
