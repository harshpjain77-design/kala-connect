# कला-Connect

## Firebase setup

1. Create a Firebase project and register the Android app id shown in `android/app/build.gradle.kts`.
2. Enable **Phone** under Firebase Authentication → Sign-in method.
3. Create a Cloud Firestore database and a Cloud Storage bucket.
4. Install the Firebase CLI, authenticate it, then install FlutterFire CLI:

   ```powershell
   firebase login
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

5. Deploy the included owner-only development rules:

   ```powershell
   firebase deploy --only firestore:rules,storage
   ```

6. Run the application:

   ```powershell
   flutter run
   ```

The application starts in local demo authentication mode until Firebase Phone
Authentication is enabled and Android SHA fingerprints are registered. Use any
valid-looking number and OTP `123456` for local testing. To use real Firebase
Phone Authentication after configuring it, run:

```powershell
flutter run --dart-define=USE_FIREBASE=true
```

To force local demo mode:

```powershell
flutter run --dart-define=USE_FIREBASE=false
```

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
