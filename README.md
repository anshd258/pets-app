# Posha - Pet Adoption App 🐾

A modern Flutter application for pet adoption with advanced state management, offline capabilities, and beautiful UI animations.

## 📱 Overview

Posha is a comprehensive pet adoption platform that connects potential pet owners with adorable pets looking for homes. The app features a clean, intuitive interface with powerful search capabilities, favorites management, and adoption history tracking.

## ✨ Features

### Core Functionality
- **Pet Discovery**: Browse through a curated list of pets available for adoption
- **Advanced Search**: Search pets by name, breed, or species with real-time filtering
- **Pet Details**: View comprehensive information about each pet including age, breed, description, and photos
- **Favorites Management**: Save favorite pets for easy access later
- **Adoption History**: Track your adoption journey and previously adopted pets

### User Experience
- **Offline Support**: Continue browsing cached pets even without internet connection
- **Pull-to-Refresh**: Easy content refresh with intuitive gestures
- **Infinite Scroll**: Seamless pagination for browsing large pet databases
- **Theme Support**: Switch between light and dark themes
- **Smooth Animations**: Beautiful page transitions and UI animations
- **Network Awareness**: Visual indicators for connectivity status

### Technical Features
- **Robust Caching**: Local storage with Hive for offline functionality
- **State Management**: BLoC pattern for predictable state management
- **Error Handling**: Graceful error handling with fallback mechanisms
- **Responsive Design**: Optimized for different screen sizes

## 🏗️ Architecture

The app follows a **Clean Architecture** pattern with clear separation of concerns:

```
lib/
├── core/                    # Core utilities and services
│   ├── constants/          # API constants and configuration
│   ├── network/           # Network client configuration
│   ├── services/          # Connectivity and core services
│   ├── theme/            # App theming and theme provider
│   └── utils/            # Utility classes (debouncer, etc.)
├── data/                   # Data layer
│   ├── models/           # Data models with Hive serialization
│   ├── repositories/     # Repository implementation
│   └── services/         # API services and local storage
├── logic/                  # Business logic layer
│   └── blocs/            # BLoC state management
│       ├── favorites/    # Favorites management
│       ├── history/      # Adoption history
│       ├── pet_details/  # Individual pet details
│       └── pet_list/     # Pet listing and search
└── presentation/           # UI layer
    ├── pages/            # App screens
    └── widgets/          # Reusable UI components
```

### Key Architectural Decisions

1. **BLoC Pattern**: Uses flutter_bloc for state management, providing:
   - Separation between UI and business logic
   - Testable and maintainable code
   - Reactive programming with streams

2. **Repository Pattern**: Centralizes data access logic:
   - Single source of truth for data operations
   - Offline-first approach with API fallback
   - Automatic caching and synchronization

3. **Local Storage**: Hive database for:
   - Offline pet browsing
   - Favorites persistence
   - Adoption history tracking
   - User preferences storage

## 🛠️ Tech Stack

### Core Framework
- **Flutter 3.8+**: Cross-platform mobile development
- **Dart**: Programming language

### State Management
- **flutter_bloc**: Predictable state management
- **equatable**: Value equality for state objects
- **provider**: Theme and dependency injection

### Networking & API
- **dio**: HTTP client with interceptors
- **talker_dio_logger**: Network request/response logging

### Local Storage
- **hive**: Lightweight, fast NoSQL database
- **hive_flutter**: Flutter integration for Hive

### UI & Animations
- **animations**: Material motion animations
- **lottie**: Vector animations
- **cached_network_image**: Efficient image loading and caching
- **flutter_staggered_grid_view**: Pinterest-style grid layouts
- **pull_to_refresh**: Pull-to-refresh functionality
- **photo_view**: Image zoom and pan capabilities
- **confetti**: Celebration animations
- **flex_color_scheme**: Advanced theming

### Development & Testing
- **mocktail**: Mocking for unit tests
- **bloc_test**: BLoC testing utilities
- **build_runner**: Code generation
- **flutter_lints**: Dart linting rules

### Utilities
- **rxdart**: Reactive extensions for Dart
- **connectivity_plus**: Network connectivity detection

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.8.0 or higher
- Dart SDK
- Android Studio / VS Code
- Android/iOS device or emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/posha.git
   cd posha
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Configuration

1. **API Setup**: Update API endpoints in `lib/core/constants/api_constants.dart`
2. **Theme Customization**: Modify themes in `lib/core/theme/app_theme.dart`

## 📁 Project Structure

### Data Models
- **PetModel**: Core pet entity with Hive serialization
- **FavoriteModel**: Favorite pets with timestamps
- **HistoryModel**: Adoption history tracking

### Key Services
- **PetApiService**: REST API communication
- **PetRepository**: Data access abstraction layer
- **ConnectivityService**: Network status monitoring
- **HiveConfig**: Local database configuration

### BLoCs (State Management)
- **PetListBloc**: Pet listing, search, and pagination
- **PetDetailsBloc**: Individual pet details management
- **FavoritesBloc**: Favorites management
- **HistoryBloc**: Adoption history

## 🎨 UI Components

### Pages
- **HomePage**: Main pet listing with search and navigation
- **DetailsPage**: Detailed pet information and adoption actions
- **FavoritesPage**: User's favorite pets
- **HistoryPage**: Adoption history

### Widgets
- **PetCard**: Reusable pet display component
- **CustomSearchBar**: Search functionality with debouncing
- **NetworkIndicator**: Connection status display

## 🔧 Development

### Running Tests
```bash
flutter test
```

### Code Generation
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Linting
```bash
flutter analyze
```

## 📦 Build & Deploy

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ipa --release
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- The open-source community for the excellent packages
- Pet shelters and rescue organizations for their important work
