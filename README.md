# Mamba Fast Tracker

## Overview

Flutter app for the Mamba Fast Tracker technical challenge: intermittent fasting and calorie tracking, Android first, all data stored on the device.

The repository currently has the app foundation: theme, composition root, clock abstraction, and the validation workflow. Product features are implemented issue by issue.

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
- `flutter_riverpod` for state management and dependency injection
- Manrope (SIL Open Font License) bundled as the app font
- `flutter_test` and `flutter_lints`
- Java 17, Android platform 36, Gradle from the generated Android project
- GitHub Actions for validation

Planned for upcoming issues, listed here because the architecture already assumes them:

- `shared_preferences` for session, selected protocol, and the active fasting session
- `sqflite` for meals and completed fasting sessions
- `flutter_local_notifications` and `timezone` for start and goal notifications

## Architecture

Feature-first layout with a small shared core. Each feature keeps its own `domain`, `data`, and `presentation` code, and only creates the folders it needs.

Responsibilities:

- `domain`: plain Dart models and calculations. No Flutter imports. This is where fasting time math lives so it can be unit tested with a fake clock.
- `data`: repositories that own persistence for one kind of data.
- `presentation`: Riverpod notifiers that act as view models, plus widgets that render state and forward user actions.

Rules the code follows:

- Persisted timestamps are the source of truth for the fasting timer. A periodic timer only refreshes the UI. Elapsed and remaining time are always computed from stored values plus the current clock, so the timer stays correct after backgrounding and after the process is killed.
- Each durable piece of data has one repository that owns it.
- The current time comes from an injected `Clock`, never from `DateTime.now()` inside business logic.
- Navigation uses the plain `Navigator` with a bottom navigation shell. No routing package.

## Project Structure

```text
.github/
  ISSUE_TEMPLATE/       Task template
  workflows/            Flutter validation
  pull_request_template.md
android/                Android host and Gradle configuration
assets/
  fonts/                Manrope and its license
  images/               Wordmark
lib/
  main.dart             Composition root: ProviderScope and app
  app/                  MaterialApp and theme
  core/                 Clock abstraction and shared helpers
  features/             One folder per feature (added as features land)
test/
  app/                  App smoke test
  core/                 Clock tests
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

The app currently opens on a placeholder screen with the project theme. Login is the next issue.

## Building the APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`.

### With Docker

The `Dockerfile` builds the same APK without a local Flutter, Java, or Android SDK setup. It pins Flutter 3.47.2, Android platform 36, build-tools 36.0.0, and the NDK the project uses, so the result matches CI.

```bash
docker build --target apk --output type=local,dest=build/docker .
```

Output: `build/docker/app-release.apk`.

The first build downloads the toolchain and takes several minutes. Later builds reuse the cached toolchain layers and a Gradle cache mount, so only the app compiles again. Docker is only a build environment here. Running the app still needs an Android device or emulator.

The template currently signs release builds with the debug key. This is suitable for checking the scaffold, but final release signing and delivery are still TODO.

## Testing

```bash
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

Unit tests live in `test/` and mirror the `lib/` layout. Business logic is tested with a `FakeClock` so time based rules run against fixed dates.

GitHub Actions runs these checks and `flutter build apk --release` on pull requests into `main` and pushes to `main`.

## Engineering Decisions

### State management: Riverpod

Problem: the app needs shared state (session, active fast, meals) that several screens read, and business logic that tests can drive without widgets.

Decision: `flutter_riverpod` without code generation. Notifiers act as view models. Repositories and the clock are providers.

Reason: providers double as dependency injection, so tests override the clock and repositories with fakes in one place. There is little boilerplate compared to Bloc, and the pattern is easy to explain.

Trade-off: Riverpod is one more concept than `ChangeNotifier` with `provider`. The gain in testability is worth it for the timer logic.

### Persistence: shared_preferences plus sqflite

Problem: some data is a single record (session, selected protocol, active fast), some data is a growing list queried by day (meals, completed fasts).

Decision: `shared_preferences` for single records stored as JSON, `sqflite` tables for meals and completed fasting sessions.

Reason: key-value storage is the simplest fit for single records. SQLite makes daily totals and the weekly chart plain queries instead of in-memory filtering over JSON blobs. Neither needs code generation.

Trade-off: two storage packages instead of one. Each repository owns exactly one of them, so the split stays clear.

Alternative considered: `drift` for typed SQL. Rejected because generated files add explanation and setup cost that this scope does not need.

### Authentication: local only

Problem: the challenge asks for a simple login with a persistent session and does not require accounts or sync.

Decision: credentials are validated locally and the session is stored on the device.

Reason: it satisfies the requirement without a network dependency in an otherwise offline app.

Trade-off: no real account system. Firebase Auth would add it but also add configuration and network handling that the challenge does not ask for.

### Fasting timer model

Problem: an in-memory counter drifts when Android suspends the app and is lost when the process is killed.

Decision: persist `startedAt`, target duration, `pausedAt`, accumulated paused time, and status. Compute elapsed and remaining from those values and the clock on every refresh.

Reason: the same calculation works while the app is open, after returning from background, and after a cold start. Reaching the target does not end the session on its own. The UI shows the goal as reached and the user ends the fast.

Trade-off: a few more fields than a counter. In exchange the timer has no drift and needs no background service.

### Other choices

- Plain `Navigator` instead of a routing package. Three tabs and a handful of pushed screens do not justify one.
- Manrope is bundled as an asset instead of fetched at runtime, so the app renders correctly offline and on first launch.
- The Dockerfile installs the toolchain from the official Flutter and Android archives instead of a community image, so the Flutter version can be pinned to exactly what CI uses.
- Android is the only generated platform because the challenge requires an APK or AAB.
- CI pins Flutter 3.47.2, and the lockfile is committed to keep dependency resolution repeatable.

## Trade-offs

- Local persistence only. Reinstalling the app clears all data. This matches the challenge scope, which does not ask for cloud sync.
- The theme is dark only, following the approved mockups. A light theme is possible later since the design tokens exist for it.
- The release build is still signed with the debug key. Final signing is handled in the release issue.

## Known Limitations

- All product features are pending. Only the foundation exists.
- Final signing, release testing, and delivery links are pending.

## What I Would Improve With More Time

TODO: Record specific improvements after the MVP is implemented and evaluated.

## Time Spent

TODO: Record actual setup and implementation time before submission.
