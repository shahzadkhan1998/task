# Profile Manager App

A comprehensive Flutter application for managing user profiles with Firebase integration.

## Features

### ✅ Core Features
- **Authentication**: Sign up, login, logout with Firebase Auth
- **Profile Management**: Create, read, update profile information
- **File Upload**: Profile pictures and documents to Firebase Storage
- **Permissions**: Camera, gallery, and storage access handling
- **Responsive UI**: Optimized for mobile devices
- **State Management**: Provider pattern for clean architecture

### 📱 Functionality
- User registration and authentication
- Profile creation with name, email, age
- Profile picture upload from gallery
- Document upload (PDF, images)
- Real-time profile updates
- Session persistence
- Error handling with user feedback

## Project Structure

```
lib/
├── models/
│   ├── user_model.dart          # User authentication model
│   └── profile_model.dart       # Profile data model
├── services/
│   ├── auth_service.dart        # Firebase Authentication
│   ├── firestore_service.dart   # Firestore database operations
│   └── storage_service.dart     # Firebase Storage operations
├── providers/
│   ├── auth_provider.dart       # Authentication state management
│   └── profile_provider.dart    # Profile state management
├── views/
│   ├── auth/
│   │   ├── login_screen.dart    # Login interface
│   │   └── signup_screen.dart   # Registration interface
│   └── profile/
│       ├── profile_screen.dart  # Profile display
│       └── edit_profile_screen.dart # Profile editing
├── utils/
│   ├── validators.dart          # Form validation
│   ├── permission_helper.dart   # Permission handling
│   └── constants.dart           # App constants and theme
└── main.dart                    # App entry point
```

## Setup Instructions

### 1. Prerequisites
- Flutter SDK (latest stable version)
- Firebase project setup
- Android Studio / VS Code
- Physical device or emulator

### 2. Firebase Configuration

#### Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project
3. Enable Authentication (Email/Password)
4. Create Firestore database
5. Set up Firebase Storage

#### Add Firebase to Flutter
1. Install Firebase CLI: `npm install -g firebase-tools`
2. Login: `firebase login`
3. Install FlutterFire CLI: `dart pub global activate flutterfire_cli`
4. Configure Firebase: `flutterfire configure`

#### Replace Configuration Files
Replace the placeholder files with your actual Firebase configuration:
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

### 3. Dependencies Installation
```bash
flutter pub get
```

### 4. Platform Setup

#### Android
- Minimum SDK: 21
- Target SDK: 34
- Permissions automatically handled

#### iOS
- Minimum iOS: 12.0
- Permissions configured in Info.plist
- Camera and photo library access

### 5. Run the App
```bash
# Debug mode
flutter run

# Release mode
flutter run --release
```

## Firebase Security Rules

### Firestore Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /profiles/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### Storage Rules
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /profile_pictures/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /documents/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Usage

### Authentication Flow
1. **Sign Up**: Create account with email/password
2. **Login**: Access existing account
3. **Session**: Automatic login on app restart

### Profile Management
1. **Create Profile**: Add name, age after registration
2. **Upload Picture**: Select from gallery, automatic upload
3. **Upload Document**: PDF or image files
4. **Edit Profile**: Update information anytime

### Permissions
- **Camera**: For taking profile pictures
- **Gallery**: For selecting existing photos
- **Storage**: For document uploads

## Error Handling
- Network connectivity issues
- Firebase authentication errors
- File upload failures
- Permission denials
- Form validation errors

## Testing Checklist

### ✅ Authentication
- [ ] User can sign up with valid email/password
- [ ] User can login with existing credentials
- [ ] User can logout successfully
- [ ] Session persists after app restart
- [ ] Error messages for invalid credentials

### ✅ Profile Management
- [ ] Profile creation with required fields
- [ ] Profile information display
- [ ] Profile editing and updates
- [ ] Data persistence in Firestore

### ✅ File Uploads
- [ ] Profile picture upload from gallery
- [ ] Document upload (PDF/images)
- [ ] File URLs saved in Firestore
- [ ] Upload progress indication

### ✅ Permissions
- [ ] Gallery permission request
- [ ] Camera permission request
- [ ] Storage permission request
- [ ] Proper error handling for denied permissions

### ✅ UI/UX
- [ ] Responsive design on different screen sizes
- [ ] Loading states during operations
- [ ] Error messages display
- [ ] Success feedback to users

## Bonus Features Implemented
- ✅ Form validation (email format, password length, age numeric)
- ✅ Progress indicators during uploads
- ✅ Clean architecture with proper separation of concerns
- ✅ Error handling with user-friendly messages
- ✅ Responsive UI design

## Technologies Used
- **Flutter**: Cross-platform mobile development
- **Firebase Auth**: User authentication
- **Cloud Firestore**: NoSQL database
- **Firebase Storage**: File storage
- **Provider**: State management
- **Image Picker**: Camera/gallery access
- **File Picker**: Document selection
- **Permission Handler**: Runtime permissions
- **Cached Network Image**: Optimized image loading

## Contributing
1. Fork the repository
2. Create feature branch: `git checkout -b feature/profile-manager-app`
3. Commit changes: `git commit -m 'Add profile management'`
4. Push to branch: `git push origin feature/profile-manager-app`
5. Open Pull Request

## License
This project is licensed under the MIT License.
