# Automatic GitHub Deployment - Push Code, Get Builds Automatically

Set up automatic builds and deployment when you push to GitHub.

## 🎯 What You'll Achieve

```
You push code to GitHub
        ↓
GitHub Actions builds your app automatically
        ↓
App uploads to TestFlight
        ↓
Testers get notified and can install
```

**No manual Xcode builds needed!**

## 📋 Quick Decision Guide

### Do You Need This?

**✅ Yes, if you:**
- Push code to GitHub regularly
- Want automatic builds on every commit
- Have multiple testers using TestFlight
- Want CI/CD for iOS development
- Hate manual archive/upload process

**❌ No, if you:**
- Only building for yourself occasionally
- Don't mind manual Xcode builds
- Not using TestFlight yet
- Just getting started with the app

## 🚀 Option 1: GitHub Actions (Recommended)

### What Is It?
GitHub's built-in CI/CD service. Runs workflows when you push code.

### Cost
- **Free tier**: 2,000 minutes/month for private repos
- **Public repos**: Unlimited free minutes
- **Paid**: $0.008/minute beyond free tier

### Requirements
- ✅ GitHub repository (free)
- ✅ Apple Developer Program ($99/year)
- ✅ Xcode project in repo
- ✅ Basic YAML knowledge (we'll provide template)

### Setup Time
- First time: 1-2 hours
- With our template: 30-60 minutes

---

## 📝 Step-by-Step: GitHub Actions Setup

### Phase 1: Prerequisites (15 min)

#### 1. Join Apple Developer Program
1. Go to [developer.apple.com](https://developer.apple.com)
2. Enroll ($99/year)
3. Wait for approval (usually instant to 48 hours)

#### 2. Create App in App Store Connect
1. Go to [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
2. **My Apps** → **+** → **New App**
3. Fill in details (name, bundle ID, etc.)

#### 3. Generate App Store Connect API Key
1. Go to **Users and Access** → **Keys** → **App Store Connect API**
2. Click **+** to generate key
3. Download the `.p8` key file (save securely!)
4. Note the **Key ID** and **Issuer ID**

### Phase 2: Certificates & Provisioning (30 min)

You'll need to create and download:
- Distribution Certificate
- App Store Distribution Provisioning Profile

**Option A: Use Fastlane Match (Recommended)**

Fastlane Match stores certificates in a private GitHub repo.

```bash
# Install fastlane
brew install fastlane

# Set up Match
cd /path/to/NoBSWorkout
fastlane match init

# Generate certificates
fastlane match appstore
```

**Option B: Manual Setup**

1. Go to [developer.apple.com/account/resources/certificates](https://developer.apple.com/account/resources/certificates)
2. Create Distribution Certificate
3. Download certificate
4. Create Provisioning Profile
5. Download profile

### Phase 3: Create GitHub Secrets (10 min)

Store sensitive data as GitHub secrets:

1. Go to your GitHub repo
2. **Settings** → **Secrets and variables** → **Actions**
3. **New repository secret**

**Add these secrets:**

| Secret Name | Value | Where to Get It |
|-------------|-------|-----------------|
| `APPLE_KEY_ID` | Key ID from API key | App Store Connect → API Key |
| `APPLE_ISSUER_ID` | Issuer ID | App Store Connect → API Key |
| `APPLE_KEY_CONTENT` | Contents of .p8 file | Open .p8 file, copy all text |
| `CERTIFICATE_P12` | Base64 of certificate | See below |
| `CERTIFICATE_PASSWORD` | Password for cert | You set this |
| `PROVISIONING_PROFILE` | Base64 of profile | See below |

**Converting to Base64:**

```bash
# For certificate
base64 -i YourCertificate.p12 | pbcopy

# For provisioning profile
base64 -i YourProfile.mobileprovision | pbcopy
```

Paste the clipboard into GitHub secrets.

### Phase 4: Create Workflow File (15 min)

Create `.github/workflows/ios-deploy.yml` in your repo:

```yaml
name: iOS Build and Deploy to TestFlight

on:
  push:
    branches: [ main, develop ]
  workflow_dispatch:  # Manual trigger

jobs:
  build-and-deploy:
    runs-on: macos-latest

    steps:
    - name: Checkout repository
      uses: actions/checkout@v3

    - name: Set up Xcode
      uses: maxim-lobanov/setup-xcode@v1
      with:
        xcode-version: '15.0'

    - name: Install dependencies
      run: |
        # Add if using CocoaPods or SPM
        # pod install

    - name: Import certificates
      env:
        CERTIFICATE_P12: ${{ secrets.CERTIFICATE_P12 }}
        CERTIFICATE_PASSWORD: ${{ secrets.CERTIFICATE_PASSWORD }}
      run: |
        # Create temp keychain
        security create-keychain -p actions temp.keychain
        security default-keychain -s temp.keychain
        security unlock-keychain -p actions temp.keychain

        # Import certificate
        echo "$CERTIFICATE_P12" | base64 --decode > certificate.p12
        security import certificate.p12 -k temp.keychain -P "$CERTIFICATE_PASSWORD" -T /usr/bin/codesign
        security set-key-partition-list -S apple-tool:,apple: -s -k actions temp.keychain

        # Clean up
        rm certificate.p12

    - name: Import provisioning profile
      env:
        PROVISIONING_PROFILE: ${{ secrets.PROVISIONING_PROFILE }}
      run: |
        mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles
        echo "$PROVISIONING_PROFILE" | base64 --decode > ~/Library/MobileDevice/Provisioning\ Profiles/profile.mobileprovision

    - name: Build archive
      run: |
        xcodebuild archive \
          -scheme NoBSWorkout \
          -configuration Release \
          -archivePath $PWD/build/NoBSWorkout.xcarchive \
          -destination 'generic/platform=iOS' \
          CODE_SIGN_STYLE=Manual \
          PROVISIONING_PROFILE_SPECIFIER="YourProfileName" \
          CODE_SIGN_IDENTITY="Apple Distribution"

    - name: Export IPA
      run: |
        xcodebuild -exportArchive \
          -archivePath $PWD/build/NoBSWorkout.xcarchive \
          -exportOptionsPlist ExportOptions.plist \
          -exportPath $PWD/build

    - name: Upload to TestFlight
      env:
        APPLE_KEY_ID: ${{ secrets.APPLE_KEY_ID }}
        APPLE_ISSUER_ID: ${{ secrets.APPLE_ISSUER_ID }}
        APPLE_KEY_CONTENT: ${{ secrets.APPLE_KEY_CONTENT }}
      run: |
        echo "$APPLE_KEY_CONTENT" > AuthKey.p8
        xcrun altool --upload-app \
          --type ios \
          --file build/NoBSWorkout.ipa \
          --apiKey $APPLE_KEY_ID \
          --apiIssuer $APPLE_ISSUER_ID
        rm AuthKey.p8

    - name: Clean up
      if: always()
      run: |
        security delete-keychain temp.keychain
        rm -rf ~/Library/MobileDevice/Provisioning\ Profiles/profile.mobileprovision
```

### Phase 5: Create Export Options (5 min)

Create `ExportOptions.plist` in repo root:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>YOUR_TEAM_ID</string>
    <key>uploadBitcode</key>
    <false/>
    <key>compileBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
    <key>signingStyle</key>
    <string>manual</string>
    <key>provisioningProfiles</key>
    <dict>
        <key>com.yourname.NoBSWorkout</key>
        <string>YourProvisioningProfileName</string>
    </dict>
</dict>
</plist>
```

Replace `YOUR_TEAM_ID` and `YourProvisioningProfileName`.

### Phase 6: Test the Workflow (5 min)

1. Commit and push workflow file:
```bash
git add .github/workflows/ios-deploy.yml ExportOptions.plist
git commit -m "Add CI/CD workflow"
git push origin main
```

2. Go to GitHub → **Actions** tab
3. Watch the workflow run
4. If successful, check TestFlight for build

---

## 🚀 Option 2: Fastlane + GitHub Actions (Advanced)

### What Is Fastlane?

Fastlane is the industry-standard tool for iOS automation.

### Benefits
- Handles certificates automatically
- Simplified configuration
- Better error messages
- More features (screenshots, metadata, etc.)

### Setup

1. **Install Fastlane:**
```bash
brew install fastlane
cd /path/to/NoBSWorkout
fastlane init
```

2. **Configure Fastfile:**

Create `fastlane/Fastfile`:

```ruby
default_platform(:ios)

platform :ios do
  desc "Push to TestFlight"
  lane :beta do
    # Set up code signing
    match(type: "appstore")

    # Increment build number
    increment_build_number

    # Build the app
    build_app(
      scheme: "NoBSWorkout",
      export_method: "app-store"
    )

    # Upload to TestFlight
    upload_to_testflight(
      skip_waiting_for_build_processing: true
    )
  end
end
```

3. **Create GitHub Action:**

`.github/workflows/ios-fastlane.yml`:

```yaml
name: iOS Deploy with Fastlane

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: macos-latest

    steps:
    - uses: actions/checkout@v3

    - name: Set up Ruby
      uses: ruby/setup-ruby@v1
      with:
        ruby-version: '3.0'
        bundler-cache: true

    - name: Install Fastlane
      run: bundle install

    - name: Deploy to TestFlight
      env:
        MATCH_PASSWORD: ${{ secrets.MATCH_PASSWORD }}
        FASTLANE_APPLE_ID: ${{ secrets.APPLE_ID }}
        FASTLANE_PASSWORD: ${{ secrets.APPLE_PASSWORD }}
      run: bundle exec fastlane beta
```

---

## 💡 Simplified Alternative: Use Fastlane Cloud

**What:** Fastlane's hosted build service

**Pros:**
- No complex setup
- No certificate management
- Just works

**Cons:**
- Costs money
- Less control

**Not available yet** - in development

---

## 🔧 Troubleshooting

### Build Fails: Certificate Issues
- Verify certificate is not expired
- Check provisioning profile matches bundle ID
- Ensure certificate is in base64

### Build Fails: Xcode Not Found
- Update `xcode-version` in workflow
- Use `xcode-select -p` locally to find version

### Upload Fails: API Key Issues
- Verify API key has not expired
- Check Key ID and Issuer ID are correct
- Ensure .p8 content is correct (no extra spaces)

### Workflow Doesn't Trigger
- Check branch name in workflow file
- Verify workflow file is in `.github/workflows/`
- Check Actions tab for errors

---

## 📊 What About Costs?

### GitHub Actions Minutes Used

Typical iOS build: ~15-30 minutes

**Free tier (Private repo):**
- 2,000 minutes/month
- = ~66-130 builds/month
- Additional: $0.008/minute

**Public repo:**
- Unlimited free

**For NoBSWorkout:**
If you push 2-3 times per day:
- ~60-90 builds/month
- Well within free tier

---

## 🎯 Recommended Workflow

### For Solo Development
1. Develop locally with Xcode
2. Push to GitHub when ready
3. GitHub Actions builds and uploads to TestFlight
4. You test via TestFlight

### For Team Development
1. Developers push to `develop` branch
2. GitHub Actions builds and uploads to TestFlight
3. Team tests via TestFlight
4. Merge to `main` for production builds

---

## 🚦 Start Simple, Scale Up

### Week 1-2: Manual Builds
- Build with Xcode
- Install on your device
- Learn the app

### Week 3-4: TestFlight
- Set up TestFlight
- Invite friends/testers
- Manual builds → TestFlight

### Month 2+: Automation
- Set up GitHub Actions
- Automatic builds on push
- Focus on code, not builds

---

## 📚 Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Fastlane Documentation](https://docs.fastlane.tools/)
- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [Fastlane Match Guide](https://docs.fastlane.tools/actions/match/)

---

## ✅ Next Steps

1. **Start with Xcode** - Get it working locally first
2. **Set up TestFlight** - Manual builds to TestFlight
3. **Add GitHub Actions** - Automate when comfortable
4. **Iterate and improve** - Refine your workflow

The automation is powerful but not required. Start simple!
