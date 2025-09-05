🚀 yxf_habit_tracking - YXF Habit Tracking App

yxf_habit_tracking is an enterprise-level cross-platform habit tracking application built with Flutter. It helps users build good habits, manage tasks, and improve productivity with features like Pomodoro technique, goal setting, and real-time typing practice.

中文文档 | README_zh.md

✨ Features

🎯 Core Modules

• 📅 Schedule & Todo Management

  • Parent/Child task hierarchy

  • Pomodoro timer integration

  • Priority-based task sorting

• 🎯 Habit Formation System

  • Pre-defined goals (e.g., "Chinese Double Pinyin")

  • Custom habit creation

  • Progress tracking and analytics

• ⌨️ Real-time Typing Practice

  • Online typing exercises

  • Downloadable word packs

  • Chinese article practice packages

• 📊 Advanced Analytics

  • Habit completion statistics

  • Productivity insights

  • Customizable reports

• 🌐 WebView Integration

  • In-app browser functionality

  • Secure web content access

🏗️ Enterprise Architecture

• Clean Architecture with layered design (Presentation-Domain-Data)

• Multi-platform Support: Android, iOS, HarmonyOS, Windows, macOS

• Internationalization (i18n) with ARB files

• Dynamic Theme Switching with custom design system

• BLoC State Management for predictable state transitions

🛠️ Technical Stack

Framework & Libraries

• Flutter 3.19.0 - Cross-platform UI framework

• Dart 3.3.0 - Programming language

• BLoC 8.1.0 - State management

• Equatable - Value comparison

• Dio - HTTP client

Internationalization

• flutter_localizations - Official localization support

• intl - Internationalization package

• ARB Files - Translation resource files

Data Persistence

• Hive - Local database

• SharedPreferences - Simple key-value storage

UI Components

• Fluent UI - Windows design system

• Cupertino - iOS design language

• Material 3 - Android material design

📁 Project Structure


lib/
├── core/
│   ├── constants/          # App constants
│   ├── errors/             # Failure classes
│   ├── network/            # Dio client setup
│   ├── theme/              # Theme data
│   └── utils/              # Utilities
├── data/
│   ├── datasources/        # Local & remote data sources
│   ├── models/             # Data models
│   └── repositories/       # Repository implementations
├── domain/
│   ├── entities/           # Business entities
│   ├── repositories/       # Repository contracts
│   └── usecases/           # Application use cases
├── presentation/
│   ├── blocs/              # BLoC classes
│   ├── pages/              # Screen pages
│   ├── widgets/            # Custom widgets
│   └── router/             # App routing
└── main.dart               # App entry point


🚀 Getting Started

Prerequisites

• Flutter SDK 3.19.0 or higher

• Dart 3.3.0 or higher

• IDE (VS Code or Android Studio with Flutter plugin)

Installation

1. Clone the repository
   git clone https://github.com/your-username/yxf_habit_tracking.git
   cd yxf_habit_tracking
   

2. Install dependencies
   flutter pub get
   

3. Generate localization files
   flutter gen-l10n
   

4. Run the application
   flutter run
   

Build Instructions

Android APK:
flutter build apk --release --target-platform android-arm64


iOS:
flutter build ios --release


Windows:
flutter build windows --release


macOS:
flutter build macos --release


🌍 Internationalization

The app uses Flutter's built-in localization system with ARB files:

1. Translation files: lib/l10n/arb/intl_*.arb
2. Generated classes: lib/l10n/generated/
3. Supported locales: English, Chinese (Simplified), Chinese (Traditional)

Add new translations:
flutter gen-l10n


🎨 Theming System

The app supports dynamic theme switching with:

• Light/Dark mode toggle

• Custom color schemes

• Platform-adaptive themes (Material/Cupertino/Fluent)
// Theme configuration example
ThemeData(
  primaryColor: Colors.blue,
  fontFamily: 'NotoSans',
  platform: TargetPlatform.windows,
);


📊 BLoC State Management

The app uses BLoC pattern for state management:
// Example BLoC implementation
class HabitBloc extends Bloc<HabitEvent, HabitState> {
  final GetHabits usecase;

  HabitBloc({required this.usecase}) : super(HabitInitial()) {
    on<LoadHabits>((event, emit) async {
      emit(HabitLoading());
      final result = await usecase();
      emit(HabitLoaded(habits: result));
    });
  }
}


🔧 Configuration

Environment Setup

Create .env file in root directory:

APP_NAME=yxf_habit_tracking
API_BASE_URL=https://api.example.com
ENABLE_ANALYTICS=true


Firebase Setup (Optional)

1. Create Firebase project
2. Add platform configurations
3. Enable Analytics, Crashlytics

📈 Performance Optimization

The app implements multiple performance optimizations:

• Const constructors for widget optimization

• ListView.builder for efficient scrolling

• Memory management with automatic disposal

• Image caching and compression

• Code splitting for reduced bundle size

🤝 Contributing

We welcome contributions! Please read our CONTRIBUTING.md and follow our CODE_OF_CONDUCT.md.

Development Workflow

1. Fork the repository
2. Create feature branch (git checkout -b feature/amazing-feature)
3. Commit changes (git commit -m 'Add amazing feature')
4. Push to branch (git push origin feature/amazing-feature)
5. Open Pull Request

Code Standards

• Dart style: Follow Effective Dart guidelines

• BLoC pattern: Use cubit for simple states

• Testing: ≥80% test coverage required

• Documentation: Document all public APIs

📝 Testing

Unit Tests

flutter test


Widget Tests

flutter test test/widget_test.dart


Integration Tests

flutter drive --target=test_driver/app.dart


📊 Analytics & Monitoring

• Firebase Analytics - User behavior tracking

• Crashlytics - Error monitoring

• Performance Monitoring - App performance metrics

🚀 Deployment

Android Play Store

flutter build appbundle --release


iOS App Store

flutter build ipa --release


Windows Store

flutter build windows --release


📋 Roadmap
v1.0 - Basic habit tracking & todo management

v1.5 - Advanced analytics & data visualization

v2.0 - AI-powered habit recommendations

v2.5 - Social features & community challenges

v3.0 - Wearable device integration

📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

🙏 Acknowledgments

• Flutter Team - Amazing cross-platform framework

• BLoC Library - Excellent state management solution

• Hive - Fast local database

• Contributors - All who help improve this project

📞 Support

If you have any questions or need help, please:

1. Check docs/README.md
2. Open an ../../issues
3. Contact us: mailto:email@example.com

Made with 💙 using Flutter
