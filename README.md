# Mamba Fast Tracker

## Overview

Flutter project for the Mamba Fast Tracker technical challenge: an intermittent fasting and calorie tracking app.

This repository currently contains the Android project scaffold and development workflow. It still runs Flutter's default counter demo. Product features have not been implemented.

## Screenshots

TODO: Add screenshots once the application UI exists.

## Features

Planned from the challenge specification:

- Simple login with a persistent session
- Predefined and custom fasting protocols
- Fasting timer that stays correct in the background and after restarting
- Notifications when fasting starts and ends
- Meal records with calories and automatic timestamps
- Daily calorie and fasting totals with goal status
- Previous-day summaries and a weekly chart
- Local data persistence

All features above are pending. Work is tracked in [GitHub Issues](https://github.com/matheusmedrado/desafioMamba/issues).

## Tech Stack

- Flutter 3.47.2 with Dart 3.13.2
- Android target with the generated Kotlin and Gradle configuration
- Java 17 for Android builds
- `flutter_test` and `flutter_lints` from the Flutter template
- `cupertino_icons` retained from the template
- GitHub Actions for validation

TODO: Choose application dependencies during architecture planning.

## Architecture

Only the generated Flutter scaffold exists. No feature layers, persistence models, or state management approach have been added.

TODO: Document the agreed architecture and responsibility boundaries.

## Project Structure

```text
.github/
  ISSUE_TEMPLATE/       Task template
  workflows/            Flutter validation
  pull_request_template.md
android/                Android host and Gradle configuration
lib/main.dart           Generated counter demo
test/widget_test.dart   Generated counter smoke test
pubspec.yaml            Package metadata and dependencies
pubspec.lock            Resolved dependency versions
```

## Getting Started

Install Flutter 3.47.2 from the [Flutter SDK archive](https://docs.flutter.dev/install/archive) and add its `bin` directory to your `PATH`. Dart is included.

Set up Java 17 and the Android SDK using the [Android setup guide](https://docs.flutter.dev/platform-integration/android/setup). The generated project uses Android platform 36. Gradle may download missing SDK and NDK components during the first build. Accept the Android SDK licenses on your development machine.

```bash
git clone https://github.com/matheusmedrado/desafioMamba.git
cd desafioMamba
flutter doctor -v
flutter doctor --android-licenses
flutter pub get
```

If Flutter selects a different Java installation, point it at your Java 17 installation with `flutter config --jdk-dir=<path-to-jdk-17>`.

## Running the App

Connect an Android device with USB debugging enabled or start an Android emulator.

```bash
flutter devices
flutter run -d <device-id>
```

This currently launches the counter demo.

## Building the APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`.

The template currently signs release builds with the debug key. This is suitable for checking the scaffold, but final release signing and delivery are still TODO.

## Testing

```bash
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

The existing test checks the generated counter demo. There are no feature tests yet.

GitHub Actions runs these checks and `flutter build apk --release` on pull requests into `main` and pushes to `main`.

## Engineering Decisions

- Android is the only generated platform because the challenge requires an APK or AAB.
- CI pins Flutter 3.47.2, and the application lockfile is committed to keep dependency resolution repeatable.
- The default demo and its test are retained as a working baseline.
- Work follows issue, branch, implementation, tests, pull request, CI, and merge. `main` is the stable branch. Use focused branches and Conventional Commits.

TODO: Record architecture, persistence, timer, and library decisions after they are agreed.

## Trade-offs

The scaffold keeps Flutter's default code and configuration. It is easy to validate, but does not represent the product UI or final release configuration.

## Known Limitations

- All challenge features are pending.
- Persistence, authentication, and state management have not been selected.
- Only the Android platform is generated.
- Final signing, release testing, and delivery links are pending.

## What I Would Improve With More Time

TODO: Record specific improvements after the MVP is implemented and evaluated.

## Time Spent

TODO: Record actual setup and implementation time before submission.
