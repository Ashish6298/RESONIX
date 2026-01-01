# Resonix 🎵

**Resonix** is a modern, feature-rich Flutter music player application designed to provide a seamless audio experience. It allows users to play local audio files, manage favorites, and customize their viewing experience with theme support.

## ✨ Features

- **Local Music Playback**: Scan and play audio files from your device storage.
- **Audio Controls**: Play, pause, skip, and seek functionality using `just_audio` and `audio_service`.
- **Background Playback**: Continue listening to music even when the app is in the background.
- **Favorites System**: Mark songs as favorites for quick access (Current session).
- **Theme Support**: Switch between Dark and Light modes.
- **Splash Screen**: Engaging analytics-style launch screen.
- **Permissions Handling**: gracefully handles storage permissions to access media files.

## 📂 Folder Structure

The project structure is organized for scalability and maintainability:

```
lib/
├── models/
│   └── song_model.dart       # Data model for audio files
├── providers/
│   ├── favorites_provider.dart # Manages favorite songs list
│   └── music_provider.dart     # Handles audio playback logic and state
├── screens/
│   ├── home_screen.dart      # Main dashboard and song list
│   ├── player_screen.dart    # Full-screen music player interface
│   └── splash_screen.dart    # Initial launch screen
├── theme/
│   └── theme_provider.dart   # Manages application theme state
├── utils/
│   └── format_duration.dart  # Helper functions (e.g., time formatting)
├── widgets/
│   ├── player_controls.dart  # Reusable playback control buttons
│   └── song_tile.dart        # List item widget for individual songs
└── main.dart                 # Application entry point
```

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev/)
- **Language**: [Dart](https://dart.dev/)
- **State Management**: `provider`
- **Audio Engine**: `just_audio`, `audio_service`
- **Utils**: `permission_handler`, `file_picker`, `rxdart`

## 🚀 Getting Started

Follow these steps to run the project locally.

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed on your machine.
- An IDE (VS Code or Android Studio) with Flutter/Dart plugins.
- An Android Emulator or physical device.

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Ashish6298/RESONIX
   cd resonix
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the application:**
   ```bash
   flutter run
   ```

   *Note: For Android 13+, ensure you accept the granular media permissions prompted on first launch.*

## 🤝 Contributing

Contributions are welcome! Feel free to open issues or submit pull requests to improve Resonix.
