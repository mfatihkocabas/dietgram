# Diyetgram 🥗

A minimalist approach to diet tracking - Flutter mobile application based on Figma design implementation.

## ✨ Features

- **🎨 Figma Design Implementation**: Pixel-perfect recreation of the provided Figma design
- **📱 4 Main Screens**: 
  - Onboarding with minimalist approach
  - Login with Google Sign-in simulation
  - Dashboard with meal timeline and calorie summary
  - Add to Diary for meal tracking
- **🏗️ Clean Architecture**: Provider pattern for state management
- **🎯 Navigation**: Smooth navigation between screens
- **📊 Meal Tracking**: Add meals with calorie tracking
- **💚 Modern UI**: Google Fonts (Epilogue) and custom color palette

## 🎨 Design

This app is a faithful implementation of the Figma design with:
- Primary Green: `#21DF26`
- Dark Text: `#121712`
- Light Gray: `#F0F5F0`
- Medium Gray: `#6C876C`

## 🚀 Getting Started

### Prerequisites
- Flutter 3.4.4 or higher
- Dart SDK
- iOS Simulator / Android Emulator

### Installation

1. Clone the repository:
```bash
git clone https://github.com/mfatihkocabas/diyetgram-flutter.git
cd diyetgram-flutter
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## 📱 Screenshots

The app includes 4 main screens:
1. **Onboarding**: Welcome screen with app introduction
2. **Login**: Google Sign-in simulation
3. **Dashboard**: Meal timeline with calorie summary cards
4. **Add to Diary**: Meal type selection interface

## 🏗️ Project Structure

```
lib/
├── main.dart                 # App entry point with navigation
├── models/
│   └── meal.dart            # Meal data model
├── providers/
│   ├── auth_provider.dart   # Authentication state management
│   └── meal_provider.dart   # Meal data management
├── screens/
│   ├── onboarding_screen.dart
│   ├── login_screen.dart
│   ├── dashboard_screen.dart
│   └── add_to_diary_screen.dart
└── utils/
    └── app_colors.dart      # Color palette constants
```

## 🔧 Dependencies

- `flutter`: SDK
- `provider`: State management
- `google_fonts`: Epilogue font family
- `intl`: Date formatting
- `shared_preferences`: Local storage
- `google_sign_in`: Authentication (prepared)
- `firebase_auth` & `firebase_core`: Backend integration (prepared)

## 📋 Navigation Flow

```
Onboarding → Login → Dashboard ⟷ Add to Diary
```

## 🎯 Key Features Implemented

### ✅ Completed
- [x] Complete UI implementation matching Figma design
- [x] Navigation between all screens
- [x] Meal provider with CRUD operations
- [x] Sample data loading
- [x] Calorie calculation and display
- [x] Timeline view for meals
- [x] Responsive design
- [x] Clean code architecture

### 🚀 Future Enhancements
- [ ] Real Google Sign-in integration
- [ ] Firebase backend integration
- [ ] Meal photo capture
- [ ] Nutrition facts integration
- [ ] Charts and analytics
- [ ] Push notifications
- [ ] Premium features

## 🔄 State Management

The app uses Provider pattern for state management:
- **AuthProvider**: Handles authentication state
- **MealProvider**: Manages meal data, daily goals, and calculations

## 📊 Demo Data

The app includes sample meal data:
- Breakfast: Oatmeal with fruits (350 cal)
- Lunch: Grilled chicken salad (420 cal)
- Dinner: Salmon with vegetables (480 cal)
- Daily Goal: 2000 calories

## 🛠️ Built With

- **Flutter**: Cross-platform mobile framework
- **Dart**: Programming language
- **Provider**: State management solution
- **Google Fonts**: Typography
- **Material Design**: UI components

## 👨‍💻 Author

**M. Fatih Kocabaş**
- GitHub: [@mfatihkocabas](https://github.com/mfatihkocabas)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Design inspiration from provided Figma mockups
- Flutter community for excellent documentation
- Google Fonts for Epilogue font family 