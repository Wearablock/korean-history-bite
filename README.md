# Korean History Bite

A Flutter quiz app for learning Korean history one bite at a time. Covers all eras from prehistory to contemporary Korea with 986 curated questions.

## Features

- **Daily Study Goals** - Customizable 1-5 chapters per day
- **Smart Quiz System** - Multiple-choice questions across 10 historical eras
- **Spaced Repetition** - Review system based on the forgetting curve
- **Progress Tracking** - Per-era mastery tracking and study statistics
- **Wrong Answer Review** - Detailed explanations for incorrect answers
- **Sound & Haptic Feedback** - Audio and vibration on correct/wrong answers
- **Study Notifications** - Configurable daily reminders
- **Dark Mode** - System, light, and dark theme support
- **In-App Updates** - Upgrade prompts via `upgrader` package

## Supported Languages

Korean, English, Japanese, Simplified Chinese, Traditional Chinese, Spanish, Portuguese (Brazilian)

## Tech Stack

- **Framework**: Flutter (Dart SDK ^3.5.0)
- **State Management**: Riverpod
- **Local Database**: Drift (SQLite)
- **Ads**: Google Mobile Ads
- **In-App Purchase**: in_app_purchase
- **Notifications**: flutter_local_notifications
- **Deployment**: Fastlane (iOS + Android)

## Project Structure

```
lib/
  core/          # Theme, config, constants
  data/          # Models, DAOs, providers
  features/      # Feature modules
    home/        # Home screen with daily study
    study/       # Quiz session flow
    progress/    # Era-based progress tracking
    wrong_answers/ # Wrong answer review
    settings/    # App settings
    onboarding/  # First-launch setup
  l10n/          # ARB localization files
  services/      # Notification, audio, purchase services

assets/
  data/questions/  # Quiz data (JSON per locale per era)
  images/          # Historical images, artifacts, maps
```

## Getting Started

```bash
flutter pub get
flutter run
```

## Build & Deploy

```bash
# iOS - TestFlight
cd ios && fastlane beta

# Android - Internal Track
cd android && fastlane internal_with_metadata
```

## License

Proprietary - All rights reserved.
