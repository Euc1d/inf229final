# 🍽️ Recipe Manager App

A comprehensive Flutter mobile application for managing recipes, meal planning, and cooking with an intuitive user interface and powerful features.

## 👥 Team Members

**Danial Kaltay** - 230103193@sdu.edu.kz - [@Euc1d](https://github.com/Euc1d)  
**Gaziz Nurgeldy** - 230103167@sdu.edu.kz

SDU University  
Mobile Application Development Course  
December 2025

## 📱 About The Project

Recipe Manager is a full-featured mobile application developed as a team project for managing recipes, meal planning, and cooking. Built with Flutter and Firebase, it provides a seamless cooking experience with features like cooking timers, shopping lists, and personalized recipe collections. The app includes a curated collection of 10 traditional Arabic recipes and allows users to create their own recipe database.

## ✨ Key Features

### Core Functionality
- **User Authentication** - Secure registration and login with Firebase Auth
- **Recipe Management** - Full CRUD operations for personal recipes
- **Advanced Search** - Real-time search with category filters (Breakfast, Lunch, Dinner, Dessert, Snack)
- **Favorites System** - Save and organize favorite recipes with heart icon
- **Smart Shopping List** - One-click ingredient addition from recipes
- **Cooking Timer** - Built-in countdown timer integrated with recipe cooking time
- **Push Notifications** - Recipe reminders and cooking alerts
- **Dark Mode** - Complete dark theme support with smooth transitions
- **Profile Management** - Edit profile with local avatar photo storage

### Unique Features
- ⏰ **Smart Cooking Timer** - Automatically pre-set from recipe cooking time
- 🛒 **One-Click Shopping** - Add all recipe ingredients to shopping list instantly
- 🌍 **Default Recipe Library** - 10 curated traditional Arabic recipes (Hummus, Falafel, Shawarma, etc.)
- 📱 **Responsive UI** - Beautiful Material Design 3 interface
- 🔍 **Intelligent Search** - Search across recipe titles, descriptions, and ingredients
- 💾 **Local Photo Storage** - Profile photos stored locally using SharedPreferences for fast access
- 🎨 **Theme Persistence** - Dark mode preference saved across sessions

## 🛠️ Technologies Used

### Frontend
- **Flutter 3.x** - Cross-platform mobile framework
- **Dart** - Programming language
- **Provider 6.x** - State management solution
- **Material Design 3** - Modern UI design system

### Backend & Services
- **Firebase Authentication** - User authentication and authorization
- **Cloud Firestore** - NoSQL database for recipes and user data
- **Flutter Local Notifications** - Push notification system
- **Shared Preferences** - Local data persistence
- **Image Picker** - Camera and gallery integration for profile photos

### External Packages
```yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6
  provider: ^6.1.1
  shared_preferences: ^2.2.2
  flutter_local_notifications: ^16.3.0
  image_picker: ^1.0.7
  url_launcher: ^6.2.2
```

## 📐 Project Architecture
```
lib/
├── models/
│   ├── recipe_model.dart        # Recipe data structure
│   └── user_model.dart          # User data structure
├── providers/
│   ├── auth_provider.dart       # Authentication state management
│   ├── recipe_provider.dart     # Recipe state management
│   ├── shopping_provider.dart   # Shopping list state management
│   └── theme_provider.dart      # Theme state management
├── services/
│   ├── auth_service.dart        # Firebase Auth operations
│   ├── database_service.dart    # Firestore CRUD operations
│   ├── notification_service.dart # Local notifications
│   └── shopping_service.dart    # Shopping list operations
├── screens/
│   ├── login_screen.dart        # Login page
│   ├── signup_screen.dart       # Registration page
│   ├── home_screen.dart         # Main recipe feed
│   ├── recipe_detail_screen.dart # Recipe details view
│   ├── add_recipe_screen.dart   # Create recipe form
│   ├── favorites_screen.dart    # Favorites collection
│   ├── shopping_list_screen.dart # Shopping list
│   ├── profile_screen.dart      # User profile
│   ├── edit_profile_screen.dart # Profile editing
│   └── cooking_timer_screen.dart # Cooking timer
└── main.dart                     # App entry point
```

**Architecture Pattern:** Provider Pattern + Service Layer
- **Models** - Data structures and business entities
- **Providers** - State management and UI logic
- **Services** - Backend communication and data operations
- **Screens** - User interface and navigation

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0 or higher)
- Dart SDK (3.0 or higher)
- Android Studio / VS Code with Flutter extensions
- Firebase project configured (instructions below)
- Android device or emulator (API level 21+)

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/Euc1d/recipe-app.git
cd recipe-app
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Configure Firebase**

Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)

Enable the following services:
- Authentication (Email/Password)
- Cloud Firestore Database
- Storage (optional)

Download configuration files:
- `google-services.json` for Android → `android/app/`
- `GoogleService-Info.plist` for iOS → `ios/Runner/`

4. **Set up Firestore Security Rules**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /recipes/{recipeId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    match /shoppingItems/{itemId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
  }
}
```

5. **Run the app**
```bash
flutter run
```

## 📦 Build Release

### Android APK (for direct installation)
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (for Google Play Store)
```bash
flutter build appbundle --release
```
Output: `build/app/outputs/bundle/release/app-release.aab`

### iOS (requires Mac)
```bash
flutter build ios --release
```

## 🎯 How to Use

### First Time Setup
1. **Launch the app** - Opens on Login screen
2. **Create account** - Tap "Sign Up" and register with email/password
3. **Load default recipes** - Go to Profile → "Load Default Recipes" (10 Arabic recipes)

### Daily Usage
1. **Browse Recipes** - View default and personal recipes on Home screen
2. **Search** - Use search bar to find recipes by name or ingredients
3. **Filter by Category** - Tap category chips (All, Breakfast, Lunch, Dinner, Dessert, Snack)
4. **Add to Favorites** - Tap heart icon on recipe cards or detail page
5. **Create Recipe** - Tap orange + button, fill form with ingredients and steps
6. **Shopping List** - Open recipe → "Add to List" button → adds all ingredients
7. **Cooking Timer** - Open recipe → tap blue clock button → auto-set timer
8. **Edit Profile** - Profile → "Edit Profile" → change name, email, password, photo
9. **Dark Mode** - Profile → toggle "Dark Mode" switch

### Recipe Management
- **View Details** - Tap any recipe card
- **Edit Recipe** - Only your own recipes (3-dot menu → Edit)
- **Delete Recipe** - Only your own recipes (3-dot menu → Delete)
- **Share Ingredients** - "Add to List" button on recipe detail page

## 🎨 Screenshots
<img width="591" height="1280" alt="image" src="https://github.com/user-attachments/assets/1c0c8273-7c63-4e9f-8018-c2874192df62" />
<img width="591" height="1280" alt="image" src="https://github.com/user-attachments/assets/b1cdcec1-f2aa-4b08-977e-d55550ac00c6" />




### Light Mode
- **Home Screen** - Recipe grid with search and category filters
- **Recipe Details** - Full recipe view with ingredients, steps, and actions
- **Add Recipe** - Form with dynamic ingredient/step fields
- **Shopping List** - Checkable items with swipe-to-delete
- **Profile** - User info with settings and actions

### Dark Mode
- Complete dark theme across all screens
- Smooth theme transitions
- Easy on the eyes for night cooking

## 🔐 Security & Privacy

### Authentication
- Firebase Authentication with email/password
- Secure password hashing (handled by Firebase)
- Session management with automatic token refresh

### Data Privacy
- User recipes are private (filtered by userId)
- Shopping lists are user-specific
- Profile data is protected by Firestore security rules
- Local photos stored in app-specific directory

### Best Practices
- Input validation on all forms
- Error handling with user-friendly messages
- Secure API calls with Firebase SDK
- No hardcoded credentials

## 📊 Database Schema

### Firestore Collections

**users/** - User profiles
```javascript
{
  name: "John Doe",
  email: "john@example.com",
  favoriteRecipes: ["recipeId1", "recipeId2"]
}
```

**recipes/** - Recipe database
```javascript
{
  title: "Chicken Shawarma",
  description: "Marinated chicken with spices",
  category: "Dinner",
  cookingTime: 45,              // minutes
  servings: 4,
  ingredients: [
    "1 kg chicken",
    "2 tsp cumin",
    "Pita bread"
  ],
  steps: [
    "Mix spices",
    "Marinate chicken",
    "Grill and serve"
  ],
  imageUrl: "https://...",
  userId: "user123",           // recipe owner
  createdAt: 1702818000000     // timestamp
}
```

**shoppingItems/** - Shopping list items
```javascript
{
  name: "2 cups chickpeas",
  isChecked: false,
  userId: "user123",
  recipeId: "recipe456",
  recipeName: "Hummus"
}
```

## 🌟 Development Highlights

### Team Collaboration
- **Version Control** - Git/GitHub for code management
- **Code Reviews** - Peer review before merging
- **Task Distribution** - Frontend/Backend split between team members
- **Communication** - Regular sync meetings and Telegram coordination

### Code Quality
- **Clean Architecture** - Clear separation of concerns
- **Error Handling** - Comprehensive try-catch blocks
- **Code Comments** - Well-documented complex logic
- **Consistent Styling** - Unified code formatting

### Performance Optimizations
- **Lazy Loading** - Images loaded on-demand
- **Efficient Queries** - Indexed Firestore queries by userId
- **State Management** - Provider prevents unnecessary rebuilds
- **Local Storage** - SharedPreferences for quick access

### User Experience
- **Loading Indicators** - Clear feedback during operations
- **Error Messages** - User-friendly error descriptions
- **Smooth Animations** - Hero animations and transitions
- **Responsive Design** - Works on various screen sizes

## 📝 Future Enhancements

### Planned Features
- [ ] Social features (share recipes with friends)
- [ ] Recipe ratings and reviews
- [ ] Meal planning calendar
- [ ] Nutrition information calculator
- [ ] Barcode scanner for ingredients
- [ ] Export shopping list to PDF
- [ ] Multi-language support (English, Russian, Kazakh)
- [ ] Recipe import from websites
- [ ] Video tutorials integration
- [ ] Voice commands for cooking

### Technical Improvements
- [ ] Unit and integration tests
- [ ] CI/CD pipeline setup
- [ ] Cloud Functions for advanced features
- [ ] Firebase Storage for user-uploaded images
- [ ] Offline mode with local database
- [ ] Analytics integration

## 🐛 Known Issues

- Profile photo displays only first letter on some devices (workaround: reload profile)
- Timer notification may not show on some Android versions (check notification permissions)

## 📚 Learning Outcomes

This project helped us learn:
- Flutter widget tree and state management
- Firebase integration (Auth, Firestore, Notifications)
- Provider pattern for scalable state management
- RESTful patterns in NoSQL databases
- Mobile UI/UX design principles
- Git collaboration workflows
- Debugging and error handling in production apps

## 🤝 Contributing

This is an educational project. For questions or suggestions:
- Create an issue on GitHub
- Contact team members via email
- Message on Telegram: [@Euc1d](https://t.me/Euc1d)

## 📄 License

This project is created for educational purposes as part of Mobile Application Development course at Suleyman Demirel University.

## 🙏 Acknowledgments

- **Flutter Team** - For the amazing cross-platform framework
- **Firebase** - For backend services and real-time database
- **Provider Package** - For elegant state management
- **Unsplash** - For high-quality recipe images
- **Material Design** - For UI/UX guidelines
- **Our Course Instructor** - For guidance and support
- **SDU** - For providing learning opportunities

## 📞 Contact & Support

**Danial Kaltay**  
📧 230103193@sdu.edu.kz  
💬 [@Euc1d](https://t.me/Euc1d)  
🐙 [GitHub](https://github.com/Euc1d)

**Gaziz Nurgeldy**  
📧 230103167@sdu.edu.kz

**University**  
Suleyman Demirel University  
Almaty, Kazakhstan

---

**Built with ❤️ and Flutter by Danial & Gaziz**

*December 2024*
