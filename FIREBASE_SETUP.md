# Firebase Setup Instructions

## Android Setup

1. **Create a Firebase Project:**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Click "Add project" or select an existing project
   - Follow the setup wizard

2. **Add Android App to Firebase:**
   - In Firebase Console, click the Android icon
   - Package name: `com.example.loam`
   - App nickname: `Loam Android` (optional)
   - Download SHA-1 (optional for now)

3. **Download google-services.json:**
   - After adding the app, download `google-services.json`
   - Place it in: `loam/android/app/google-services.json`
   - **Replace the placeholder file** that's currently there

4. **Enable Firebase Services:**
   - **Authentication:** Enable Email/Password, Google, and Apple sign-in
   - **Firestore Database:** Create database in test mode (you'll configure rules later)
   - **Storage:** Enable Firebase Storage

## iOS Setup (when needed)

1. **Add iOS App to Firebase:**
   - In Firebase Console, click the iOS icon
   - Bundle ID: `com.example.loam` (or your custom bundle ID)
   - Download `GoogleService-Info.plist`
   - Place it in: `loam/ios/Runner/GoogleService-Info.plist`

## Verify Setup

After adding `google-services.json`, rebuild the app:
```bash
cd loam
flutter clean
flutter pub get
flutter run
```

The app should now initialize Firebase successfully!

