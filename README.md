# LuminFace - Premium Skin Analysis App

LuminFace is a sophisticated beauty-tech application built with Flutter and powered by Google Gemini AI. The app offers personalized skin analysis and beauty recommendations through a luxurious, user-friendly interface.

## 🌟 Key Features

- **Advanced Skin Analysis**: Utilizes Google Gemini for precise facial analysis
- **Elegant UI/UX**: Premium design with soft gradients, animations, and thoughtful interactions
- **Personalized Recommendations**: Custom skincare suggestions based on individual results
- **Beautiful Visualizations**: Intuitive charts and graphics to understand skin health
- **Secure Authentication**: Firebase email/password authentication with user profiles
- **Responsive Design**: Optimized for both Android and iOS devices

## 🎨 Design Elements

LuminFace features a refined, beauty-industry inspired color palette:

| Purpose | Color | Hex Code |
|---------|-------|----------|
| Background Light | Ivory White | #FFF9F5 |
| Background Dark | Soft Charcoal | #1D1B1E |
| Primary Accent | Orchid Pink | #EFA6BF |
| Secondary Accent | Blush Nude | #F7C6BA |
| Tertiary Accent | Rose Gold | #E6B8A2 |
| Call-To-Action | Rich Berry | #8E3B60 |
| Borders/Shadows | Mauve Mist | #D3BFD4 |
| Text Primary | Cocoa Gray | #3A3335 |
| Icon Tint/Glow | Light Champagne Glow | #F5E2D8 |

## 🧰 Technology Stack

- **Frontend**: Flutter SDK
- **Backend**: Firebase (Auth, Firestore, Storage, Functions)
- **AI Integration**: Google Gemini via Firebase Cloud Functions
- **State Management**: Provider
- **Image Processing**: Camera, Image Picker, and custom processing

## 📱 App Screens

1. **Onboarding & Authentication**
   - Splash screen
   - Login/Signup with email/password
   - User profile creation

2. **Home Screen**
   - Recent scan results
   - Quick actions
   - Beauty tips

3. **Scan Interface**
   - Camera with facial guidelines
   - Gallery upload option
   - Capture feedback

4. **Analysis Results**
   - Summary metrics
   - Detailed analysis with visualizations
   - Personalized recommendations
   - Shareable results

5. **Profile & History**
   - User information
   - Scan history with progress tracking
   - Theme preferences

## 🔧 Setup Instructions

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio or VS Code with Flutter extensions
- Firebase account

### Firebase Configuration
1. Create a new Firebase project in the [Firebase Console](https://console.firebase.google.com/)
2. Enable Authentication, Firestore, and Storage services
3. Install FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```
4. Configure your Flutter app with Firebase:
   ```bash
   flutterfire configure
   ```
   This will create a `firebase_options.dart` file with your Firebase configuration.

### Gemini API Setup
1. Get API access to Google Gemini and set up a project
2. Deploy the Firebase cloud function for Gemini integration (code provided in the repository)
3. Update the function name in `lib/gemini_service.dart` if necessary

### Installation
1. Clone the repository
   ```
   git clone https://github.com/yourusername/lumin_face.git
   ```

2. Install dependencies
   ```
   cd lumin_face
   flutter pub get
   ```

3. Create necessary asset directories
   ```
   mkdir -p assets/images assets/animations
   ```

4. Run the app
   ```
   flutter run
   ```

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgements

- [Flutter Team](https://flutter.dev/)
- [Firebase](https://firebase.google.com/)
- [Google Gemini AI](https://deepmind.google/technologies/gemini/)

---

Designed and developed with 💖 by Swapnil  