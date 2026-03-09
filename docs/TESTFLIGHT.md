# TestFlight Deployment Guide

Deploy Fidel Learn to TestFlight for beta testing.

---

## Prerequisites

1. **Apple Developer Account** (paid, $99/year)
2. **App in App Store Connect** — Create an app with bundle ID `com.fidellearn.app` at [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
3. **Xcode** — Latest stable version

---

## 1. Configure Code Signing

### Add your Team ID

1. Open `Config.xcconfig` in the project root (create from `Config.xcconfig.example` if needed)
2. Set your **Development Team ID** (replace the empty value):
   ```
   DEVELOPMENT_TEAM = YOUR_TEAM_ID
   ```
3. Find your Team ID: [developer.apple.com/account](https://developer.apple.com/account) → Membership → Team ID

### Regenerate the Xcode project

```bash
tuist generate
```

---

## 2. Option A: Deploy via Xcode (Recommended for first time)

1. Open `FidelLearn.xcodeproj` in Xcode
2. Select the **FidelLearn** scheme
3. Choose **Any iOS Device** as destination (not a simulator)
4. **Product → Archive**
5. When the Organizer opens, click **Distribute App**
6. Select **App Store Connect** → **Upload**
7. Follow the prompts (automatic signing, upload)
8. In App Store Connect, the build will appear under TestFlight after processing (5–30 min)

---

## 3. Option B: Deploy via Fastlane

### Install Fastlane

```bash
brew install fastlane
```

### Set credentials

```bash
export APPLE_ID="your@email.com"
export TEAM_ID="YOUR_TEAM_ID"
```

Or add to `fastlane/Appfile` (do not commit if it contains secrets).

### Run the beta lane

```bash
fastlane beta
```

This runs: lint → test → build → upload to TestFlight.

### Skip lint (if SwiftLint/SwiftFormat not installed)

```bash
fastlane build
# Then manually upload the IPA from ./build/FidelLearn.ipa
# Or use: fastlane run upload_to_testflight ipa_path:"./build/FidelLearn.ipa"
```

---

## 4. Verify Before Upload

### Run unit tests

```bash
xcodebuild test \
  -scheme FidelLearn \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -only-testing:FidelLearnTests
```

### Build for device (sanity check)

```bash
xcodebuild build \
  -scheme FidelLearn \
  -destination 'generic/platform=iOS' \
  -configuration Release
```

---

## 5. After Upload

1. Go to [App Store Connect](https://appstoreconnect.apple.com) → Your App → TestFlight
2. Wait for build processing (usually 5–30 minutes)
3. Add internal/external testers
4. Submit for Beta App Review if using external testers

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "Requires a development team" | Add `DEVELOPMENT_TEAM = YOUR_TEAM_ID` to `Config.xcconfig` and run `tuist generate` |
| "No signing certificate" | Xcode → Settings → Accounts → Download Manual Profiles, or create a distribution certificate |
| "Package.swift not found" | This is a Tuist project, not SPM. Use `tuist generate` and open the `.xcodeproj` |
| Archive fails | Ensure you're building for **Any iOS Device**, not a simulator |
| Upload fails | Check Apple ID has App Manager or Admin role for the app in App Store Connect |
