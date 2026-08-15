# TimeFlow

TimeFlow is a privacy-first Flutter app for recording daily activities and producing monthly time-use reports.

## Stack

- Flutter 3.47.0 stable
- Dart 3.11.x
- Material 3
- shared_preferences
- fl_chart
- intl

## Run

```bash
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```

Android:

```bash
flutter build apk
```

Open this repository in GitHub Codespaces. The `.devcontainer` installs the pinned Flutter SDK and VS Code Dart/Flutter tooling.

Codespaces is excellent for coding, analysis, tests, web development and Android builds. iOS builds/device testing still require a Mac with Xcode.

## Product direction

The current MVP records activities with start/end times, category, title and note. It provides a daily log and monthly category report with a pie chart.

Recommended production evolution:
- SQLite/Drift for larger datasets
- edit activities and overlap validation
- CSV/PDF export
- localization
- optional encrypted cloud backup
- reminders and recurring activities
- goals/budgets by category
