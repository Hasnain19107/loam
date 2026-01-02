# Loam Flutter App

A Flutter mobile application for Loam - "Genuine People, In Real Life"

## Project Structure

This project uses GetX for state management and follows a feature-based architecture:

```
lib/
├── core/                    # Core utilities, constants, theme
│   ├── constants/          # App constants, colors, theme
│   ├── routes/             # Route definitions
│   └── widgets/            # Reusable widgets
├── data/                    # Data layer
│   ├── models/             # Data models
│   ├── network/            # Network services (Firebase)
│   └── repositories/       # Repository pattern implementations
└── features/               # Feature modules
    ├── auth/               # Authentication
    ├── home/               # Home screen
    ├── events/             # Events feature
    ├── profile/            # User profile
    ├── chat/               # Chat feature
    ├── matchmake/          # Matchmaking feature
    ├── settings/           # Settings
    └── admin/              # Admin dashboard
```

## Setup Instructions

1. **Install Dependencies**
   ```bash
   flutter pub get
   ```

2. **Firebase Setup**
   - Create a Firebase project at https://console.firebase.google.com
   - Add Android/iOS apps to your Firebase project
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Place them in the appropriate directories:
     - Android: `android/app/google-services.json`
     - iOS: `ios/Runner/GoogleService-Info.plist`

3. **Firebase Configuration**
   - Enable Authentication (Email/Password)
   - Enable Cloud Firestore
   - Enable Firebase Storage
   - Set up Firestore security rules
   - Set up Storage security rules

4. **Run the App**
   ```bash
   flutter run
   ```

## Features

- ✅ Authentication with Firebase
- ✅ User profiles
- ✅ Events browsing and registration
- ✅ Matchmaking system
- ✅ Admin dashboard
- ✅ Settings management

## Colors & Theme

The app uses the same color scheme as the React web app:
- Primary (Coral): `#F43F5E`
- Background (Cream): `#FDF7F2`
- Font: Lora (serif)

## State Management

This project uses GetX for:
- State management (Controllers)
- Dependency injection
- Route management
- Snackbars/Dialogs

## Firebase Collections

- `profiles` - User profiles
- `events` - Event listings
- `event_participants` - Event registrations
- `surveys` - Quiz surveys
- `matchmaker_sets` - Matchmaker question sets
- `matches` - User matches
- `user_roles` - Role-based access control

## Next Steps

1. Complete implementation of all pages
2. Add image upload functionality
3. Implement push notifications
4. Add offline support
5. Complete admin features
6. Add unit and integration tests
