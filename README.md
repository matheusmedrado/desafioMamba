# Mamba Fast Tracker

## Overview

Flutter app for the Mamba Fast Tracker technical challenge: intermittent fasting and calorie tracking, Android first, all data stored on the device.

The repository currently has local login with a persistent session, fasting protocol selection, a timestamp-based fasting timer with local notifications, meal tracking, and a daily summary with goal status. Product features are implemented issue by issue.

## Screenshots

TODO: Add screenshots once the application UI exists.

## Features

Done:

- Local login with a persistent session. The session is restored after closing and reopening the app.
- Fasting protocols: 12:12, 16:8, 18:6, and a custom protocol with 8 to 23 fasting hours. The choice is stored locally.
- Fasting timer with start, pause, resume, and manual end controls. Elapsed and remaining time are restored from persisted timestamps after backgrounding or restarting the app.
- Local notifications when a fast starts and when its planned fasting goal is reached. The scheduled notification is restored, rescheduled, or canceled with the active session.
- Meal tracking: add, edit, and delete today's meals with a name and calories. The meal time is recorded automatically, and meals are stored in SQLite so they remain after restarting the app.
- Daily summary on Today: calories against a daily calorie limit, fasting time for the day, and whether the day is within goal. Ended fasts are stored in SQLite, so the totals remain after restarting the app.

Planned from the challenge specification:

- Previous-day summaries and a weekly chart

Remaining work is tracked in [GitHub Issues](https://github.com/matheusmedrado/desafioMamba/issues).

## Tech Stack

- Flutter 3.47.2 with Dart 3.13.2
- `flutter_riverpod` for state management and dependency injection
- `shared_preferences` for small single-record data such as the session and the calorie limit
- `sqflite` for meals and ended fasts, with `path` to build the database file path
- `flutter_local_notifications` for Android start and fasting-goal notifications
- `timezone` and `flutter_timezone` for scheduling in the device's local timezone
- Manrope (SIL Open Font License) bundled as the app font
- `flutter_test` and `flutter_lints`
- `sqflite_common_ffi` so repository tests run against real SQLite on the development machine and in CI
- Java 17, Android platform 36, Gradle from the generated Android project
- GitHub Actions for validation

## Architecture

Feature-first layout with a small shared core. Each feature keeps its own `domain`, `data`, and `presentation` code, and only creates the folders it needs.

Responsibilities:

- `domain`: plain Dart models and calculations. No Flutter imports. This is where fasting time math and the daily goal rule live, so they can be unit tested with a fake clock.
- `data`: repositories that own persistence for one kind of data.
- `presentation`: Riverpod notifiers that act as view models, plus widgets that render state and forward user actions.

Rules the code follows:

- Persisted timestamps are the source of truth for the fasting timer. A periodic timer only refreshes the UI. Elapsed and remaining time are always computed from stored values plus the current clock, so the timer stays correct after backgrounding and after the process is killed.
- Each durable piece of data has one repository that owns it.
- The current time comes from an injected `Clock`, never from `DateTime.now()` inside business logic.
- Navigation uses the plain `Navigator` with a bottom navigation shell. No routing package. A tab is built the first time it is opened and then kept in an `IndexedStack`, so switching tabs does not reload it.
- The fasting screen observes app lifecycle changes. It stops the display ticker when hidden and reloads the persisted session when the app resumes.
- Notifications are a projection of the persisted fasting session. A fixed goal-notification ID is canceled before a new target is scheduled, so pause, resume, end, and restore cannot leave an old target behind.
- Android uses inexact alarms. The timer remains correct if Android delays or does not deliver a notification.
- A fast is copied to SQLite when it ends. The copy is keyed by the fast id and repeated whenever the current fast loads, so it also recovers an app closed between the two writes.
- The daily summary is calculated in plain Dart from today's meals, the fasts that ended today, the current fast, and the calorie limit. It recalculates on every timer tick, so a running fast's time stays current.

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
  app/                  MaterialApp, theme, auth gate, and tab shell
  core/                 Clock, SQLite database, local day boundaries, and formatting helpers
  features/
    auth/
      domain/           UserSession model, login form rules
      data/             SessionRepository over shared_preferences
      presentation/     AuthController, LoginScreen
    fasting/
      domain/           FastingProtocol, ProtocolSettings, FastingSession
      data/             ProtocolRepository, FastingRepository, CompletedFastRepository, and notification service
      presentation/     Riverpod controllers, timer screen, protocol selection and custom editor
    meals/
      domain/           Meal model, calorie total, meal form rules
      data/             MealRepository over sqflite
      presentation/     MealsController, Meals screen, add/edit and delete sheets
    dashboard/
      domain/           DaySummary goal rule, calorie limit rules
      data/             CalorieLimitRepository over shared_preferences
      presentation/     Today summary providers, Your day section, calorie limit sheet
test/
  app/                  App smoke test
  core/                 Clock, database upgrade, local day, and formatting tests
  features/auth/        Validator, repository, controller, and login screen tests
  features/fasting/     Protocol, timer, persistence, completed fasts, notification, controller, and selection flow tests
  features/meals/       Validator, SQLite repository, controller, and Meals screen tests
  features/dashboard/   Goal rule, calorie limit, summary provider, and Your day section tests
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

The app opens on the login screen. Any well-formed email and a password with at least 8 characters sign you in. After that the Today tab shows the selected protocol, timer controls, and a summary of the day with calories, fasting time, and goal status. Tap Calories in that summary to change the daily calorie limit. The Meals tab lists today's meals and adds, edits, or deletes them. Android 13 and newer ask for notification permission when the first fast starts.

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

Decision: the login form validates the email format and a minimum password length. On success the session (email and sign-in time) is saved as JSON in `shared_preferences`. `AuthController` loads it on startup, and `AuthGate` picks the login screen or the app from that value.

Reason: it satisfies the requirement without a network dependency in an otherwise offline app, and the restore path is the same code on every launch.

Trade-off: no real account system. Any credentials that pass the form rules sign in, and the password is never stored or checked. Firebase Auth would add real accounts but also configuration and network handling that the challenge does not ask for.

### Fasting timer model

Problem: an in-memory counter drifts when Android suspends the app and is lost when the process is killed.

Decision: persist the protocol id, target duration, `startedAt`, `pausedAt`, accumulated paused time, `endedAt`, and lifecycle status. Compute elapsed and remaining from those values and the clock on every refresh.

Reason: the same calculation works while the app is open, after returning from background, and after a cold start. Paused wall-clock time is excluded. Reaching the target does not end the session on its own. The UI shows the goal as reached and the user ends the fast.

Trade-off: a few more fields than a counter. In exchange the timer has no drift and needs no background service.

### Local notifications

Problem: a notification must follow the active fasting session across pause, resume, restart, and manual end without becoming a second source of truth.

Decision: use `flutter_local_notifications` with `timezone`. Show a start notification immediately, and schedule one fixed-ID notification for the planned fasting goal. Synchronization cancels that ID first, then schedules it only for a running session whose goal has not been reached.

Reason: the persisted session already contains the target timestamp inputs. Rebuilding the notification projection from that state keeps pause, resume, end, and restore idempotent. `flutter_timezone` sets the timezone used by the schedule while persisted timestamps remain UTC.

Trade-off: Android uses inexact alarms, so delivery can be delayed by the OS. Notification timing is only a reminder; timer calculations do not depend on it. A failed notification call is logged and skipped, so it cannot block loading or changing a fast. The next transition or restore synchronizes again.

### Meal tracking

Problem: meals are a growing list that later issues will total per day and per week, and the challenge asks for an automatic meal time.

Decision: one `meals` table in a single app database (`core/database.dart`), with the meal time stored as UTC epoch milliseconds and indexed. The time is set once when the meal is added. Editing changes only the name and calories. The Meals screen shows the local calendar day of the injected clock and reloads when the app returns to the foreground, so the list moves to the new day after midnight. Every add, edit, or delete is saved first and the list is then read back from the database.

Reason: storing UTC and filtering by local day boundaries keeps day totals correct across timezones and daylight saving changes. Reading back after each change means the screen always shows what is stored. Keeping every table in one database file gives the schema one version number for future migrations.

Trade-off: re-reading the day after each change is an extra query, which is negligible for one day of meals. The meal time cannot be corrected by hand, which matches the specification but means a meal logged late keeps the time it was logged.

### Daily goal and day boundaries

Problem: the specification asks whether the user is within the goal, but it does not define the goal or which day a fast belongs to.

Decision: a day is within goal when its calories are at or under a daily calorie limit and a fast credited to that day reached its own target. The limit is 2,000 kcal by default and can be set from 500 to 5,000 on Today. A fast is credited to the local calendar day it ends, and the fast that has not ended counts toward today. Today reads "In progress" until the result is known. It becomes "Outside" as soon as calories go over the limit, or when the day's fast ended short of its target and no fast is still open. Ended fasts are copied to a `fasting_sessions` table (database version 2), so starting a new fast no longer replaces the previous one.

Reason: every fast already has a target, and the mockups judge days by it ("Goal reached", "Ended early"). The calorie limit adds the calorie side of the goal. Crediting a fast to the day it ends is exact with the stored fields and matches the day details mockup, which shows a fast that started the evening before. Each fast is compared with its own target, so changing the protocol later does not change past results.

Trade-off: a fast that crosses midnight adds no time to the day it started. Splitting fasting time at midnight was considered, but it would need the start and end of every pause, and only the total paused time is stored. The calorie limit is one current value rather than a value saved per day.

### Other choices

- The protocol choice is one small record: the selected protocol id plus the custom fasting hours. Custom hours are kept when a preset is selected again, so the custom card stays editable. Presets are constants in code, since they never change and there is nothing to store for them.
- Plain `Navigator` instead of a routing package. A few tabs and a handful of pushed screens do not justify one.
- Manrope is bundled as an asset instead of fetched at runtime, so the app renders correctly offline and on first launch.
- The Dockerfile installs the toolchain from the official Flutter and Android archives instead of a community image, so the Flutter version can be pinned to exactly what CI uses.
- Android is the only generated platform because the challenge requires an APK or AAB.
- CI pins Flutter 3.47.2, and the lockfile is committed to keep dependency resolution repeatable.

## Trade-offs

- Local persistence only. Reinstalling the app clears all data. This matches the challenge scope, which does not ask for cloud sync.
- The theme is dark only, following the approved mockups. A light theme is possible later since the design tokens exist for it.
- The release build is still signed with the debug key. Final signing is handled in the release issue.

## Known Limitations

- Login is local only. There is no registration, password recovery, or password verification. The mockup links for those flows were left out on purpose.
- Android may delay inexact notifications because of Doze mode or vendor battery-management rules. Notification permission can also be denied.
- The Meals screen shows only today. Meals from earlier days stay stored but are not visible or editable until History is implemented.
- A fast counts on the day it ends. A fast that crosses midnight adds no time to the day it started.
- The calorie limit is a single current value. When History shows earlier days, they will be judged against the current limit.
- If saving an ended fast to SQLite fails, the error is logged and the copy is retried the next time the current fast loads. If it still fails when a new fast starts, that ended fast is missing from the day totals.
- History and the weekly chart are pending.
- Final signing, release testing, and delivery links are pending.

## What I Would Improve With More Time

TODO: Record specific improvements after the MVP is implemented and evaluated.

## Time Spent

TODO: Record actual setup and implementation time before submission.
